import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/responsive.dart';

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
          backgroundColor: AppColors.breakdown,
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

      final existingMachine = await machineRef.get();

      if (existingMachine.exists) {
        throw Exception('A machine with ID "$machineId" already exists.');
      }

      await machineRef.set({
        'machineId': machineId,
        'machineName': machineName,
        'lineName': lineName,
        'status': _status,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Machine added successfully!'),
          backgroundColor: AppColors.running,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      String message = 'Failed to add machine.';
      if (e is FirebaseException && e.code == 'permission-denied') {
        message = 'Permission denied. Only an administrator can add machines.';
      } else if (e is Exception) {
        message = e.toString().replaceFirst('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.breakdown),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Machine'),
      ),
      body: SingleChildScrollView(
        padding: Responsive.pagePadding(context),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.add_to_photos_rounded,
                            color: AppColors.textPrimary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Register New Unit',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Add a new asset to the telemetry grid',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // MACHINE ID FIELD
                    const Text(
                      'Machine Identifier (ID)',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _machineIdController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. M-104 or CNC-02',
                        prefixIcon: Icon(Icons.tag_rounded, color: AppColors.textSecondary),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a machine ID';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // MACHINE NAME FIELD
                    const Text(
                      'Machine Name / Model',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _machineNameController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. CNC Milling Unit A',
                        prefixIcon: Icon(Icons.precision_manufacturing_rounded,
                            color: AppColors.textSecondary),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a machine name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // LINE NAME FIELD
                    const Text(
                      'Production Line Assignment',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _lineNameController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Line 1 - Stamping',
                        prefixIcon:
                            Icon(Icons.factory_rounded, color: AppColors.textSecondary),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please assign a production line';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 22),

                    // INITIAL STATUS
                    const Text(
                      'Initial Operating Status',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _statuses.map((s) {
                        final isSelected = _status == s;
                        final color = AppColors.getStatusColor(s);

                        return InkWell(
                          onTap: () => setState(() => _status = s),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? color : color.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? color : color.withValues(alpha: 0.3),
                                width: isSelected ? 1.8 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  s,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 30),

                    // SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveMachine,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_rounded, size: 20),
                        label: Text(
                          _isSaving ? 'Registering...' : 'Register Machine',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
