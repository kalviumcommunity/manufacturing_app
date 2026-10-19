import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class DashboardSidebar extends StatelessWidget {
  final String selectedItem;
  final VoidCallback onDashboardTap;
  final VoidCallback onMachinesTap;
  final VoidCallback onBreakdownsTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;
  final bool isCompact;

  const DashboardSidebar({
    super.key,
    required this.selectedItem,
    required this.onDashboardTap,
    required this.onMachinesTap,
    required this.onBreakdownsTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCompact ? 76 : 260,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          right: BorderSide(color: AppColors.sidebarBorder, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER / BRAND
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 16 : 22,
              vertical: 24,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ManufactureOS',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              'EQUIPMENT NETWORK',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: AppColors.sidebarBorder, height: 1),

          if (!isCompact) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 22, 22, 10),
              child: Text(
                'MAIN MENU',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ] else
            const SizedBox(height: 16),

          // MENU ITEMS
          _SidebarItem(
            title: 'Dashboard',
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            selected: selectedItem == 'Dashboard',
            isCompact: isCompact,
            onTap: onDashboardTap,
          ),
          _SidebarItem(
            title: 'Machines',
            icon: Icons.precision_manufacturing_outlined,
            activeIcon: Icons.precision_manufacturing_rounded,
            selected: selectedItem == 'Machines',
            isCompact: isCompact,
            onTap: onMachinesTap,
          ),
          _SidebarItem(
            title: 'Breakdowns',
            icon: Icons.warning_amber_outlined,
            activeIcon: Icons.warning_amber_rounded,
            selected: selectedItem == 'Breakdowns',
            isCompact: isCompact,
            onTap: onBreakdownsTap,
          ),
          _SidebarItem(
            title: 'Settings',
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            selected: selectedItem == 'Settings',
            isCompact: isCompact,
            onTap: onSettingsTap,
          ),

          const Spacer(),
          const Divider(color: AppColors.sidebarBorder, height: 1),

          // USER PROFILE & LOGOUT
          Padding(
            padding: EdgeInsets.all(isCompact ? 12 : 18),
            child: Column(
              children: [
                StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    final email = snapshot.data?.email ?? 'Operator';
                    final initial = email.isNotEmpty ? email[0].toUpperCase() : 'O';

                    if (isCompact) {
                      return Tooltip(
                        message: email,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.sidebarSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.sidebarBorder),
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.sidebarSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.sidebarBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  email,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Authenticated',
                                  style: TextStyle(
                                    color: AppColors.running,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                if (!isCompact)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onLogoutTap,
                      icon: const Icon(Icons.logout_rounded, size: 16),
                      label: const Text('Sign Out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.breakdown,
                        side: const BorderSide(color: Color(0xFF450A0A)),
                        backgroundColor: const Color(0xFF2E0D0D).withValues(alpha: 0.3),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                else
                  IconButton(
                    tooltip: 'Sign Out',
                    onPressed: onLogoutTap,
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.breakdown,
                      size: 20,
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
  final IconData activeIcon;
  final bool selected;
  final bool isCompact;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.selected,
    required this.isCompact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final item = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 14,
        vertical: 4,
      ),
      child: Material(
        color: selected
            ? AppColors.primaryLight
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 0 : 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? AppColors.runningBorder
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  selected ? activeIcon : icon,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                        fontSize: 13.5,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (selected)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (isCompact) {
      return Tooltip(message: title, child: item);
    }
    return item;
  }
}
