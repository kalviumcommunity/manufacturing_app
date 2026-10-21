import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/dashboard_sidebar.dart';

import '../widgets/stat_card.dart';
import 'all_breakdowns_screen.dart';
import 'all_machines_screen.dart';

import 'machine_details.dart';
import 'recurring_faults_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedItem = 'Dashboard';
  int _indexForPage(String page) {
    switch (page) {
      case 'Machines':
        return 1;
      case 'Breakdowns':
        return 2;
      case 'Settings':
        return 3;
      case 'Dashboard':
      default:
        return 0;
    }
  }

  int _navIndex() => _indexForPage(selectedItem);

  void changePage(String page) {
    if (selectedItem == page) return;
    setState(() {
      selectedItem = page;
    });
  }

  void _onNavDestinationSelected(int index) {
    switch (index) {
      case 0:
        changePage('Dashboard');
        break;
      case 1:
        changePage('Machines');
        break;
      case 2:
        changePage('Breakdowns');
        break;
      case 3:
        changePage('Settings');
        break;
    }
  }

  Widget _getCurrentPage() {
    switch (selectedItem) {
      case 'Dashboard':
        return DashboardHomeContent(
          onNavigateToMachines: () => changePage('Machines'),
          onNavigateToBreakdowns: () => changePage('Breakdowns'),
          onNavigateToSettings: () => changePage('Settings'),
          onNavigateToFaults: () => changePage('Fault Patterns'),
        );
      case 'Machines':
        return const AllMachinesScreen();
      case 'Breakdowns':
        return const AllBreakdownsScreen();

      case 'Fault Patterns':
        return const RecurringFaultsScreen();

      case 'Settings':
        return const SettingsScreen();
      default:
        return DashboardHomeContent(
          onNavigateToMachines: () => changePage('Machines'),
          onNavigateToBreakdowns: () => changePage('Breakdowns'),
          onNavigateToSettings: () => changePage('Settings'),
          onNavigateToFaults: () => changePage('Fault Patterns'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _navIndex() == 0
            ? AppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                scrolledUnderElevation: 0,
                title: Row(
                  children: [
                    // Industrial Brand Badge (Carbon Slate)
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.precision_manufacturing_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'ManufactureOS',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
                actions: [
                  // Status pill: Floor Active
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.runningLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.runningBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.running,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Floor Active',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.running,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: AppColors.textPrimary, size: 21),
                    tooltip: 'Sign Out',
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                  ),
                  const SizedBox(width: 4),
                ],
              )
            : null,
        body: _getCurrentPage(),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _navIndex(),
          onDestinationSelected: _onNavDestinationSelected,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primaryLight,
          elevation: 0,
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(Icons.precision_manufacturing_outlined),
              selectedIcon: Icon(Icons.precision_manufacturing_rounded),
              label: 'Machines',
            ),
            NavigationDestination(
              icon: Icon(Icons.warning_amber_outlined),
              selectedIcon: Icon(Icons.warning_amber_rounded, color: AppColors.breakdown),
              label: 'Breakdowns',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      );
    }

    // Tablet or Desktop
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          DashboardSidebar(
            selectedItem: selectedItem,
            isCompact: isTablet,
            onDashboardTap: () => changePage('Dashboard'),
            onMachinesTap: () => changePage('Machines'),
            onBreakdownsTap: () => changePage('Breakdowns'),
            onFaultsTap: () => changePage('Fault Patterns'),
            onSettingsTap: () => changePage('Settings'),
            onLogoutTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          Expanded(child: _getCurrentPage()),
        ],
      ),
    );
  }
}

class DashboardHomeContent extends StatelessWidget {
  final VoidCallback onNavigateToMachines;
  final VoidCallback onNavigateToBreakdowns;
  final VoidCallback onNavigateToSettings;
  final VoidCallback onNavigateToFaults;

  const DashboardHomeContent({
    super.key,
    required this.onNavigateToMachines,
    required this.onNavigateToBreakdowns,
    required this.onNavigateToSettings,
    required this.onNavigateToFaults,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? (user?.email?.split('@').first ?? 'Operator');

    return SingleChildScrollView(
      padding: Responsive.pagePadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // HERO WELCOME CARD (Clean Human Design)
              // ------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, $userName',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Main Assembly Floor · Line A & Line B active',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.precision_manufacturing_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // RECURRING FAULT ALERT STREAM
              // ------------------------------------------------
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('breakdowns')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final docs = snapshot.data!.docs;
                  final Map<String, int> machineCounts = {};
                  for (final doc in docs) {
                    final d = doc.data();
                    final id = d['machineId'] as String? ?? '';
                    if (id.isNotEmpty) {
                      machineCounts[id] = (machineCounts[id] ?? 0) + 1;
                    }
                  }
                  final recurring =
                      machineCounts.entries.where((e) => e.value >= 2).toList();
                  if (recurring.isEmpty) return const SizedBox.shrink();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade400),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber.shade900,
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Warning: ${recurring.length} Machine(s) with Recurring Faults',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Recurring breakdowns detected before shift-end review.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.brown.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: onNavigateToFaults,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('View Patterns'),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // ------------------------------------------------
              // CURRENT STATUS MICRO-HEADER
              // ------------------------------------------------
              const Text(
                'CURRENT STATUS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),

              // ------------------------------------------------
              // STREAM BUILDER FOR LIVE METRICS
              // ------------------------------------------------
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('machines').snapshots(),
                builder: (context, snapshot) {
                  final machines = snapshot.data?.docs ?? [];
                  final totalMachines = machines.length;
                  final runningMachines = machines.where((m) => (m.data()['status'] ?? '') == 'Running').length;
                  final breakdownMachines = machines.where((m) => (m.data()['status'] ?? '') == 'Breakdown').length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CLEAN STAT CARDS
                      StatCard(
                        title: 'Equipment Units',
                        value: totalMachines > 0 ? '$totalMachines Units' : '12 Units',
                        icon: Icons.precision_manufacturing_outlined,
                        subtitle: '$runningMachines active machines running',
                        onTap: onNavigateToMachines,
                      ),
                      const SizedBox(height: 12),

                      StatCard(
                        title: 'Breakdowns',
                        value: breakdownMachines > 0 ? '$breakdownMachines Active' : '0 Active',
                        icon: Icons.warning_amber_rounded,
                        subtitle: breakdownMachines > 0
                            ? '$breakdownMachines machines require repair'
                            : 'All floor units operating normally',
                        onTap: onNavigateToBreakdowns,
                      ),

                      const SizedBox(height: 20),

                      // ------------------------------------------------
                      // ACTION BUTTONS (Stacked Clean Layout)
                      // ------------------------------------------------
                      // Primary Solid Carbon Slate Button
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: onNavigateToMachines,
                          icon: const Icon(Icons.precision_manufacturing_outlined, size: 18),
                          label: const Text('View All Machines'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Secondary White Outline Buttons
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: onNavigateToMachines,
                          icon: const Icon(Icons.alt_route_rounded, size: 18),
                          label: const Text('View Production Lines'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: onNavigateToBreakdowns,
                          icon: const Icon(Icons.assignment_late_outlined, size: 18),
                          label: const Text('View Active Breakdowns'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: onNavigateToBreakdowns,
                          icon: const Icon(Icons.history_rounded, size: 18),
                          label: const Text('View Inspection & Audit Logs'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 28),

              // ------------------------------------------------
              // RECENT MACHINE ACTIVITY SECTION
              // ------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RECENT MACHINE ACTIVITY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                      height: 1.3,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Live sync',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // RECENT ACTIVITY TILES
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('machines')
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    // Default manufacturing equipment sample tiles
                    return Column(
                      children: [
                        _buildActivityTile(
                          title: 'CNC Milling Station #02',
                          subtitle: 'Line A · Stamping & Cutting · 2h ago',
                          value: 'Running',
                          statusBadge: 'Running',
                          icon: Icons.precision_manufacturing_rounded,
                          onTap: onNavigateToMachines,
                        ),
                        const SizedBox(height: 10),
                        _buildActivityTile(
                          title: 'Robotic Welder Line B',
                          subtitle: 'Line B · Automated Cell · 4h ago',
                          value: 'Running',
                          statusBadge: 'Running',
                          icon: Icons.precision_manufacturing_rounded,
                          onTap: onNavigateToMachines,
                        ),
                        const SizedBox(height: 10),
                        _buildActivityTile(
                          title: 'Conveyor Transport Unit 01',
                          subtitle: 'Assembly Section · Inspection complete',
                          value: 'Running',
                          statusBadge: 'Running',
                          icon: Icons.precision_manufacturing_rounded,
                          onTap: onNavigateToMachines,
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: docs.map((doc) {
                      final data = doc.data();
                      final name = data['name'] ?? 'Machine Unit';
                      final line = data['lineName'] ?? 'General Line';
                      final status = data['status'] ?? 'Running';
                      final id = doc.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildActivityTile(
                          title: name,
                          subtitle: '$line · Active telemetry',
                          value: status,
                          icon: Icons.precision_manufacturing_rounded,
                          statusBadge: status,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MachineDetailsScreen(
                                  machineId: id,
                                  machineName: name,
                                  lineName: line,
                                  status: status,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    String? statusBadge,
    VoidCallback? onTap,
  }) {
    return _ActivityTileItem(
      title: title,
      subtitle: subtitle,
      value: value,
      icon: icon,
      statusBadge: statusBadge,
      onTap: onTap,
    );
  }
}

class _ActivityTileItem extends StatefulWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final String? statusBadge;
  final VoidCallback? onTap;

  const _ActivityTileItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    this.statusBadge,
    this.onTap,
  });

  @override
  State<_ActivityTileItem> createState() => _ActivityTileItemState();
}

class _ActivityTileItemState extends State<_ActivityTileItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered && widget.onTap != null ? -2.5 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered && widget.onTap != null
                ? AppColors.textPrimary.withValues(alpha: 0.25)
                : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered && widget.onTap != null
                  ? Colors.black.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: _isHovered && widget.onTap != null ? 10 : 6,
              offset: Offset(0, _isHovered && widget.onTap != null ? 4 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(widget.icon, color: AppColors.textSecondary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.statusBadge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.getStatusLightBg(widget.statusBadge!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.statusBadge!,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getStatusColor(widget.statusBadge!),
                          height: 1.25,
                        ),
                      ),
                    )
                  else
                    Text(
                      widget.value,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
