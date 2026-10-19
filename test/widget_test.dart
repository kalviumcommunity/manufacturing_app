import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manufacturing_app/screens/loading_screen.dart';
import 'package:manufacturing_app/theme/app_theme.dart';
import 'package:manufacturing_app/utils/responsive.dart';
import 'package:manufacturing_app/widgets/pulsing_status_badge.dart';
import 'package:manufacturing_app/widgets/stat_card.dart';

void main() {
  testWidgets('PulsingStatusBadge displays status label and renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PulsingStatusBadge(status: 'Running'),
        ),
      ),
    );

    expect(find.text('Running'), findsOneWidget);
  });

  testWidgets('StatCard displays value, title, and responds to tap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatCard(
            title: 'Operating Units',
            value: '42',
            icon: Icons.precision_manufacturing,
            color: AppColors.primary,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('OPERATING UNITS'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);

    await tester.tap(find.text('OPERATING UNITS'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('CustomLoadingScreen displays brand title, message, and loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CustomLoadingScreen(
          message: 'Establishing floor telemetry...',
          subMessage: 'Live Industrial Supervision Grid',
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('ManufactureOS'), findsOneWidget);
    expect(find.byIcon(Icons.precision_manufacturing_rounded), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Establishing floor telemetry...'), findsOneWidget);
    expect(find.text('Live Industrial Supervision Grid'), findsOneWidget);
  });

  test('Responsive breakpoint logic functions correctly', () {
    expect(Responsive.mobileBreakpoint, 768);
    expect(Responsive.tabletBreakpoint, 1100);
  });
}
