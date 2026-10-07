import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/screens.dart';
import '../widgets/widgets.dart';

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

