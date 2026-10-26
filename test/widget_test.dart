import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manufacturing_app/screens/loading_screen.dart';
import 'package:manufacturing_app/theme/app_theme.dart';
import 'package:manufacturing_app/utils/responsive.dart';
import 'package:manufacturing_app/widgets/breakdown_summary_card.dart';
import 'package:manufacturing_app/widgets/production_line_card.dart';
import 'package:manufacturing_app/widgets/pulsing_status_badge.dart';
import 'package:manufacturing_app/screens/machine_details.dart';
import 'package:manufacturing_app/widgets/dashboard_sidebar.dart';
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

  testWidgets('BreakdownSummaryCard renders inspection summary metrics and handles selection', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BreakdownSummaryCard(
            title: 'Passed',
            value: '18',
            icon: Icons.check_circle_rounded,
            color: AppColors.running,
            isSelected: true,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Passed'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    await tester.tap(find.text('Passed'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('ProductionLineCard renders line name, machine count, and status badge', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductionLineCard(
            lineName: 'Assembly Line 1',
            machineCount: 5,
            status: 'Running',
            statusColor: AppColors.running,
          ),
        ),
      ),
    );

    expect(find.text('Assembly Line 1'), findsOneWidget);
    expect(find.text('5 Machines'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
  });

  testWidgets('DashboardSidebar renders Production Lines menu item and handles tap', (WidgetTester tester) async {
    bool linesTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardSidebar(
            selectedItem: 'Dashboard',
            onDashboardTap: () {},
            onMachinesTap: () {},
            onProductionLinesTap: () {
              linesTapped = true;
            },
            onBreakdownsTap: () {},
            onFaultsTap: () {},
            onSettingsTap: () {},
            onLogoutTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Production Lines'), findsOneWidget);
    await tester.tap(find.text('Production Lines'));
    await tester.pump();

    expect(linesTapped, isTrue);
  });

  test('MachineDetailsScreen constructor has safe defaults', () {
    const screen = MachineDetailsScreen(machineId: 'test-mach-1');
    expect(screen.machineId, 'test-mach-1');
    expect(screen.machineName, 'Machine Details');
    expect(screen.lineName, 'Production Line');
    expect(screen.status, 'Running');
  });
}
