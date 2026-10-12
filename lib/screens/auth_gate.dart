import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_screen.dart';
import 'auth_screen.dart';
import 'dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Widget _buildErrorScaffold({
    required BuildContext context,
    required String message,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authSnapshot.hasData) {
          return const AuthScreen();
        }

        final user = authSnapshot.data!;

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
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
}

