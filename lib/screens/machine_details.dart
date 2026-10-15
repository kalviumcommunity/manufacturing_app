import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'breakdown_form.dart';
import 'inspection_form.dart';

class MachineDetailsScreen extends StatelessWidget {
  final String machineId;
  final String machineName;
  final String lineName;
  final String status;

  const MachineDetailsScreen({
    super.key,
    required this.machineId,
    required this.machineName,
    required this.lineName,
    required this.status,
  });

  Color _statusColor(String currentStatus) {
    switch (currentStatus) {
      case 'Running':
        return Colors.green;
      case 'Breakdown':
        return Colors.red;
      case 'Maintenance':
        return Colors.orange;
      case 'Pending Verification':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _reportFixed(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please sign in first.')));
      return;
    }

    final notesController = TextEditingController();

    final notes = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report Machine Fixed'),
        content: TextField(
          controller: notesController,
          minLines: 3,
          maxLines: 5,
          maxLength: 2000,
          decoration: const InputDecoration(
            labelText: 'Repair details',
            hintText: 'Describe what was repaired or checked...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = notesController.text.trim();

              if (value.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter the repair details.'),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext, value);
            },
            child: const Text('Submit Repair'),
          ),
        ],
      ),
    );

    notesController.dispose();

    if (notes == null || notes.trim().isEmpty || !context.mounted) {
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      // Find the machine by its machineId field.
      final machineQuery = await firestore
          .collection('machines')
          .where('machineId', isEqualTo: machineId)
          .limit(1)
          .get();

      if (machineQuery.docs.isEmpty) {
        throw Exception('Machine not found. No changes were made.');
      }

      final machineRef = machineQuery.docs.first.reference;
      final repairRef = firestore.collection('repairs').doc();

      // Commit the machine update and repair log together.
      final batch = firestore.batch();

      batch.update(machineRef, {
        'status': 'Running',
        'lastFixedBy': user.uid,
        'lastFixedByEmail': user.email ?? '',
        'lastRepairNotes': notes.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.set(repairRef, {
        'machineId': machineId,
        'machineName': machineName,
        'lineName': lineName,
        'notes': notes.trim(),
        'repairedBy': user.uid,
        'repairedByEmail': user.email ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Machine repaired and returned to Running status!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not submit repair report: $e'),
          backgroundColor: Colors.red,
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
          .collection('users')
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Unable to load your account role.')),
          );
        }

        if (!userSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = userSnapshot.data!.data();
        final role = userData?['role'];
        final isAdmin = role == 'admin';
        final isEmployee = role == 'user';

        if (!isAdmin && !isEmployee) {
          return const Scaffold(
            body: Center(
              child: Text('Your account does not have a valid role.'),
            ),
          );
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('machines')
              .doc(machineId)
              .snapshots(),
          builder: (context, machineSnapshot) {
            if (machineSnapshot.hasError) {
              return const Scaffold(
                body: Center(child: Text('Unable to load machine details.')),
              );
            }

            if (!machineSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final machineDocument = machineSnapshot.data!;

            if (!machineDocument.exists) {
              return Scaffold(
                appBar: AppBar(title: const Text('Machine Details')),
                body: const Center(child: Text('Machine not found.')),
              );
            }

            final machineData = machineDocument.data()!;
            final currentStatus = machineData['status'] as String? ?? status;
            final statusColor = _statusColor(currentStatus);

            return Scaffold(
              appBar: AppBar(
                title: const Text('Machine Details'),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.precision_manufacturing,
                                  color: Colors.blue,
                                  size: 35,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      machineData['machineName'] as String? ??
                                          machineName,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      machineId,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      machineData['lineName'] as String? ??
                                          lineName,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              const Text(
                                'Current Status',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    currentStatus,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Employees and admins can submit inspections.
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InspectionFormScreen(
                                machineId: machineId,
                                machineName: machineName,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.fact_check),
                        label: const Text('Report Inspection'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                    // When a machine is broken down, technicians or admins can report it fixed.
                    if (currentStatus == 'Breakdown') ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _reportFixed(context),
                          icon: const Icon(Icons.build_circle),
                          label: const Text('Report Fixed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],

                    // When a machine is running or in maintenance, anyone on the floor can report a breakdown immediately.
                    if (currentStatus != 'Breakdown') ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BreakdownFormScreen(
                                  machineId: machineId,
                                  machineName: machineName,
                                  lineName: lineName,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.warning),
                          label: const Text('Report Breakdown'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
