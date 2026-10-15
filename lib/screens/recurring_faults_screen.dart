import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'machine_details.dart';

class RecurringFaultsScreen extends StatelessWidget {
  const RecurringFaultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Fault Patterns'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('breakdowns')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load breakdown patterns: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final breakdowns = snapshot.data?.docs ?? [];

          if (breakdowns.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_outlined,
                        size: 50,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Fault Patterns Detected',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'All production lines are operating without recurring breakdown patterns.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          // Group breakdowns by machineId
          final Map<String, List<Map<String, dynamic>>> machineBreakdowns = {};
          final Map<String, String> machineNames = {};
          final Map<String, String> machineLines = {};

          // Group breakdowns by lineName
          final Map<String, int> lineFaultCounts = {};

          for (final doc in breakdowns) {
            final data = doc.data();
            final machineId = (data['machineId'] as String? ?? 'unknown').trim();
            final machineName = data['machineName'] as String? ?? machineId;
            final lineName = data['lineName'] as String? ?? 'General Line';

            machineBreakdowns.putIfAbsent(machineId, () => []).add(data);
            machineNames[machineId] = machineName;
            machineLines[machineId] = lineName;

            lineFaultCounts[lineName] = (lineFaultCounts[lineName] ?? 0) + 1;
          }

          // Identify recurring fault machines (2 or more breakdowns)
          final recurringMachines = machineBreakdowns.entries
              .where((entry) => entry.value.length >= 2)
              .toList()
            ..sort((a, b) => b.value.length.compareTo(a.value.length));

          final highRiskCount =
              recurringMachines.where((m) => m.value.length >= 3).length;
          final moderateRiskCount =
              recurringMachines.where((m) => m.value.length == 2).length;

          // Find most affected line
          String worstLine = 'None';
          int maxLineFaults = 0;
          lineFaultCounts.forEach((line, count) {
            if (count > maxLineFaults) {
              maxLineFaults = count;
              worstLine = line;
            }
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Predictive Fault Intelligence',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Automated pattern detection from live breakdown logs to prevent shift-end surprises',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                const SizedBox(height: 20),

                // Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Recurring Faults',
                        value: '${recurringMachines.length}',
                        subtitle: 'Machines affected',
                        color: recurringMachines.isNotEmpty
                            ? Colors.red
                            : Colors.green,
                        icon: Icons.warning_amber_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'High Risk',
                        value: '$highRiskCount',
                        subtitle: '≥3 breakdowns',
                        color: Colors.red.shade800,
                        icon: Icons.dangerous_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Moderate Risk',
                        value: '$moderateRiskCount',
                        subtitle: '2 breakdowns',
                        color: Colors.orange,
                        icon: Icons.report_problem_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Top Affected Line',
                        value: worstLine,
                        subtitle: '$maxLineFaults total faults',
                        color: Colors.blue,
                        icon: Icons.factory_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Early Warning Banner
                if (recurringMachines.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.alarm_on, color: Colors.red, size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Shift Attention Required: Recurring Failures Detected',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${recurringMachines.length} machine(s) have logged repeated breakdown events. '
                                'Schedule proactive inspections immediately to avert unplanned shift downtime.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 25),

                // Breakdown Frequency by Line
                const Text(
                  'Fault Distribution by Production Line',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: lineFaultCounts.entries.map((entry) {
                        final ratio = breakdowns.isNotEmpty
                            ? (entry.value / breakdowns.length)
                            : 0.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${entry.value} faults (${(ratio * 100).toStringAsFixed(1)}%)',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade200,
                                  color: entry.value >= 3
                                      ? Colors.red
                                      : entry.value >= 2
                                          ? Colors.orange
                                          : Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Problematic Machines List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recurring Fault Machines',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sorted by breakdown frequency',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (recurringMachines.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No machines currently exhibit recurring breakdowns (all machines have ≤1 breakdown recorded).',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  )
                else
                  ...recurringMachines.map((entry) {
                    final machineId = entry.key;
                    final list = entry.value;
                    final name = machineNames[machineId] ?? machineId;
                    final line = machineLines[machineId] ?? 'Unknown Line';
                    final isHighRisk = list.length >= 3;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isHighRisk
                              ? Colors.red.withOpacity(0.4)
                              : Colors.orange.withOpacity(0.4),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (isHighRisk
                                            ? Colors.red
                                            : Colors.orange)
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.warning_amber_rounded,
                                    color: isHighRisk
                                        ? Colors.red
                                        : Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '$machineId • $line',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    isHighRisk ? 'HIGH RISK' : 'MODERATE RISK',
                                    style: TextStyle(
                                      color: isHighRisk
                                          ? Colors.red.shade900
                                          : Colors.orange.shade900,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  backgroundColor: (isHighRisk
                                          ? Colors.red
                                          : Colors.orange)
                                      .withOpacity(0.15),
                                  side: BorderSide.none,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Text(
                              'Reported Fault History (${list.length} events):',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...list.take(4).map((fault) {
                              final desc = fault['description'] as String? ??
                                  'No description provided';
                              final sev = fault['severity'] as String? ?? 'General';
                              final timestamp = fault['timestamp'];
                              String timeStr = 'Recently';
                              if (timestamp is Timestamp) {
                                final d = timestamp.toDate();
                                timeStr =
                                    '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: Text(
                                        '$desc ($sev)',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    Text(
                                      timeStr,
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MachineDetailsScreen(
                                        machineId: machineId,
                                        machineName: name,
                                        lineName: line,
                                        status: 'Breakdown',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.arrow_forward, size: 16),
                                label: const Text('Inspect Machine Details'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
