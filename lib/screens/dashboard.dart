import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/screens.dart';
import '../widgets/widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedItem = 'Dashboard';

  void changePage(String page) {
    setState(() {
      selectedItem = page;
    });
  }

  Widget getCurrentPage() {
    switch (selectedItem) {
      case 'Machines':
        return const AllMachinesScreen();

      case 'Breakdowns':
        return const AllBreakdownsScreen();

      case 'Settings':
        return const SettingsScreen();

      case 'Dashboard':
      default:
        return const DashboardHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          DashboardSidebar(
            selectedItem: selectedItem,
            onDashboardTap: () {
              changePage('Dashboard');
            },
            onMachinesTap: () {
              changePage('Machines');
            },
            onBreakdownsTap: () {
              changePage('Breakdowns');
            },
            onSettingsTap: () {
              changePage('Settings');
            },
            onLogoutTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          Expanded(child: getCurrentPage()),
        ],
      ),
    );
  }
}

class DashboardHomeContent extends StatelessWidget {
  const DashboardHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------
          // TITLE
          // ------------------------------------------------
          const Text(
            'Production Overview',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Monitor your production lines and machine health',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 25),

          // ------------------------------------------------
          // MACHINES STREAM (STAT CARDS + PRODUCTION LINES)
          // ------------------------------------------------
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('machines').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Text(
                  'Failed to load machine data',
                  style: TextStyle(color: Colors.red),
                );
              }

              final machines = snapshot.data?.docs ?? [];
              final totalMachines = machines.length;

              final runningMachines = machines.where((machine) {
                final data = machine.data() as Map<String, dynamic>;
                return data['status'] == 'Running';
              }).length;

              final breakdownMachines = machines.where((machine) {
                final data = machine.data() as Map<String, dynamic>;
                return data['status'] == 'Breakdown';
              }).length;
              
              // Dynamically extract unique line names
              final lineNames = machines.map((machine) {
                final data = machine.data() as Map<String, dynamic>;
                return (data['lineName'] ?? 'Unknown Line') as String;
              }).toSet().toList()..sort();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Machines',
                          value: totalMachines.toString(),
                          icon: Icons.precision_manufacturing,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: StatCard(
                          title: 'Running',
                          value: runningMachines.toString(),
                          icon: Icons.play_circle,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: StatCard(
                          title: 'Breakdowns',
                          value: breakdownMachines.toString(),
                          icon: Icons.warning,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Production Lines',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  ...lineNames.map((lineName) {
                    final lineMachines = machines.where((machine) {
                      final data = machine.data() as Map<String, dynamic>;
                      return data['lineName'] == lineName;
                    }).toList();

                    final machineCount = lineMachines.length;
                    final breakdownCount = lineMachines.where((machine) {
                      final data = machine.data() as Map<String, dynamic>;
                      return data['status'] == 'Breakdown';
                    }).length;
                    final maintenanceCount = lineMachines.where((machine) {
                      final data = machine.data() as Map<String, dynamic>;
                      return data['status'] == 'Maintenance';
                    }).length;

                    String status;
                    Color statusColor;
                    if (breakdownCount > 0) {
                      status = 'Breakdown';
                      statusColor = Colors.red;
                    } else if (maintenanceCount > 0) {
                      status = 'Maintenance';
                      statusColor = Colors.orange;
                    } else {
                      status = 'Running';
                      statusColor = Colors.green;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: ProductionLineCard(
                        lineName: lineName,
                        machineCount: machineCount,
                        status: status,
                        statusColor: statusColor,
                      ),
                    );
                  }),
                ],
              );
            },
          ),

          const SizedBox(height: 35),

          // ------------------------------------------------
          // RECENT BREAKDOWNS
          // ------------------------------------------------
          const Text(
            'Recent Breakdowns',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('breakdowns')
                .orderBy('timestamp', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Text(
                  'Failed to load breakdowns',
                  style: TextStyle(color: Colors.red),
                );
              }

              final breakdowns = snapshot.data?.docs ?? [];

              if (breakdowns.isEmpty) {
                return const Text(
                  'No breakdowns reported yet.',
                  style: TextStyle(color: Colors.grey),
                );
              }

              return Column(
                children: breakdowns.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: BreakdownCard(
                      machine: data['machineName'] ?? 'Unknown Machine',
                      line: 'Production Line', 
                      issue: data['description'] ?? 'No description',
                      time: data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toString().split('.')[0] : 'Just now',
                      severity: data['severity'] ?? 'Unknown severity',
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
