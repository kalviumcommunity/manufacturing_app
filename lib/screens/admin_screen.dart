import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/stat_card.dart';
import 'all_machines_screen.dart';
import 'all_breakdowns_screen.dart';
import 'all_inspections_screen.dart';
import 'recurring_faults_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.pending;
      case 'user':
        return AppColors.running;
      default:
        return AppColors.maintenance;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'user':
        return 'Floor Operator';
      default:
        return 'Unassigned';
    }
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                softWrap: true,
              ),
            ],
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: 8),
          action,
        ],
      ],
    );
  }

  Widget _buildMachineOverview() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('machines').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Could not load machine statistics.');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final machines = snapshot.data?.docs ?? [];

        int countStatus(String status) {
          return machines.where((m) => (m.data()['status'] ?? '') == status).length;
        }

        final total = machines.length;
        final running = countStatus('Running');
        final breakdown = countStatus('Breakdown');
        final maintenance = countStatus('Maintenance');

        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 640;

            final totalCard = StatCard(
              title: 'Total Units',
              value: total.toString(),
              icon: Icons.precision_manufacturing_rounded,
              color: AppColors.accent,
              subtitle: 'Tap to view',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllMachinesScreen()),
                );
              },
            );

            final runningCard = StatCard(
              title: 'Running',
              value: running.toString(),
              icon: Icons.play_circle_rounded,
              color: AppColors.running,
              subtitle: 'Operating',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AllMachinesScreen(statusFilter: 'Running'),
                  ),
                );
              },
            );

            final breakdownCard = StatCard(
              title: 'Breakdown',
              value: breakdown.toString(),
              icon: Icons.warning_rounded,
              color: AppColors.breakdown,
              subtitle: 'Requires action',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AllMachinesScreen(statusFilter: 'Breakdown'),
                  ),
                );
              },
            );

            final maintenanceCard = StatCard(
              title: 'Maintenance',
              value: maintenance.toString(),
              icon: Icons.build_rounded,
              color: AppColors.maintenance,
              subtitle: 'Servicing',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AllMachinesScreen(statusFilter: 'Maintenance'),
                  ),
                );
              },
            );

            if (isNarrow) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: totalCard),
                      const SizedBox(width: 10),
                      Expanded(child: runningCard),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: breakdownCard),
                      const SizedBox(width: 10),
                      Expanded(child: maintenanceCard),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: totalCard),
                const SizedBox(width: 12),
                Expanded(child: runningCard),
                const SizedBox(width: 12),
                Expanded(child: breakdownCard),
                const SizedBox(width: 12),
                Expanded(child: maintenanceCard),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBreakdownOverview() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('breakdowns').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Could not load breakdown statistics.');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final breakdowns = snapshot.data?.docs ?? [];

        int countSeverity(String sev) {
          return breakdowns.where((b) => (b.data()['severity'] ?? '') == sev).length;
        }

        final total = breakdowns.length;
        final critical = countSeverity('Critical');
        final high = countSeverity('High');
        final medium = countSeverity('Medium');
        final low = countSeverity('Low');

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 900
                ? 5
                : width >= 540
                    ? 3
                    : width >= 340
                        ? 2
                        : 1;

            const spacing = 10.0;
            final cardWidth = (width - spacing * (columns - 1)) / columns;

            final cards = [
              StatCard(
                title: 'Total Incidents',
                value: total.toString(),
                icon: Icons.assignment_outlined,
                color: AppColors.accent,
                subtitle: 'Tap to view',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AllBreakdownsScreen()),
                  );
                },
              ),
              StatCard(
                title: 'Critical',
                value: critical.toString(),
                icon: Icons.error_outline_rounded,
                color: AppColors.critical,
                subtitle: 'Immediate',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllBreakdownsScreen(severityFilter: 'Critical'),
                    ),
                  );
                },
              ),
              StatCard(
                title: 'High',
                value: high.toString(),
                icon: Icons.priority_high_rounded,
                color: AppColors.high,
                subtitle: 'Urgent',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllBreakdownsScreen(severityFilter: 'High'),
                    ),
                  );
                },
              ),
              StatCard(
                title: 'Medium',
                value: medium.toString(),
                icon: Icons.warning_rounded,
                color: AppColors.medium,
                subtitle: 'Standard',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllBreakdownsScreen(severityFilter: 'Medium'),
                    ),
                  );
                },
              ),
              StatCard(
                title: 'Low',
                value: low.toString(),
                icon: Icons.info_outline_rounded,
                color: AppColors.low,
                subtitle: 'Minor',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllBreakdownsScreen(severityFilter: 'Low'),
                    ),
                  );
                },
              ),
            ];

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: cards
                  .map((c) => SizedBox(width: cardWidth, child: c))
                  .toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildUserManagement() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Could not load users. Check permissions.');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final allUsers = snapshot.data?.docs ?? [];

        final filteredUsers = allUsers.where((document) {
          final email = (document.data()['email'] as String? ?? '').toLowerCase();
          return email.contains(_searchQuery);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search operators or admins by email...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Showing ${filteredUsers.length} of ${allUsers.length} registered accounts',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 14),

            if (filteredUsers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No accounts match your search.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredUsers.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final data = filteredUsers[index].data();
                  final email = data['email'] as String? ?? 'No email available';
                  final role = data['role'] as String? ?? 'user';
                  final roleColor = _roleColor(role);
                  final roleLabel = _roleLabel(role);
                  final initial = email.isNotEmpty ? email[0].toUpperCase() : 'O';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.textPrimary,
                          radius: 18,
                          child: Text(
                            initial,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                roleLabel,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: TextStyle(
                              color: roleColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildAdminActionCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: AppColors.textPrimary),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'ManufactureOS Admin',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded, color: AppColors.textPrimary),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: Responsive.pagePadding(context),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // MICRO-HEADER (Matches AidGrid Image 1)
                const Text(
                  'ADMIN DASHBOARD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Welcome back, Admin',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 20),

                // 4 STACKED ACTION CARDS (Structured Human Product Layout)
                _buildAdminActionCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Machine & Equipment Inventory',
                  description: 'View, register, and configure machinery across all production lines.',
                  buttonText: 'Open Equipment',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AllMachinesScreen()),
                    );
                  },
                ),
                const SizedBox(height: 14),

                _buildAdminActionCard(
                  icon: Icons.alt_route_rounded,
                  title: 'Production Lines & Cells',
                  description: 'Monitor line capacity, workstation hubs, and operational throughput.',
                  buttonText: 'Open Production Lines',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AllMachinesScreen()),
                    );
                  },
                ),
                const SizedBox(height: 14),

                _buildAdminActionCard(
                  icon: Icons.assignment_outlined,
                  title: 'Breakdown & Work Orders',
                  description: 'Track incident tickets, technician dispatches, and active repair orders.',
                  buttonText: 'Open Work Orders',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AllBreakdownsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 14),

                _buildAdminActionCard(
                  icon: Icons.history_rounded,
                  title: 'Inspection & Incident Logs',
                  description: 'Review real-time safety audit records, shift logs, and maintenance history.',
                  buttonText: 'Open Audit Logs',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AllInspectionsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // MACHINE TELEMETRY OVERVIEW
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        icon: Icons.precision_manufacturing_rounded,
                        title: 'Machine Telemetry Overview',
                        subtitle: 'Live operational status across all units',
                      ),
                      const SizedBox(height: 16),
                      _buildMachineOverview(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // BREAKDOWN SEVERITY OVERVIEW
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        icon: Icons.warning_amber_rounded,
                        title: 'Breakdown Severity Log',
                        subtitle: 'Incident tracking by criticality level',
                      ),
                      const SizedBox(height: 16),
                      _buildBreakdownOverview(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // PREDICTIVE FAULT PATTERNS
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        icon: Icons.auto_graph_outlined,
                        title: 'Predictive Fault Pattern Intelligence',
                        subtitle: 'Analyze repeat breakdowns, high-risk machines, and line failure trends in real-time',
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Real-time Failure Pattern Analytics',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Review detected repeat breakdowns and telemetry trends across all lines.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RecurringFaultsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                              label: const Text('View Insights'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // USER & OPERATOR ACCESS SECTION
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        icon: Icons.people_outline_rounded,
                        title: 'User & Operator Access',
                        subtitle: 'Manage registered floor personnel and role permissions',
                      ),
                      const SizedBox(height: 16),
                      _buildUserManagement(),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
