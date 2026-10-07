import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/screens.dart';
import '../widgets/widgets.dart';

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

