import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_screen.dart';
import 'dashboard.dart';
import 'admin_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

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

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (userSnapshot.hasError) {
              return const Scaffold(
                body: Center(child: Text('Failed to load user information.')),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text('User profile not found.')),
              );
            }

            final document = userSnapshot.data!;
            final userData = document.data() as Map<String, dynamic>;

            final role = userData['role'];

            if (role == 'admin') {
              return const AdminScreen();
            }

            if (role == 'user') {
              return const DashboardScreen();
            }

            return const Scaffold(
              body: Center(
                child: Text(
                  'Invalid or missing user role. Contact an administrator.',
                ),
              ),
            );
          },
        );
      },
    );
  }
}
