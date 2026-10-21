import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'admin_screen.dart';
import 'auth_screen.dart';

import 'dashboard.dart';
import 'loading_screen.dart';

class AuthGate extends StatefulWidget {
  final Duration splashDuration;

  const AuthGate({
    super.key,
    this.splashDuration = const Duration(milliseconds: 2200),
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isInitialBoot = true;

  @override
  void initState() {
    super.initState();
    _startBootTimer();
  }

  void _startBootTimer() {
    if (widget.splashDuration == Duration.zero) {
      _isInitialBoot = false;
      return;
    }

    Future.delayed(widget.splashDuration, () {
      if (mounted) {
        setState(() {
          _isInitialBoot = false;
        });
      }
    });
  }

  Widget _buildErrorScaffold({
    required BuildContext context,
    required String message,
  }) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Operator Authentication'),
        backgroundColor: AppColors.cardBg,
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.breakdownBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: AppColors.breakdown,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Profile Sync Failure',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Sign Out & Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedFlow(BuildContext context) {
    return StreamBuilder<User?>(
      key: const ValueKey('auth_stream_active'),
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoadingScreen(
            key: ValueKey('auth_state_waiting'),
          );
        }

        if (!authSnapshot.hasData) {
          return const AuthScreen(
            key: ValueKey('auth_screen_login'),
          );
        }

        final user = authSnapshot.data!;

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const CustomLoadingScreen(
                key: ValueKey('user_profile_waiting'),
                message: 'Authenticating operator credentials...',
                subMessage: 'Station Permissions Synchronizing',
              );
            }

            if (userSnapshot.hasError) {
              return _buildErrorScaffold(
                context: context,
                message: 'Failed to load user profile: ${userSnapshot.error}',
              );
            }

            // Fallback for accounts created before role support or missing documents:
            // Default to regular user role so existing accounts are never locked out.
            final userData = userSnapshot.data?.data();
            final role = userData?['role'] as String?;

            if (role == 'admin') {
              return const AdminScreen();
            }

            // Regular user or unassigned/legacy profile:
            // Route to standard DashboardScreen for backward compatibility.
            return const DashboardScreen();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: _isInitialBoot
          ? const CustomLoadingScreen(
              key: ValueKey('landing_boot_screen'),
            )
          : _buildAuthenticatedFlow(context),
    );
  }
}

