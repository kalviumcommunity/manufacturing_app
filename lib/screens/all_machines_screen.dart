import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/machine_status_summary_card.dart';
import 'machine_details.dart';

class AllMachinesScreen extends StatelessWidget {
  const AllMachinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Machines'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('machines').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to load machines',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          final machines = snapshot.data?.docs ?? [];

          if (machines.isEmpty) {
            return const Center(
              child: Text(
                'No machines found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final runningCount = machines.where((machine) {
            final data = machine.data() as Map<String, dynamic>;

            return data['status'] == 'Running';
          }).length;

          final breakdownCount = machines.where((machine) {
            final data = machine.data() as Map<String, dynamic>;

            return data['status'] == 'Breakdown';
          }).length;

          final maintenanceCount = machines.where((machine) {
            final data = machine.data() as Map<String, dynamic>;

            return data['status'] == 'Maintenance';
          }).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All Machines',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Monitor the current status of all production machines',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: MachineStatusSummaryCard(
                        title: 'Total',
                        value: machines.length.toString(),
                        icon: Icons.precision_manufacturing,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: MachineStatusSummaryCard(
                        title: 'Running',
                        value: runningCount.toString(),
                        icon: Icons.play_circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: MachineStatusSummaryCard(
                        title: 'Breakdowns',
                        value: breakdownCount.toString(),
                        icon: Icons.warning,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: MachineStatusSummaryCard(
                        title: 'Maintenance',
                        value: maintenanceCount.toString(),
                        icon: Icons.build,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  'Machine List',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                ...machines.map((machine) {
                  final data = machine.data() as Map<String, dynamic>;

                  final machineId = data['machineId'] ?? '';

                  final machineName = data['machineName'] ?? 'Unknown Machine';

                  final lineName = data['lineName'] ?? 'Unknown Line';

                  final status = data['status'] ?? 'Unknown';

                  Color statusColor;

                  if (status == 'Running') {
                    statusColor = Colors.green;
                  } else if (status == 'Breakdown') {
                    statusColor = Colors.red;
                  } else if (status == 'Maintenance') {
                    statusColor = Colors.orange;
                  } else {
                    statusColor = Colors.grey;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MachineDetailsScreen(
                              machineId: machineId,
                              machineName: machineName,
                              lineName: lineName,
                              status: status,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.precision_manufacturing,
                                color: Colors.blue,
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    machineName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    '$machineId • $lineName',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
