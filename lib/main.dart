import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ManufacturingApp());
}

  // ============================================================
  // APP
  // ============================================================

  class ManufacturingApp extends StatelessWidget {
    const ManufacturingApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Manufacturing Monitor',

        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        ),

       home: const AuthGate(), 
      );
    }
  }

  // ============================================================
  // DASHBOARD
  // ============================================================

  class DashboardScreen extends StatelessWidget {
    const DashboardScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Manufacturing Monitor',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              // ------------------------------------------------
              // TITLE
              // ------------------------------------------------

              const Text(
                'Production Overview',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Monitor your production lines and machine health',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // STAT CARDS
              // ------------------------------------------------

              Row(
                children: [

                  Expanded(
                    child: StatCard(
                      title: 'Machines',
                      value: '24',
                      icon: Icons.precision_manufacturing,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: StatCard(
                      title: 'Running',
                      value: '21',
                      icon: Icons.play_circle,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: StatCard(
                      title: 'Breakdowns',
                      value: '3',
                      icon: Icons.warning,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // ------------------------------------------------
              // PRODUCTION LINES
              // ------------------------------------------------

              const Text(
                'Production Lines',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              ProductionLineCard(
                lineName: 'Production Line 01',
                machines: 8,
                status: 'Running',
                statusColor: Colors.green,
              ),

              const SizedBox(height: 15),

              ProductionLineCard(
                lineName: 'Production Line 02',
                machines: 7,
                status: 'Running',
                statusColor: Colors.green,
              ),

              const SizedBox(height: 15),

              ProductionLineCard(
                lineName: 'Production Line 03',
                machines: 6,
                status: 'Running',
                statusColor: Colors.green,
              ),

              const SizedBox(height: 15),

              ProductionLineCard(
                lineName: 'Production Line 04',
                machines: 3,
                status: 'Breakdown',
                statusColor: Colors.red,
              ),

              const SizedBox(height: 35),

              // ------------------------------------------------
              // RECENT BREAKDOWNS
              // ------------------------------------------------

              const Text(
                'Recent Breakdowns',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('breakdowns')
      .orderBy('timestamp', descending: true)
      .limit(5)
      .snapshots(),

  builder: (context, snapshot) {

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
      return const Text(
        'Failed to load breakdowns',
        style: TextStyle(color: Colors.red),
      );
    }

    final breakdowns = snapshot.data?.docs ?? [];

    if (breakdowns.isEmpty) {
      return const Text(
        'No breakdowns reported yet.',
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      children: breakdowns.map((doc) {

        final data = doc.data() as Map<String, dynamic>;

        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: BreakdownCard(
            machine: data['machineName'] ?? 'Unknown Machine',
            line: 'Production Line',
            issue: data['description'] ?? 'No description',
            time: data['severity'] ?? 'Unknown severity',
          ),
        );

      }).toList(),
    );
  },
),
            ],
          ),
        ),
      );
    }
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  class StatCard extends StatelessWidget {
    final String title;
    final String value;
    final IconData icon;
    final Color color;

    const StatCard({
      super.key,
      required this.title,
      required this.value,
      required this.icon,
      required this.color,
    });

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Icon(
              icon,
              color: color,
              size: 30,
            ),

            const SizedBox(height: 15),

            Text(
              value,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }
  }

  // ============================================================
  // PRODUCTION LINE CARD
  // ============================================================

  class ProductionLineCard extends StatelessWidget {
    final String lineName;
    final int machines;
    final String status;
    final Color statusColor;

    const ProductionLineCard({
      super.key,
      required this.lineName,
      required this.machines,
      required this.status,
      required this.statusColor,
    });

    @override
    Widget build(BuildContext context) {
      return InkWell(
        borderRadius: BorderRadius.circular(15),

        onTap: () {
          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (context) => MachineListScreen(
                lineName: lineName,
              ),
            ),
          );
        },

        child: Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            children: [

              Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: const Icon(
                  Icons.factory,
                  color: Colors.blue,
                  size: 30,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(
                      lineName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '$machines machines',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  children: [

                    Container(
                      width: 8,
                      height: 8,

                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      );
    }
  }

  // ============================================================
  // MACHINE LIST SCREEN
  // ============================================================

  class MachineListScreen extends StatelessWidget {
    final String lineName;

    const MachineListScreen({
      super.key,
      required this.lineName,
    });

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(lineName),

          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),

        body: ListView(
          padding: const EdgeInsets.all(20),

          children: [

            const Text(
              'Machines',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Machines operating on $lineName',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            MachineCard(
              machineId: 'M-101',
              machineName: 'CNC Cutting Machine',
              status: 'Running',
              statusColor: Colors.green,
            ),

            const SizedBox(height: 15),

            MachineCard(
              machineId: 'M-102',
              machineName: 'Hydraulic Press',
              status: 'Running',
              statusColor: Colors.green,
            ),

            const SizedBox(height: 15),

            MachineCard(
              machineId: 'M-103',
              machineName: 'Industrial Motor',
              status: 'Breakdown',
              statusColor: Colors.red,
            ),

            const SizedBox(height: 15),

            MachineCard(
              machineId: 'M-104',
              machineName: 'Assembly Machine',
              status: 'Maintenance',
              statusColor: Colors.orange,
            ),
          ],
        ),
      );
    }
  }

  // ============================================================
  // MACHINE CARD
  // ============================================================

  class MachineCard extends StatelessWidget {
    final String machineId;
    final String machineName;
    final String status;
    final Color statusColor;

    const MachineCard({
      super.key,
      required this.machineId,
      required this.machineName,
      required this.status,
      required this.statusColor,
    });

    @override
    Widget build(BuildContext context) {
      return InkWell(
        borderRadius: BorderRadius.circular(15),

        onTap: () {
          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (context) => MachineDetailsScreen(
                machineId: machineId,
                machineName: machineName,
                status: status,
                statusColor: statusColor,
              ),
            ),
          );
        },

        child: Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            children: [

              Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Icon(
                  Icons.precision_manufacturing,
                  color: statusColor,
                  size: 30,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(
                      machineId,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      machineName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      );
    }
  }

  // ============================================================
  // MACHINE DETAILS SCREEN
  // ============================================================

  class MachineDetailsScreen extends StatelessWidget {
    final String machineId;
    final String machineName;
    final String status;
    final Color statusColor;

    const MachineDetailsScreen({
      super.key,
      required this.machineId,
      required this.machineName,
      required this.status,
      required this.statusColor,
    });

    @override
    Widget build(BuildContext context) {
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

              // Machine header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Column(
                  children: [

                    Icon(
                      Icons.precision_manufacturing,
                      size: 70,
                      color: statusColor,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      machineId,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      machineName,
                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Machine Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              InfoRow(
                title: 'Machine ID',
                value: machineId,
              ),

              InfoRow(
                title: 'Status',
                value: status,
              ),

              InfoRow(
                title: 'Last Inspection',
                value: 'Today, 09:30 AM',
              ),

              InfoRow(
                title: 'Operating Hours',
                value: '7.5 hours',
              ),

              const SizedBox(height: 25),

              // Action buttons
              // ============================================================
              // REPORT INSPECTION BUTTON
              // ============================================================

              SizedBox(
                width: double.infinity,

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

                icon: const Icon(Icons.assignment),

                    label: const Text(
                          'Report Inspection',
                           ),

                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,

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

                  label: const Text(
                    'Report Breakdown',
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  class InfoRow extends StatelessWidget {
    final String title;
    final String value;

    const InfoRow({
      super.key,
      required this.title,
      required this.value,
    });

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
        ),

        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black12,
            ),
          ),
        ),

        child: Row(
          children: [

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  // ============================================================
  // BREAKDOWN CARD
  // ============================================================

  class BreakdownCard extends StatelessWidget {
    final String machine;
    final String line;
    final String issue;
    final String time;

    const BreakdownCard({
      super.key,
      required this.machine,
      required this.line,
      required this.issue,
      required this.time,
    });

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),

          border: Border.all(
            color: Colors.red.withOpacity(0.2),
          ),
        ),

        child: Row(
          children: [

            Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),

              child: const Icon(
                Icons.warning,
                color: Colors.red,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    machine,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    line,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    issue,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              time,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
  }

  // ============================================================
// INSPECTION FORM SCREEN
// ============================================================

class InspectionFormScreen extends StatefulWidget {
  final String machineId;
  final String machineName;

  const InspectionFormScreen({
    super.key,
    required this.machineId,
    required this.machineName,
  });

  @override
  State<InspectionFormScreen> createState() =>
      _InspectionFormScreenState();
}

class _InspectionFormScreenState
    extends State<InspectionFormScreen> {

  final TextEditingController notesController =
      TextEditingController();

  String selectedCondition = 'Good';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Inspection'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // ------------------------------------------------
            // MACHINE INFORMATION
            // ------------------------------------------------

            const Text(
              'Machine',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              widget.machineName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              widget.machineId,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // MACHINE CONDITION
            // ------------------------------------------------

            const Text(
              'Machine Condition',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedCondition,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),

              items: const [
                DropdownMenuItem(
                  value: 'Good',
                  child: Text('Good'),
                ),
                DropdownMenuItem(
                  value: 'Needs Attention',
                  child: Text('Needs Attention'),
                ),
                DropdownMenuItem(
                  value: 'Critical',
                  child: Text('Critical'),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  selectedCondition = value!;
                });
              },
            ),

            const SizedBox(height: 25),

            // ------------------------------------------------
            // INSPECTION NOTES
            // ------------------------------------------------

            const Text(
              'Inspection Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: notesController,

              maxLines: 5,

              decoration: InputDecoration(
                hintText:
                    'Enter any observations or issues found...',

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),

                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // SUBMIT BUTTON
            // ------------------------------------------------

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () {

                  if (notesController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter inspection notes',
                        ),
                      ),
                    );

                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Inspection submitted successfully',
                      ),
                    ),
                  );
                },

                icon: const Icon(Icons.check),

                label: const Text(
                  'Submit Inspection',
                ),

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ============================================================
// BREAKDOWN FORM SCREEN
// ============================================================

class BreakdownFormScreen extends StatefulWidget {
  final String machineId;
  final String machineName;

  const BreakdownFormScreen({
    super.key,
    required this.machineId,
    required this.machineName,
  });

  @override
  State<BreakdownFormScreen> createState() =>
      _BreakdownFormScreenState();
}

class _BreakdownFormScreenState
    extends State<BreakdownFormScreen> {

  final TextEditingController descriptionController =
      TextEditingController();

  String selectedSeverity = 'Medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Breakdown'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // ------------------------------------------------
            // MACHINE INFORMATION
            // ------------------------------------------------

            const Text(
              'Machine',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              widget.machineName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              widget.machineId,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // SEVERITY
            // ------------------------------------------------

            const Text(
              'Breakdown Severity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedSeverity,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),

              items: const [
                DropdownMenuItem(
                  value: 'Low',
                  child: Text('Low'),
                ),
                DropdownMenuItem(
                  value: 'Medium',
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: 'High',
                  child: Text('High'),
                ),
                DropdownMenuItem(
                  value: 'Critical',
                  child: Text('Critical'),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  selectedSeverity = value!;
                });
              },
            ),

            const SizedBox(height: 25),

            // ------------------------------------------------
            // BREAKDOWN DESCRIPTION
            // ------------------------------------------------

            const Text(
              'What happened?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: descriptionController,

              maxLines: 6,

              decoration: InputDecoration(
                hintText:
                    'Describe the problem with the machine...',

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),

                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

// ============================================================
// SUBMIT BREAKDOWN
// ============================================================

SizedBox(
  width: double.infinity,

  child: ElevatedButton.icon(
    onPressed: () async {

      // Get description entered by the user
      final description =
          descriptionController.text.trim();

      // Validate description
      if (description.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please describe the breakdown',
            ),
          ),
        );

        return;
      }

      try {

        // Save breakdown to Firestore
final user = FirebaseAuth.instance.currentUser;

await FirebaseFirestore.instance
    .collection('breakdowns')
    .add({
  'machineId': widget.machineId,
  'machineName': widget.machineName,
  'severity': selectedSeverity,
  'description': description,
  'timestamp': FieldValue.serverTimestamp(),
  'reportedBy': user?.uid,
});

        // Make sure the screen still exists
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Breakdown reported successfully',
            ),
          ),
        );

      } catch (error) {

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to report breakdown: $error',
            ),
          ),
        );
      }
    },

    icon: const Icon(Icons.warning),

    label: const Text(
      'Submit Breakdown',
    ),

    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.all(16),
    ),
  ),
),
          ],
        ),
      ),
    );
  }
}
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const DashboardScreen();
        }

        return const AuthScreen();
      },
    );
  }
}
class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;

  Future<void> submitAuth() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (error) {
      String message = 'Authentication failed';

      if (error.code == 'invalid-credential') {
        message = 'Invalid email or password';
      } else if (error.code == 'email-already-in-use') {
        message = 'This email is already registered';
      } else if (error.code == 'weak-password') {
        message = 'Password is too weak';
      } else if (error.code == 'invalid-email') {
        message = 'Please enter a valid email';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manufacturing Monitor'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.factory,
                  size: 70,
                ),

                const SizedBox(height: 20),

                Text(
                  isLogin ? 'Login' : 'Create Account',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submitAuth,
                    child: Text(
                      isLoading
                          ? 'Please wait...'
                          : isLogin
                              ? 'Login'
                              : 'Sign Up',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin
                        ? 'Create a new account'
                        : 'Already have an account? Login',
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