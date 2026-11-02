import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/pulsing_status_badge.dart';
import 'breakdown_form.dart';
import 'inspection_form.dart';

class MachineDetailsScreen extends StatefulWidget {
  final String machineId;
  final String machineName;
  final String lineName;
  final String status;

  const MachineDetailsScreen({
    super.key,
    required this.machineId,
    this.machineName = 'Machine Details',
    this.lineName = 'Production Line',
    this.status = 'Running',
  });

  @override
  State<MachineDetailsScreen> createState() => _MachineDetailsScreenState();
}

class _MachineDetailsScreenState extends State<MachineDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _reportFixed(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }

    final notesController = TextEditingController();

    final notes = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.runningLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.build_circle_rounded, color: AppColors.running),
            ),
            const SizedBox(width: 12),
            const Text('Report Fixed', style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Document the resolution and maintenance steps taken before returning the machine to production.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              minLines: 3,
              maxLines: 5,
              maxLength: 2000,
              decoration: const InputDecoration(
                labelText: 'Repair notes / resolution details',
                hintText: 'e.g. Replaced faulty bearing, tested calibration...',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.running,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              final value = notesController.text.trim();
              if (value.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter repair notes.'),
                    backgroundColor: AppColors.breakdown,
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext, value);
            },
            child: const Text('Submit Work Order'),
          ),
        ],
      ),
    );

    notesController.dispose();

    if (notes == null || notes.trim().isEmpty || !context.mounted) {
      return;
    }

    try {
      bool fnSuccess = false;
      try {
        final callable = FirebaseFunctions.instanceFor(region: 'asia-south1')
            .httpsCallable('reportRepair');
        final response = await callable.call<Map<String, dynamic>>({
          'machineId': widget.machineId,
          'notes': notes.trim(),
        });
        if (response.data['success'] == true) {
          fnSuccess = true;
        }
      } catch (_) {
        // Fallback to transactional client update
      }

      if (!fnSuccess) {
        final firestore = FirebaseFirestore.instance;

        var machineQuery = await firestore
            .collection('machines')
            .where('machineId', isEqualTo: widget.machineId)
            .limit(1)
            .get();

        DocumentReference machineRef;
        if (machineQuery.docs.isNotEmpty) {
          machineRef = machineQuery.docs.first.reference;
        } else {
          machineRef = firestore.collection('machines').doc(widget.machineId);
        }

        final repairRef = firestore.collection('repairRequests').doc();
        final historyRef = firestore.collection('workHistory').doc();

        final batch = firestore.batch();

        batch.update(machineRef, {
          'status': 'Pending Verification',
          'pendingRepairRequestId': repairRef.id,
          'lastFixedBy': user.uid,
          'lastFixedByEmail': user.email ?? '',
          'lastRepairNotes': notes.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        batch.set(repairRef, {
          'machineId': widget.machineId,
          'machineName': widget.machineName,
          'employeeId': user.uid,
          'employeeEmail': user.email ?? '',
          'notes': notes.trim(),
          'previousStatus': 'Breakdown',
          'status': 'Pending Verification',
          'createdAt': FieldValue.serverTimestamp(),
        });

        batch.set(historyRef, {
          'machineId': widget.machineId,
          'machineName': widget.machineName,
          'action': 'repair_submitted',
          'previousStatus': 'Breakdown',
          'newStatus': 'Pending Verification',
          'employeeId': user.uid,
          'employeeEmail': user.email ?? '',
          'notes': notes.trim(),
          'repairRequestId': repairRef.id,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await batch.commit();
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Repair submitted! Equipment is locked in Pending Verification awaiting supervisor sign-off.',
          ),
          backgroundColor: AppColors.maintenance,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not submit repair report: $e'),
          backgroundColor: AppColors.breakdown,
        ),
      );
    }
  }

  Future<void> _reviewRepairDialog({
    required BuildContext context,
    required String? pendingRequestId,
    required String currentMachineName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final notesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supervisor Safety Verification'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Machine: $currentMachineName (${widget.machineId})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'Conduct physical and electrical inspection before authorizing equipment re-energization.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              const Text(
                'Supervisor Review Notes (Mandatory if rejecting):',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'e.g. Cleared safety lockouts, vibration tests normal...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.breakdown,
              side: const BorderSide(color: AppColors.breakdown),
            ),
            onPressed: () async {
              final reviewNotes = notesController.text.trim();
              if (reviewNotes.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter review notes when rejecting a repair.'),
                    backgroundColor: AppColors.breakdown,
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext);
              await _executeRepairReview(context, pendingRequestId, 'reject', reviewNotes);
            },
            child: const Text('Reject Repair'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.running,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _executeRepairReview(
                context,
                pendingRequestId,
                'approve',
                notesController.text.trim(),
              );
            },
            child: const Text('Approve & Re-energize'),
          ),
        ],
      ),
    );

    notesController.dispose();
  }

  Future<void> _executeRepairReview(
    BuildContext context,
    String? requestId,
    String decision,
    String reviewNotes,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      bool fnSuccess = false;
      if (requestId != null && requestId.isNotEmpty) {
        try {
          final callable = FirebaseFunctions.instanceFor(region: 'asia-south1')
              .httpsCallable('reviewRepair');
          final response = await callable.call<Map<String, dynamic>>({
            'repairRequestId': requestId,
            'decision': decision,
            'notes': reviewNotes,
          });
          if (response.data['success'] == true) fnSuccess = true;
        } catch (_) {
          // Fallback to client transaction
        }
      }

      if (!fnSuccess) {
        final firestore = FirebaseFirestore.instance;
        final approved = decision == 'approve';
        final nextStatus = approved ? 'Running' : 'Breakdown';

        var machineQuery = await firestore
            .collection('machines')
            .where('machineId', isEqualTo: widget.machineId)
            .limit(1)
            .get();

        DocumentReference machineRef;
        if (machineQuery.docs.isNotEmpty) {
          machineRef = machineQuery.docs.first.reference;
        } else {
          machineRef = firestore.collection('machines').doc(widget.machineId);
        }

        final batch = firestore.batch();

        batch.update(machineRef, {
          'status': nextStatus,
          'pendingRepairRequestId': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
          if (approved) ...{
            'verifiedBy': user.uid,
            'verifiedByEmail': user.email ?? '',
            'verifiedAt': FieldValue.serverTimestamp(),
          }
        });

        if (requestId != null && requestId.isNotEmpty) {
          final repairRef = firestore.collection('repairRequests').doc(requestId);
          batch.update(repairRef, {
            'status': approved ? 'Approved' : 'Rejected',
            'decision': decision,
            'reviewedBy': user.uid,
            'reviewedByEmail': user.email ?? '',
            'reviewNotes': reviewNotes,
            'reviewedAt': FieldValue.serverTimestamp(),
          });
        }

        final historyRef = firestore.collection('workHistory').doc();
        batch.set(historyRef, {
          'machineId': widget.machineId,
          'machineName': widget.machineName,
          'action': approved ? 'repair_approved' : 'repair_rejected',
          'previousStatus': 'Pending Verification',
          'newStatus': nextStatus,
          'reviewedBy': user.uid,
          'reviewedByEmail': user.email ?? '',
          'repairRequestId': requestId ?? '',
          'notes': reviewNotes,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await batch.commit();
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(decision == 'approve'
              ? 'Repair verified. Equipment safely re-energized to Running status!'
              : 'Repair rejected. Equipment kept in Breakdown status.'),
          backgroundColor: decision == 'approve' ? AppColors.running : AppColors.breakdown,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete verification: $e'),
          backgroundColor: AppColors.breakdown,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view machine details.')),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('machines')
          .doc(widget.machineId)
          .snapshots(),
      builder: (context, machineSnapshot) {
        final machineData = machineSnapshot.data?.data();
        final currentStatus = machineData?['status'] as String? ?? widget.status;
        final currentMachineName = machineData?['machineName'] as String? ?? widget.machineName;
        final currentLineName = machineData?['lineName'] as String? ?? widget.lineName;
        final statusColor = AppColors.getStatusColor(currentStatus);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(currentMachineName),
          ),
          body: SingleChildScrollView(
            padding: Responsive.pagePadding(context),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HERO CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Icon(
                                  Icons.precision_manufacturing_rounded,
                                  color: statusColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentMachineName,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          child: Text(
                                            widget.machineId,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          child: Text(
                                            currentLineName,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              PulsingStatusBadge(status: currentStatus),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          // QUICK METRIC STATS
                          Row(
                            children: [
                              Expanded(
                                child: _MetricTile(
                                  label: 'Current Status',
                                  value: currentStatus,
                                  valueColor: statusColor,
                                  icon: Icons.speed_rounded,
                                ),
                              ),
                              Container(width: 1, height: 36, color: AppColors.border),
                              Expanded(
                                child: _MetricTile(
                                  label: 'Assigned Line',
                                  value: currentLineName,
                                  valueColor: AppColors.textPrimary,
                                  icon: Icons.factory_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (currentStatus == 'Pending Verification') ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.maintenanceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.maintenanceBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.security_rounded,
                              color: AppColors.maintenance,
                              size: 26,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Safety Lockout Active',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.maintenance,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Technician repair has been submitted. Machine remains locked until a supervisor inspects and authorizes re-energization.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ACTIONS SECTION
                    const Text(
                      'Operational Actions',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 600;
                        final pendingRequestId =
                            machineData?['pendingRepairRequestId'] as String?;

                        final inspectionButton = OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InspectionFormScreen(
                                  machineId: widget.machineId,
                                  machineName: currentMachineName,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.fact_check_rounded, size: 19),
                          label: const Text('Log Inspection'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.borderLight),
                            backgroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        );

                        final breakdownButton = OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BreakdownFormScreen(
                                  machineId: widget.machineId,
                                  machineName: currentMachineName,
                                  lineName: currentLineName,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.warning_amber_rounded, size: 19),
                          label: const Text('Report Breakdown'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.breakdown,
                            backgroundColor: AppColors.breakdownLight,
                            side: const BorderSide(color: AppColors.breakdownBorder),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        );

                        final fixedButton = ElevatedButton.icon(
                          onPressed: () => _reportFixed(context),
                          icon: const Icon(Icons.build_circle_rounded, size: 19),
                          label: const Text('Submit Repair'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.running,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        );

                        final reviewButton = ElevatedButton.icon(
                          onPressed: () => _reviewRepairDialog(
                            context: context,
                            pendingRequestId: pendingRequestId,
                            currentMachineName: currentMachineName,
                          ),
                          icon: const Icon(Icons.verified_user_rounded, size: 19),
                          label: const Text('Supervisor Sign-off'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.maintenance,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        );

                        Widget actionButton;
                        if (currentStatus == 'Breakdown') {
                          actionButton = fixedButton;
                        } else if (currentStatus == 'Pending Verification') {
                          actionButton = reviewButton;
                        } else {
                          actionButton = breakdownButton;
                        }

                        if (isWide) {
                          return Row(
                            children: [
                              Expanded(child: inspectionButton),
                              const SizedBox(width: 14),
                              Expanded(child: actionButton),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            SizedBox(width: double.infinity, child: inspectionButton),
                            const SizedBox(height: 10),
                            SizedBox(width: double.infinity, child: actionButton),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 26),

                    // TABS FOR MACHINE HISTORY
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabBar(
                            controller: _tabController,
                            labelColor: AppColors.textPrimary,
                            unselectedLabelColor: AppColors.textSecondary,
                            indicatorColor: AppColors.textPrimary,
                            indicatorWeight: 2,
                            dividerColor: AppColors.border,
                            tabs: const [
                              Tab(text: 'Breakdowns'),
                              Tab(text: 'Inspections'),
                              Tab(text: 'Repairs'),
                            ],
                          ),
                          SizedBox(
                            height: 380,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _MachineBreakdownsTab(machineId: widget.machineId),
                                _MachineInspectionsTab(machineId: widget.machineId),
                                _MachineRepairsTab(machineId: widget.machineId),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: valueColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MachineBreakdownsTab extends StatelessWidget {
  final String machineId;

  const _MachineBreakdownsTab({required this.machineId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('breakdowns')
          .where('machineId', isEqualTo: machineId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline_rounded, color: AppColors.running, size: 36),
                SizedBox(height: 10),
                Text(
                  'No breakdowns recorded for this machine.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const Divider(height: 16),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final severity = data['severity'] ?? 'Medium';
            final desc = data['description'] ?? 'No description';
            final timestamp = data['timestamp'];
            String timeStr = 'Recent';
            if (timestamp is Timestamp) {
              final d = timestamp.toDate();
              timeStr = '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
            }

            final color = AppColors.getSeverityColor(severity);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.warning_rounded, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            severity,
                            style: TextStyle(color: color, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            timeStr,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _MachineInspectionsTab extends StatelessWidget {
  final String machineId;

  const _MachineInspectionsTab({required this.machineId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('inspectionReports')
          .where('machineId', isEqualTo: machineId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fact_check_outlined, color: AppColors.textMuted, size: 36),
                SizedBox(height: 10),
                Text(
                  'No inspection reports recorded yet.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const Divider(height: 16),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final result = data['result'] ?? 'Passed';
            final desc = data['description'] ?? 'Routine inspection';
            final inspector = data['employeeEmail'] ?? '';
            final timestamp = data['createdAt'];

            final Color color = result == 'Passed'
                ? AppColors.running
                : (result == 'Needs Attention' ? AppColors.maintenance : AppColors.breakdown);

            final IconData icon = result == 'Passed'
                ? Icons.check_circle_rounded
                : (result == 'Needs Attention' ? Icons.warning_amber_rounded : Icons.cancel_rounded);

            String formattedTime = 'Recent';
            if (timestamp is Timestamp) {
              final d = timestamp.toDate();
              formattedTime =
                  '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
            }

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              result,
                              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Text(
                              formattedTime,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                        if (inspector.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Inspector: $inspector',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MachineRepairsTab extends StatelessWidget {
  final String machineId;

  const _MachineRepairsTab({required this.machineId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('repairs')
          .where('machineId', isEqualTo: machineId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.build_outlined, color: AppColors.textMuted, size: 36),
                SizedBox(height: 10),
                Text(
                  'No repair logs recorded yet.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const Divider(height: 16),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final notes = data['notes'] ?? 'Repaired and restored to operation.';
            final email = data['repairedByEmail'] ?? '';

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.build_circle_rounded,
                    color: AppColors.textPrimary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        email.isNotEmpty ? 'Repaired by $email' : 'Repair Logged',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(notes, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
