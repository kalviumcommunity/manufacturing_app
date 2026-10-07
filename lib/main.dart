import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ManufacturingApp());
}

class ManufacturingApp extends StatelessWidget {
  const ManufacturingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Manufacturing Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const AuthGate(),
    );
  }
}

// ============================================================
// DASHBOARD SIDEBAR
// ============================================================

class DashboardSidebar extends StatelessWidget {
  final String selectedItem;
  final VoidCallback onDashboardTap;
  final VoidCallback onMachinesTap;
  final VoidCallback onBreakdownsTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  const DashboardSidebar({
    super.key,
    required this.selectedItem,
    required this.onDashboardTap,
    required this.onMachinesTap,
    required this.onBreakdownsTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF111827),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
            child: const Row(
              children: [
                Icon(
                  Icons.precision_manufacturing,
                  color: Colors.blue,
                  size: 32,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Manufacturing\nMonitor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF374151), height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 25, 22, 12),
            child: Text(
              'MAIN MENU',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _SidebarItem(
            title: 'Dashboard',
            icon: Icons.dashboard_outlined,
            selected: selectedItem == 'Dashboard',
            onTap: onDashboardTap,
          ),
          _SidebarItem(
            title: 'Machines',
            icon: Icons.precision_manufacturing_outlined,
            selected: selectedItem == 'Machines',
            onTap: onMachinesTap,
          ),
          _SidebarItem(
            title: 'Breakdowns',
            icon: Icons.warning_amber_outlined,
            selected: selectedItem == 'Breakdowns',
            onTap: onBreakdownsTap,
          ),
          _SidebarItem(
            title: 'Settings',
            icon: Icons.settings_outlined,
            selected: selectedItem == 'Settings',
            onTap: onSettingsTap,
          ),
          const Spacer(),
          const Divider(color: Color(0xFF374151), height: 1),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StreamBuilder<User?>(
                        stream: FirebaseAuth.instance.authStateChanges(),
                        builder: (context, snapshot) {
                          final email = snapshot.data?.email ?? 'User';

                          return Text(
                            email,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onLogoutTap,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF4B5563)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
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

class _SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: selected ? Colors.blue.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? Colors.blue : Colors.grey.shade400,
                  size: 21,
                ),
                const SizedBox(width: 13),
                Text(
                  title,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade400,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

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
          // STAT CARDS
          // ------------------------------------------------
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('machines')
                .snapshots(),
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

              return Row(
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
              );
            },
          ),

          const SizedBox(height: 30),

          // ------------------------------------------------
          // PRODUCTION LINES
          // ------------------------------------------------
          const Text(
            'Production Lines',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('machines')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Text(
                  'Failed to load production lines',
                  style: TextStyle(color: Colors.red),
                );
              }

              final machines = snapshot.data?.docs ?? [];

              final lineNames = [
                'Production Line 01',
                'Production Line 02',
                'Production Line 03',
                'Production Line 04',
              ];

              return Column(
                children: lineNames.map((lineName) {
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
                }).toList(),
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
                      time: data['severity'] ?? 'Unknown severity',
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
// ============================================================
// STAT CARD
// ============================================================

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 18),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}

// ============================================================
// PRODUCTION LINE CARD
// ============================================================

class ProductionLineCard extends StatelessWidget {
  final String lineName;
  final int machineCount;
  final String status;
  final Color statusColor;

  const ProductionLineCard({
    super.key,
    required this.lineName,
    required this.machineCount,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MachineListScreen(lineName: lineName),
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.factory, color: Colors.blue),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lineName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$machineCount machines',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MACHINE LIST
// ============================================================

class MachineListScreen extends StatelessWidget {
  final String lineName;

  const MachineListScreen({super.key, required this.lineName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lineName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('machines')
            .where('lineName', isEqualTo: lineName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to load machines',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final machines = snapshot.data?.docs ?? [];

          if (machines.isEmpty) {
            return const Center(
              child: Text(
                'No machines found for this production line.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Machines',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Machines operating on $lineName',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 25),
              ...machines.map((machine) {
                final data = machine.data() as Map<String, dynamic>;

                final machineId = data['machineId'] ?? '';

                final machineName = data['machineName'] ?? 'Unknown Machine';

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
                  padding: const EdgeInsets.only(bottom: 15),
                  child: MachineCard(
                    machineId: machineId,
                    machineName: machineName,
                    status: status,
                    statusColor: statusColor,
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// MACHINE CARD
// ============================================================

class MachineCard extends StatelessWidget {
  final String machineId;
  final String machineName;
  final String status;
  final Color statusColor;

  const MachineCard({
    super.key,
    required this.machineId,
    required this.machineName,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MachineDetailsScreen(
              machineId: machineId,
              machineName: machineName,
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.precision_manufacturing,
                color: Colors.blue,
                size: 28,
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
                    machineId,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MACHINE DETAILS
// ============================================================

class MachineDetailsScreen extends StatelessWidget {
  final String machineId;
  final String machineName;
  final String status;

  const MachineDetailsScreen({
    super.key,
    required this.machineId,
    required this.machineName,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
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
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InspectionFormScreen(
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
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BreakdownFormScreen(
                            machineId: machineId,
                            machineName: machineName,
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
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BREAKDOWN CARD
// ============================================================

class BreakdownCard extends StatelessWidget {
  final String machine;
  final String line;
  final String issue;
  final String time;

  const BreakdownCard({
    super.key,
    required this.machine,
    required this.line,
    required this.issue,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber, color: Colors.red),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  machine,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  line,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(issue, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

// ============================================================
// INSPECTION FORM
// ============================================================

class InspectionFormScreen extends StatefulWidget {
  final String machineId;
  final String machineName;

  const InspectionFormScreen({
    super.key,
    required this.machineId,
    required this.machineName,
  });

  @override
  State<InspectionFormScreen> createState() => _InspectionFormScreenState();
}

class _InspectionFormScreenState extends State<InspectionFormScreen> {
  final TextEditingController descriptionController = TextEditingController();

  String selectedResult = 'Passed';
  bool isSubmitting = false;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> submitInspection() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('inspections').add({
        'machineId': widget.machineId,
        'machineName': widget.machineName,
        'result': selectedResult,
        'description': descriptionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'reportedBy': user?.uid,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inspection submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit inspection: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Inspection'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.machineName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(widget.machineId, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            const Text(
              'Inspection Result',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedResult,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Passed', child: Text('Passed')),
                DropdownMenuItem(value: 'Failed', child: Text('Failed')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedResult = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter inspection details',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitInspection,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Inspection'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BREAKDOWN FORM
// ============================================================

class BreakdownFormScreen extends StatefulWidget {
  final String machineId;
  final String machineName;

  const BreakdownFormScreen({
    super.key,
    required this.machineId,
    required this.machineName,
  });

  @override
  State<BreakdownFormScreen> createState() => _BreakdownFormScreenState();
}

class _BreakdownFormScreenState extends State<BreakdownFormScreen> {
  final TextEditingController descriptionController = TextEditingController();

  String selectedSeverity = 'Critical';
  bool isSubmitting = false;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> submitBreakdown() async {
    final description = descriptionController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('breakdowns').add({
        'machineId': widget.machineId,
        'machineName': widget.machineName,
        'severity': selectedSeverity,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'reportedBy': user?.uid,
      });

      await FirebaseFirestore.instance
          .collection('machines')
          .doc(widget.machineId)
          .update({
            'status': 'Breakdown',
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Breakdown submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit breakdown: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Breakdown'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.machineName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(widget.machineId, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            const Text(
              'Severity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedSeverity,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Critical', child: Text('Critical')),
                DropdownMenuItem(value: 'High', child: Text('High')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'Low', child: Text('Low')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedSeverity = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe the breakdown',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitBreakdown,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Breakdown'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// AUTH SCREEN
// ============================================================

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> authenticate() async {
    final email = emailController.text.trim();

    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        final user = credential.user;

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'uid': user.uid,
                'email': user.email,
                'createdAt': FieldValue.serverTimestamp(),
              });
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;

      if (e.code == 'user-not-found') {
        message = 'No account found';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with this email';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      } else {
        message = e.message ?? 'Authentication failed';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.precision_manufacturing,
                  color: Colors.blue,
                  size: 55,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Manufacturing Monitor',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  isLogin ? 'Login to your account' : 'Create your account',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : authenticate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isLogin ? 'Login' : 'Sign Up'),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            isLogin = !isLogin;
                          });
                        },
                  child: Text(
                    isLogin
                        ? 'Create a new account'
                        : 'Already have an account? Login',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// AUTH GATE
// ============================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const DashboardScreen();
        }

        return const AuthScreen();
      },
    );
  }
}

// ============================================================
// ALL MACHINES SCREEN
// ============================================================

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

// ============================================================
// MACHINE STATUS SUMMARY CARD
// ============================================================

class MachineStatusSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const MachineStatusSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 25),

          const SizedBox(height: 15),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}

// ============================================================
// ALL BREAKDOWNS SCREEN
// ============================================================

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

// ============================================================
// BREAKDOWN SUMMARY CARD
// ============================================================

class BreakdownSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const BreakdownSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 25),

          const SizedBox(height: 15),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
// ============================================================
// SETTINGS SCREEN
// ============================================================

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final email = user?.email ?? 'No email available';
    final uid = user?.uid ?? 'No user ID available';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your account and application settings',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // ACCOUNT
            const Text(
              'Account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.blue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Logged in as',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Divider(),

                  const SizedBox(height: 15),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.fingerprint, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'User ID',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            SelectableText(
                              uid,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // APPLICATION
            const Text(
              'Application',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Container(
              width: double.infinity,
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
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.info_outline, color: Colors.blue),
                    ),
                    title: const Text(
                      'Manufacturing Monitor',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Production monitoring application'),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.cloud_done_outlined,
                        color: Colors.green,
                      ),
                    ),
                    title: const Text(
                      'Firebase Connection',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Connected to Firebase'),
                    trailing: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // SIGN OUT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  if (!context.mounted) return;

                  Navigator.pop(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
