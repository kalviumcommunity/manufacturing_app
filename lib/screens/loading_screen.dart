import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomLoadingScreen extends StatelessWidget {
  final String? message;
  final String? subMessage;

  const CustomLoadingScreen({
    super.key,
    this.message,
    this.subMessage,
  });

  @override
  Widget build(BuildContext context) {
    final displayMessage = message ?? 'Loading equipment telemetry...';
    final displaySub = subMessage ?? 'Industrial Machine & Telemetry Grid';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Industrial Brand Badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.precision_manufacturing_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Brand Title
              const Text(
                'ManufactureOS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 6),

              // Subtitle
              Text(
                displaySub,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 32),

              // Clean Product Circular Loader
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),

              const SizedBox(height: 16),

              // Subtle Status Message
              Text(
                displayMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
