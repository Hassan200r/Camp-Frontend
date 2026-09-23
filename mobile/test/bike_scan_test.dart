import 'package:camp/features/bike_scan/presentation/screens/bike_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BikeScanScreen renders all skeuomorphic telemetry and HUD components',
      (WidgetTester tester) async {
    // Set a phone-like viewport size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: BikeScanScreen(),
      ),
    );
    // Allow camera initialization timeout to complete
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Header & Badges
    expect(find.text('CAMP'), findsOneWidget);
    expect(find.text('BIKE SCAN'), findsOneWidget);
    expect(find.text('TELEMETRY VISION 4.2'), findsOneWidget);
    expect(find.text('ISO AUTO • 60 FPS'), findsOneWidget);

    // Verify HUD elements inside Viewport
    expect(find.text('Optical Frame Locked'), findsOneWidget);
    expect(find.text('RE-SCAN'), findsOneWidget);
    expect(find.text('Fork Sensor OK'), findsOneWidget);

    // Verify Vehicle Specs Card
    expect(find.textContaining('Auto-Detected Vehicle'), findsOneWidget);
    expect(find.text('2023 BMW R 1250 GS Adventure'), findsOneWidget);
    expect(find.text('WB10J9309PZE84102'), findsOneWidget);
    expect(find.text('14,820'), findsOneWidget);
    expect(find.text('1,254 cc'), findsOneWidget);

    // Verify Tire Telemetry
    expect(find.text('RDC TIRE TELEMETRY'), findsOneWidget);
    expect(find.text('TPMS Live'), findsOneWidget);
    expect(find.text('FRONT'), findsOneWidget);
    expect(find.text('REAR'), findsOneWidget);

    // Verify Save & Sync button
    expect(find.text('Save & Sync to Garage'), findsOneWidget);

    // Verify Next Scheduled Maintenance
    expect(find.text('NEXT SCHEDULED MAINTENANCE'), findsOneWidget);
    expect(find.text('18,000 mi • Valve Check & Fluids'), findsOneWidget);
  });

  testWidgets('Tapping RE-SCAN triggers scan animation and randomizes telemetry',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: BikeScanScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 300));

    // Find and tap RE-SCAN
    final rescanFinder = find.text('RE-SCAN');
    expect(rescanFinder, findsOneWidget);
    await tester.tap(rescanFinder);
    await tester.pump();

    // During scanning, status updates to scanning frame
    expect(find.text('Vision Scanning Frame...'), findsOneWidget);

    // Fast-forward animation past 1500ms
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 300));

    // After scan completes, variant rotated to Ducati Multistrada
    expect(find.text('2024 Ducati Multistrada V4 Rally'), findsOneWidget);
    expect(find.text('ZD12A9308PZE92811'), findsOneWidget);
    expect(find.text('8,340'), findsOneWidget);
    expect(find.text('1,158 cc'), findsOneWidget);
  });
}
