import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary: Distinctive Industrial Carbon Slate (Modern Enterprise Hardware Aesthetic)
  static const Color primary = Color(0xFF182230); // Deep Carbon Slate
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryLight = Color(0xFFF1F5F9); // Subtle cool slate tint
  static const Color accent = Color(0xFF334155); // Steel Charcoal
  static const Color indigo = Color(0xFF475569);

  // Status Colors (Refined, functional industrial tones)
  static const Color running = Color(0xFF059669); // Crisp Emerald Green
  static const Color runningLight = Color(0xFFECFDF5); // Soft mint pill
  static const Color runningBorder = Color(0xFFA7F3D0);

  static const Color breakdown = Color(0xFFDC2626); // Crisp Alert Crimson
  static const Color breakdownLight = Color(0xFFFEF2F2); // Soft red pill
  static const Color breakdownBorder = Color(0xFFFECACA);

  static const Color maintenance = Color(0xFFD97706); // Warm Ochre Amber
  static const Color maintenanceLight = Color(0xFFFFFBEB); // Soft amber pill
  static const Color maintenanceBorder = Color(0xFFFDE68A);

  static const Color pending = Color(0xFF4F46E5);
  static const Color pendingLight = Color(0xFFEEF2FF);

  // Severity Colors
  static const Color critical = Color(0xFFDC2626);
  static const Color high = Color(0xFFEA580C);
  static const Color medium = Color(0xFFD97706);
  static const Color low = Color(0xFF0D9488);

  // Clean Cool Canvas & Pure White Card Containers
  static const Color background = Color(0xFFF8FAFC); // Refined cool zinc canvas
  static const Color surface = Color(0xFFFFFFFF); // Pure white card
  static const Color cardBg = Color(0xFFFFFFFF); // Card container
  static const Color cardHover = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0); // Whisper slate border
  static const Color borderLight = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Dark carbon slate
  static const Color textSecondary = Color(0xFF64748B); // Slate grey
  static const Color textMuted = Color(0xFF94A3B8); // Muted slate

  // Sidebar & Navigation Colors
  static const Color sidebarBg = Color(0xFFFFFFFF);
  static const Color sidebarSurface = Color(0xFFF8FAFC);
  static const Color sidebarBorder = Color(0xFFE2E8F0);

  // Helper method for status color
  static Color getStatusColor(String status) {
    switch (status) {
      case 'Running':
        return running;
      case 'Breakdown':
        return breakdown;
      case 'Maintenance':
        return maintenance;
      case 'Pending Verification':
        return pending;
      default:
        return textSecondary;
    }
  }

  // Helper method for status light background
  static Color getStatusLightBg(String status) {
    switch (status) {
      case 'Running':
        return runningLight;
      case 'Breakdown':
        return breakdownLight;
      case 'Maintenance':
        return maintenanceLight;
      case 'Pending Verification':
        return pendingLight;
      default:
        return borderLight;
    }
  }

  // Helper method for severity color
  static Color getSeverityColor(String severity) {
    switch (severity) {
      case 'Critical':
        return critical;
      case 'High':
        return high;
      case 'Medium':
        return medium;
      case 'Low':
        return low;
      default:
        return textSecondary;
    }
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    const textTheme = TextTheme(
      displayLarge: TextStyle(fontFamily: 'Inter', height: 1.25, letterSpacing: -0.5),
      displayMedium: TextStyle(fontFamily: 'Inter', height: 1.25, letterSpacing: -0.5),
      displaySmall: TextStyle(fontFamily: 'Inter', height: 1.25, letterSpacing: -0.5),
      headlineLarge: TextStyle(fontFamily: 'Inter', height: 1.25, letterSpacing: -0.4),
      headlineMedium: TextStyle(fontFamily: 'Inter', height: 1.25, letterSpacing: -0.4),
      headlineSmall: TextStyle(fontFamily: 'Inter', height: 1.25, letterSpacing: -0.3),
      titleLarge: TextStyle(fontFamily: 'Inter', height: 1.3, letterSpacing: -0.3),
      titleMedium: TextStyle(fontFamily: 'Inter', height: 1.3, letterSpacing: -0.2),
      titleSmall: TextStyle(fontFamily: 'Inter', height: 1.3, letterSpacing: -0.1),
      bodyLarge: TextStyle(fontFamily: 'Inter', height: 1.35, letterSpacing: -0.1),
      bodyMedium: TextStyle(fontFamily: 'Inter', height: 1.35, letterSpacing: 0),
      bodySmall: TextStyle(fontFamily: 'Inter', height: 1.35, letterSpacing: 0),
      labelLarge: TextStyle(fontFamily: 'Inter', height: 1.3, letterSpacing: 0.1),
      labelMedium: TextStyle(fontFamily: 'Inter', height: 1.3, letterSpacing: 0.2),
      labelSmall: TextStyle(fontFamily: 'Inter', height: 1.3, letterSpacing: 0.4),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      fontFamilyFallback: const [
        '-apple-system',
        'BlinkMacSystemFont',
        'Segoe UI',
        'Roboto',
        'Helvetica',
        'Arial',
        'sans-serif',
      ],
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        error: AppColors.breakdown,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.25,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
            height: 1.25,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.breakdown),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textMuted,
          fontSize: 13.5,
          height: 1.3,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textSecondary,
          fontSize: 13.5,
          height: 1.3,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primaryLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              height: 1.25,
            );
          }
          return const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            height: 1.25,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: AppColors.textSecondary);
        }),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
