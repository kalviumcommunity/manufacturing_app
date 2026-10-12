import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        return Colors.deepPurple;
      case 'user':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'user':
        return 'User';
      default:
        return 'Unassigned';
    }
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              '$count',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid(List<Widget> cards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 850
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 1;

        final spacing = 12.0;
        final cardWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map((card) => SizedBox(width: cardWidth, child: card))
              .toList(),
        );
      },
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(subtitle),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMachineOverview() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('machines').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Could not load machine statistics. '
                'Check Firestore permissions.',
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final machines = snapshot.data?.docs ?? [];

        int countStatus(String status) {
          return machines.where((machine) {
            return machine.data()['status'] == status;
          }).length;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              icon: Icons.precision_manufacturing,
              title: 'Machine Overview',
              subtitle: 'Live status of factory machines',
            ),
            _buildStatGrid([
              _buildStatCard(
                title: 'Total Machines',
                count: machines.length,
                icon: Icons.factory,
                color: Colors.blue,
              ),
              _buildStatCard(
                title: 'Running',
                count: countStatus('Running'),
                icon: Icons.play_circle_outline,
                color: Colors.green,
              ),
              _buildStatCard(
                title: 'Breakdowns',
                count: countStatus('Breakdown'),
                icon: Icons.warning_amber,
                color: Colors.red,
              ),
              _buildStatCard(
                title: 'Maintenance',
                count: countStatus('Maintenance'),
                icon: Icons.build_outlined,
                color: Colors.orange,
              ),
            ]),
          ],
        );
      },
    );
  }

  Widget _buildBreakdownOverview() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('breakdowns').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Could not load breakdown statistics. '
                'Check Firestore permissions.',
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final breakdowns = snapshot.data?.docs ?? [];

        int countSeverity(String severity) {
          return breakdowns.where((breakdown) {
            return breakdown.data()['severity'] == severity;
          }).length;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              icon: Icons.warning_amber,
              title: 'Breakdown Overview',
              subtitle: 'Reported breakdowns grouped by severity',
            ),
            _buildStatGrid([
              _buildStatCard(
                title: 'Total Reports',
                count: breakdowns.length,
                icon: Icons.assignment_outlined,
                color: Colors.blue,
              ),
              _buildStatCard(
                title: 'Critical',
                count: countSeverity('Critical'),
                icon: Icons.error_outline,
                color: Colors.red,
              ),
              _buildStatCard(
                title: 'High Severity',
                count: countSeverity('High'),
                icon: Icons.priority_high,
                color: Colors.deepOrange,
              ),
              _buildStatCard(
                title: 'Medium Severity',
                count: countSeverity('Medium'),
                icon: Icons.warning_amber,
                color: Colors.amber.shade800,
              ),
              _buildStatCard(
                title: 'Low Severity',
                count: countSeverity('Low'),
                icon: Icons.info_outline,
                color: Colors.teal,
              ),
            ]),
          ],
        );
      },
    );
  }

  Widget _buildUserManagement() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Could not load users. Check Firestore permissions.',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final allUsers = snapshot.data?.docs ?? [];

        final totalAdmins = allUsers.where((document) {
          return document.data()['role'] == 'admin';
        }).length;

        final totalRegularUsers = allUsers.where((document) {
          return document.data()['role'] == 'user';
        }).length;

        final filteredUsers = allUsers.where((document) {
          final email = (document.data()['email'] as String? ?? '')
              .toLowerCase();

          return email.contains(_searchQuery);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              icon: Icons.people_outline,
              title: 'User Management',
              subtitle: 'Search registered accounts and view roles',
            ),
            _buildStatGrid([
              _buildStatCard(
                title: 'Total Users',
                count: allUsers.length,
                icon: Icons.people_outline,
                color: Colors.blue,
              ),
              _buildStatCard(
                title: 'Admins',
                count: totalAdmins,
                icon: Icons.admin_panel_settings,
                color: Colors.deepPurple,
              ),
              _buildStatCard(
                title: 'Regular Users',
                count: totalRegularUsers,
                icon: Icons.person_outline,
                color: Colors.green,
              ),
            ]),
            const SizedBox(height: 24),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${filteredUsers.length} of ${allUsers.length} users',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            if (allUsers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No registered users found.'),
              )
            else if (filteredUsers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No users match your search.'),
              )
            else
              ...filteredUsers.map((document) {
                final data = document.data();
                final email = data['email'] as String? ?? 'No email available';
                final role = data['role'] as String? ?? 'unassigned';
                final createdAt = data['createdAt'] as Timestamp?;
                final roleColor = _roleColor(role);

                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                      leading: CircleAvatar(
                        child: Icon(
                          role == 'admin'
                              ? Icons.admin_panel_settings
                              : Icons.person_outline,
                        ),
                      ),
                      title: Text(email),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(
                              _roleLabel(role),
                              style: TextStyle(
                                color: roleColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: roleColor.withOpacity(0.12),
                            side: BorderSide(
                              color: roleColor.withOpacity(0.35),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          if (createdAt != null)
                            Text(
                              'Joined: ${createdAt.toDate().toLocal().toString().split('.').first}',
                            ),
                        ],
                      ),
                      isThreeLine: createdAt != null,
                    ),
                    const Divider(height: 1),
                  ],
                );
              }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Administration',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Manage registered users and monitor your factory.'),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildMachineOverview(),
              ),
            ),
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildBreakdownOverview(),
              ),
            ),
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildUserManagement(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
