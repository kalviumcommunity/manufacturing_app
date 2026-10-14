import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMachineScreen extends StatefulWidget {
  const AddMachineScreen({super.key});

  @override
  State<AddMachineScreen> createState() => _AddMachineScreenState();
}

class _AddMachineScreenState extends State<AddMachineScreen> {
  final _formKey = GlobalKey<FormState>();

  final _machineIdController = TextEditingController();
  final _machineNameController = TextEditingController();
  final _lineNameController = TextEditingController();

  String _status = 'Running';
  bool _isSaving = false;

  final List<String> _statuses = ['Running', 'Breakdown', 'Maintenance'];

  @override
  void dispose() {
    _machineIdController.dispose();
    _machineNameController.dispose();
    _lineNameController.dispose();
    super.dispose();
  }

  Future<void> _saveMachine() async {
    if (!_formKey.currentState!.validate()) return;

    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in before adding a machine.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final machineId = _machineIdController.text.trim();
      final machineName = _machineNameController.text.trim();
      final lineName = _lineNameController.text.trim();

      final machineRef = FirebaseFirestore.instance
          .collection('machines')
          .doc(machineId);

      // Prevent accidentally overwriting an existing machine.
      final existingMachine = await machineRef.get();

      if (existingMachine.exists) {
        throw Exception('A machine with ID "$machineId" already exists.');
      }

      await machineRef.set({
        'machineId': machineId,
        'machineName': machineName,
        'lineName': lineName,
        'status': _status,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Machine added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      String message = 'Failed to add machine.';

      if (e is FirebaseException && e.code == 'permission-denied') {
        message = 'Permission denied. Only an admin can add machines.';
      } else if (e is Exception) {
        message = e.toString().replaceFirst('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Machine'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.precision_manufacturing,
                        size: 60,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Machine Details',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _machineIdController,
                        decoration: const InputDecoration(
                          labelText: 'Machine ID',
                          hintText: 'e.g. M-104',
                          prefixIcon: Icon(Icons.tag),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a machine ID';
                          }

                          if (value.trim().contains('/')) {
                            return 'Machine ID cannot contain "/"';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _machineNameController,
                        decoration: const InputDecoration(
                          labelText: 'Machine Name',
                          hintText: 'e.g. CNC Milling Machine',
                          prefixIcon: Icon(Icons.precision_manufacturing),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a machine name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _lineNameController,
                        decoration: const InputDecoration(
                          labelText: 'Production Line',
                          hintText: 'e.g. Line A',
                          prefixIcon: Icon(Icons.factory),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a production line';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: const InputDecoration(
                          labelText: 'Machine Status',
                          prefixIcon: Icon(Icons.settings),
                          border: OutlineInputBorder(),
                        ),
                        items: _statuses.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _status = value);
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveMachine,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add),
                        label: Text(_isSaving ? 'Saving...' : 'Add Machine'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
