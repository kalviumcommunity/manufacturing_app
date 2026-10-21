import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/breakdown_summary_card.dart';
import 'inspection_form.dart';
import 'machine_details.dart';

class AllInspectionsScreen extends StatefulWidget {
  final String? resultFilter;

  const AllInspectionsScreen({super.key, this.resultFilter});

  @override
  State<AllInspectionsScreen> createState() => _AllInspectionsScreenState();
}

class _AllInspectionsScreenState extends State<AllInspectionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late String _currentResult;
  bool _glideForward = true;

  int _getResultIndex(String res) {
    switch (res) {
      case 'All':
        return 0;
      case 'Passed':
        return 1;
      case 'Needs Attention':
        return 2;
      case 'Failed':
        return 3;
      default:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _currentResult = widget.resultFilter ?? 'All';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setResult(String res) {
    if (_currentResult == res) return;
    final newIndex = _getResultIndex(res);
    final oldIndex = _getResultIndex(_currentResult);
    setState(() {
      _glideForward = newIndex >= oldIndex;
      _currentResult = res;
    });
  }

  Color _getResultColor(String result) {
    switch (result) {
      case 'Passed':
        return AppColors.running;
      case 'Needs Attention':
        return AppColors.maintenance;
      case 'Failed':
        return AppColors.breakdown;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getResultIcon(String result) {
    switch (result) {
      case 'Passed':
        return Icons.check_circle_rounded;
      case 'Needs Attention':
        return Icons.warning_amber_rounded;
      case 'Failed':
        return Icons.cancel_rounded;
      default:
        return Icons.fact_check_outlined;
    }
  }

  void _showNewInspectionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Machine to Inspect',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose an equipment unit from the plant floor to record an inspection report.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('machines').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Failed to load machines: ${snapshot.error}',
                          style: const TextStyle(color: AppColors.breakdown),
                        ),
                      );
                    }

                    final machines = snapshot.data?.docs ?? [];
                    if (machines.isEmpty) {
                      return const Center(
                        child: Text(
                          'No machines found in database.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: machines.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final mDoc = machines[index];
                        final mData = mDoc.data();
                        final mId = mDoc.id;
                        final mName = mData['name'] ?? 'Machine $mId';
                        final mLine = mData['line'] ?? 'Floor';
                        final mStatus = mData['status'] ?? 'Running';
                        final statusColor = AppColors.getStatusColor(mStatus);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.precision_manufacturing_rounded,
                              color: statusColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            mName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            '$mLine · Status: $mStatus',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InspectionFormScreen(
                                  machineId: mId,
                                  machineName: mName,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inspection & Audit Logs'),
        actions: [
          IconButton(
            tooltip: 'Record Inspection',
            icon: const Icon(Icons.add_task_rounded),
            onPressed: () => _showNewInspectionDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.fact_check_rounded, size: 20),
        label: const Text('Log Inspection'),
        onPressed: () => _showNewInspectionDialog(context),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('inspectionReports')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.breakdown),
                    const SizedBox(height: 12),
                    const Text(
                      'Failed to load inspection audit logs',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.breakdown),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];

          // Counts
          final totalCount = allDocs.length;
          final passedCount = allDocs.where((d) => (d.data()['result'] ?? '') == 'Passed').length;
          final attentionCount = allDocs.where((d) => (d.data()['result'] ?? '') == 'Needs Attention').length;
          final failedCount = allDocs.where((d) => (d.data()['result'] ?? '') == 'Failed').length;

          // Filter by result
          var filteredList = allDocs.where((d) {
            if (_currentResult == 'All') return true;
            return (d.data()['result'] ?? '') == _currentResult;
          }).toList();

          // Filter by search query
          if (_searchQuery.isNotEmpty) {
            filteredList = filteredList.where((d) {
              final data = d.data();
              final machine = (data['machineName'] ?? '').toString().toLowerCase();
              final id = (data['machineId'] ?? '').toString().toLowerCase();
              final desc = (data['description'] ?? '').toString().toLowerCase();
              final inspector = (data['employeeEmail'] ?? '').toString().toLowerCase();
              final res = (data['result'] ?? '').toString().toLowerCase();
              return machine.contains(_searchQuery) ||
                  id.contains(_searchQuery) ||
                  desc.contains(_searchQuery) ||
                  inspector.contains(_searchQuery) ||
                  res.contains(_searchQuery);
            }).toList();
          }

          return SingleChildScrollView(
            padding: Responsive.pagePadding(context),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PAGE HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Inspection & Audit Logs',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Live quality verification and maintenance safety records across all plant production lines.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // SUMMARY CARDS GRID
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmall = constraints.maxWidth < 600;
                        final cardWidth = isSmall
                            ? (constraints.maxWidth - 12) / 2
                            : (constraints.maxWidth - 36) / 4;

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: BreakdownSummaryCard(
                                title: 'Total Audits',
                                value: totalCount.toString(),
                                icon: Icons.fact_check_rounded,
                                color: AppColors.primary,
                                isSelected: _currentResult == 'All',
                                onTap: () => _setResult('All'),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: BreakdownSummaryCard(
                                title: 'Passed',
                                value: passedCount.toString(),
                                icon: Icons.check_circle_rounded,
                                color: AppColors.running,
                                isSelected: _currentResult == 'Passed',
                                onTap: () => _setResult('Passed'),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: BreakdownSummaryCard(
                                title: 'Attention',
                                value: attentionCount.toString(),
                                icon: Icons.warning_amber_rounded,
                                color: AppColors.maintenance,
                                isSelected: _currentResult == 'Needs Attention',
                                onTap: () => _setResult('Needs Attention'),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: BreakdownSummaryCard(
                                title: 'Failed',
                                value: failedCount.toString(),
                                icon: Icons.cancel_rounded,
                                color: AppColors.breakdown,
                                isSelected: _currentResult == 'Failed',
                                onTap: () => _setResult('Failed'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // SEARCH & FILTER BAR
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val.trim().toLowerCase();
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search by machine, inspector email, notes, or result...',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // RESULTS HEADER & ACTIVE FILTER STATUS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'AUDIT RECORDS (${filteredList.length})',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (_currentResult != 'All' || _searchQuery.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _currentResult = 'All';
                                _searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 14),
                            label: const Text('Reset filters', style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // DIRECTIONAL GLIDING INSPECTION LIST
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final offsetTween = Tween<Offset>(
                          begin: Offset(_glideForward ? 0.08 : -0.08, 0),
                          end: Offset.zero,
                        );
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offsetTween.animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<String>('$_currentResult-$_searchQuery'),
                        child: filteredList.isEmpty
                            ? _buildEmptyState()
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredList.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final doc = filteredList[index];
                                  final data = doc.data();
                                  final result = data['result'] ?? 'Passed';
                                  final desc = data['description'] ?? 'Routine inspection';
                                  final machineName = data['machineName'] ?? 'Unknown Machine';
                                  final machineId = data['machineId'] ?? '';
                                  final inspector = data['employeeEmail'] ?? 'Operator';
                                  final timestamp = data['createdAt'];

                                  String formattedDate = 'Recent';
                                  if (timestamp is Timestamp) {
                                    final d = timestamp.toDate();
                                    formattedDate =
                                        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
                                  }

                                  return _buildInspectionCard(
                                    context: context,
                                    machineName: machineName,
                                    machineId: machineId,
                                    result: result,
                                    description: desc,
                                    inspector: inspector,
                                    formattedDate: formattedDate,
                                  );
                                },
                              ),
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              size: 40,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Inspection Records Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No audit logs match your selected filter or search keywords.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => _showNewInspectionDialog(context),
            icon: const Icon(Icons.add_task_rounded, size: 16),
            label: const Text('Record New Inspection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionCard({
    required BuildContext context,
    required String machineName,
    required String machineId,
    required String result,
    required String description,
    required String inspector,
    required String formattedDate,
  }) {
    final resColor = _getResultColor(result);
    final resIcon = _getResultIcon(result);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: resColor.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: machineId.isNotEmpty
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MachineDetailsScreen(machineId: machineId),
                    ),
                  );
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Result Badge & Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Result Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: resColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: resColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(resIcon, size: 14, color: resColor),
                          const SizedBox(width: 5),
                          Text(
                            result.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: resColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Timestamp
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule_rounded, size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Machine Name & ID
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.precision_manufacturing_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            machineName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (machineId.isNotEmpty)
                            Text(
                              'ID: $machineId',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (machineId.isNotEmpty)
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Checklist / Description Notes Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Footer Row: Inspector & Action Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 5),
                        Text(
                          'Inspector: $inspector',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (machineId.isNotEmpty)
                      Text(
                        'View Machine →',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
