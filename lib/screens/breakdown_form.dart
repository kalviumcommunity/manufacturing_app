import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class BreakdownFormScreen extends StatefulWidget {
  final String machineId;
  final String machineName;
  final String lineName;

  const BreakdownFormScreen({
    super.key,
    required this.machineId,
    required this.machineName,
    required this.lineName,
  });

  @override
  State<BreakdownFormScreen> createState() => _BreakdownFormScreenState();
}

class _BreakdownFormScreenState extends State<BreakdownFormScreen> {
  final TextEditingController descriptionController = TextEditingController();
  String selectedSeverity = 'Critical';
  bool isSubmitting = false;

  final List<String> severities = ['Critical', 'High', 'Medium', 'Low'];

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> submitBreakdown() async {
    final description = descriptionController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an issue description.'),
          backgroundColor: AppColors.breakdown,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('breakdowns').add({
        'machineId': widget.machineId,
        'machineName': widget.machineName,
        'lineName': widget.lineName,
        'severity': selectedSeverity,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'reportedBy': user?.uid,
      });

      final machineDocs = await FirebaseFirestore.instance
          .collection('machines')
          .where('machineId', isEqualTo: widget.machineId)
          .limit(1)
          .get();

      if (machineDocs.docs.isNotEmpty) {
        await machineDocs.docs.first.reference.update({
          'status': 'Breakdown',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseFirestore.instance
            .collection('machines')
            .doc(widget.machineId)
            .update({
          'status': 'Breakdown',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Breakdown incident reported successfully!'),
          backgroundColor: AppColors.running,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit breakdown: $e'),
          backgroundColor: AppColors.breakdown,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Report Breakdown'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MACHINE INFO HEADER
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.breakdownLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.breakdown,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.machineName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${widget.machineId} • Line: ${widget.lineName}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // SEVERITY SELECTOR
                  const Text(
                    'Incident Severity Level',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Select the critical tier for maintenance escalation:',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: severities.map((sev) {
                      final isSelected = selectedSeverity == sev;
                      final sevColor = AppColors.getSeverityColor(sev);

                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedSeverity = sev;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? sevColor
                                : sevColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? sevColor
                                  : sevColor.withValues(alpha: 0.3),
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                size: 16,
                                color: isSelected ? Colors.white : sevColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                sev,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : sevColor,
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

                  const SizedBox(height: 24),

                  // DESCRIPTION
                  const Text(
                    'Detailed Issue Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    maxLines: 5,
                    maxLength: 1000,
                    decoration: const InputDecoration(
                      hintText:
                          'Describe what failed, any unusual noises, error codes, or physical damage...',
                      alignLabelWithHint: true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isSubmitting ? null : submitBreakdown,
                      icon: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        isSubmitting ? 'Submitting Report...' : 'Submit Incident Report',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.breakdown,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
