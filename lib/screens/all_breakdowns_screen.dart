import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/screens.dart';
import '../widgets/widgets.dart';

class AllBreakdownsScreen extends StatelessWidget {
  const AllBreakdownsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breakdowns'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('breakdowns')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to load breakdowns',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          final breakdowns = snapshot.data?.docs ?? [];

          if (breakdowns.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 60,
                    color: Colors.green,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No breakdowns reported',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'All machines are currently operating normally.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final criticalCount = breakdowns.where((breakdown) {
            final data = breakdown.data() as Map<String, dynamic>;

            return data['severity'] == 'Critical';
          }).length;

          final highCount = breakdowns.where((breakdown) {
            final data = breakdown.data() as Map<String, dynamic>;

            return data['severity'] == 'High';
          }).length;

          final mediumCount = breakdowns.where((breakdown) {
            final data = breakdown.data() as Map<String, dynamic>;

            return data['severity'] == 'Medium';
          }).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Breakdown Reports',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Monitor reported machine breakdowns and their severity',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: BreakdownSummaryCard(
                        title: 'Total',
                        value: breakdowns.length.toString(),
                        icon: Icons.warning_amber,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: BreakdownSummaryCard(
                        title: 'Critical',
                        value: criticalCount.toString(),
                        icon: Icons.error,
                        color: Colors.red.shade800,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: BreakdownSummaryCard(
                        title: 'High',
                        value: highCount.toString(),
                        icon: Icons.priority_high,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: BreakdownSummaryCard(
                        title: 'Medium',
                        value: mediumCount.toString(),
                        icon: Icons.warning,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  'Breakdown History',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                ...breakdowns.map((breakdown) {
                  final data = breakdown.data() as Map<String, dynamic>;

                  final machineName = data['machineName'] ?? 'Unknown Machine';

                  final machineId = data['machineId'] ?? 'Unknown ID';

                  final description = data['description'] ?? 'No description';

                  final severity = data['severity'] ?? 'Unknown';

                  final reportedBy = data['reportedBy'] ?? 'Unknown User';

                  Color severityColor;

                  if (severity == 'Critical') {
                    severityColor = Colors.red;
                  } else if (severity == 'High') {
                    severityColor = Colors.orange;
                  } else if (severity == 'Medium') {
                    severityColor = Colors.amber.shade700;
                  } else {
                    severityColor = Colors.green;
                  }

                  String reportedTime = 'Time unavailable';

                  final timestamp = data['timestamp'];

                  if (timestamp is Timestamp) {
                    final date = timestamp.toDate();

                    reportedTime =
                        '${date.day.toString().padLeft(2, '0')}/'
                        '${date.month.toString().padLeft(2, '0')}/'
                        '${date.year} '
                        '${date.hour.toString().padLeft(2, '0')}:'
                        '${date.minute.toString().padLeft(2, '0')}';
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: severityColor.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: severityColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.warning,
                                  color: severityColor,
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
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      machineId,
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
                                  color: severityColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  severity,
                                  style: TextStyle(
                                    color: severityColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          const Divider(),

                          const SizedBox(height: 12),

                          const Text(
                            'Description',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            description,
                            style: const TextStyle(fontSize: 15),
                          ),

                          const SizedBox(height: 15),

                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                reportedTime,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.person_outline,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  reportedBy,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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

