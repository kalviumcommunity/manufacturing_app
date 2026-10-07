import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/screens.dart';
import '../widgets/widgets.dart';

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

