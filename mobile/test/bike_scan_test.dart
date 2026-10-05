import 'dart:async';
import 'dart:io';

import 'package:camp/features/bike_scan/controllers/bike_onboarding_controller.dart';
import 'package:camp/features/bike_scan/domain/bike_recognition_service.dart';
import 'package:camp/features/bike_scan/presentation/screens/bike_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Test doubles ─────────────────────────────────────────────────────────────

/// Returns a BMW R 1250 GS result immediately.
class _IdentifiedService extends BikeRecognitionService {
  const _IdentifiedService();
  @override
  Future<BikeRecognitionResult?> identify(File image) async {
    return const BikeRecognitionResult(
      make: 'BMW',
      model: 'R 1250 GS',
      confidence: RecognitionConfidence.high,
      displacementCc: 1254,
      bikeType: 'Adventure',
      fuelTankLiters: 20.0,
    );
  }
}

/// Always returns null (no bike detected).
class _NotIdentifiedService extends BikeRecognitionService {
  const _NotIdentifiedService();
  @override
  Future<BikeRecognitionResult?> identify(File image) async => null;
}

/// Never resolves — used to test the 8-second timeout.
class _HangingService extends BikeRecognitionService {
  const _HangingService();
  @override
  Future<BikeRecognitionResult?> identify(File image) =>
      Completer<BikeRecognitionResult?>().future;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _mockBikeDetailsBuilder(BuildContext context) => const Scaffold(
      body: Text('Bike Details Screen Mock'),
    );

/// Build the screen with no real camera and the given service.
Widget _buildScreen({
  BikeRecognitionService? service,
  String? imagePath,
  bool cameraAvailable = false,
}) {
  return MaterialApp(
    initialRoute: '/bike-scan',
    routes: {
      '/bike-scan': (context) => BikeScanScreen(
            recognitionService: service,
            cameraAvailable: cameraAvailable,
            imagePath: imagePath,
          ),
      '/bike-details': (context) => const Scaffold(
            body: Text('Bike Details Screen Mock'),
          ),
    },
  );
}

void main() {
  setUp(() => BikeOnboardingController.instance.reset());

  // ── 1. No-camera state ────────────────────────────────────────────────────
  testWidgets(
    'No-camera state shows "Enter details manually" and hides telemetry',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildScreen(service: const _NotIdentifiedService()),
      );
      await tester.pumpAndSettle();

      // Should show the manual entry button
      expect(find.text('Enter details manually'), findsOneWidget);

      // Must NOT show any of the old removed UI
      expect(find.textContaining('TELEMETRY', findRichText: true), findsNothing);
      expect(find.textContaining('RDC TIRE', findRichText: true), findsNothing);
      expect(find.textContaining('99.4%', findRichText: true), findsNothing);
      expect(find.textContaining('TPMS', findRichText: true), findsNothing);
      expect(find.textContaining('RECOMMENDED', findRichText: true), findsNothing);
      expect(find.textContaining('ISO AUTO', findRichText: true), findsNothing);
    },
  );

  // ── 2. Identified path → opens Bike Details with pre-filled values ─────────
  testWidgets(
    'Identified recognition opens Bike Details and pre-fills the controller',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Use a temporary file path to simulate a photo already taken.
      const fakePath = '/tmp/test_bike.jpg';

      await tester.pumpWidget(
        const MaterialApp(
          home: BikeScanScreen(
            recognitionService: _IdentifiedService(),
            cameraAvailable: false,
            imagePath: fakePath,
          ),
          routes: <String, WidgetBuilder>{
            '/bike-details': _mockBikeDetailsBuilder,
          },
        ),
      );

      // Let recognition complete (async but synchronous in test double).
      await tester.pumpAndSettle();

      // Banner should say identified with BMW details.
      expect(
        find.textContaining('Looks like a BMW R 1250 GS', findRichText: true),
        findsOneWidget,
      );

      // Tap Add Details button.
      final addDetailsBtn = find.text('Add Details');
      expect(addDetailsBtn, findsOneWidget);
      await tester.tap(addDetailsBtn);
      await tester.pumpAndSettle();

      // Controller should be pre-filled.
      final ctrl = BikeOnboardingController.instance;
      expect(ctrl.make, 'BMW');
      expect(ctrl.modelName, 'R 1250 GS');
      expect(ctrl.displacement, 1254);
      expect(ctrl.bikeType, 'Adventure');
      expect(ctrl.fuelTankCapacityLiters, 20.0);

      // Odometer must stay blank.
      expect(ctrl.odometerKm, isNull);
    },
  );

  // ── 3. Not-identified path → opens blank form ──────────────────────────────
  testWidgets(
    'Not-identified recognition opens Bike Details with blank form',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      const fakePath = '/tmp/test_bike2.jpg';

      await tester.pumpWidget(
        const MaterialApp(
          home: BikeScanScreen(
            recognitionService: _NotIdentifiedService(),
            cameraAvailable: false,
            imagePath: fakePath,
          ),
          routes: <String, WidgetBuilder>{
            '/bike-details': _mockBikeDetailsBuilder,
          },
        ),
      );
      await tester.pumpAndSettle();

      // Banner should show "not identified" text.
      expect(
        find.textContaining('Couldn\'t identify', findRichText: true),
        findsOneWidget,
      );

      // Add Details must be visible and tappable.
      final addDetailsBtn = find.text('Add Details');
      expect(addDetailsBtn, findsOneWidget);
      await tester.tap(addDetailsBtn);
      await tester.pumpAndSettle();

      // Controller should have blank model name and no displacement set.
      final ctrl = BikeOnboardingController.instance;
      expect(ctrl.modelName, '');
      expect(ctrl.odometerKm, isNull);
    },
  );

  // ── 4. Retake returns to live preview ─────────────────────────────────────
  testWidgets(
    'Retake button clears photo and shows shutter again',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      const fakePath = '/tmp/test_bike3.jpg';

      await tester.pumpWidget(
        const MaterialApp(
          home: BikeScanScreen(
            recognitionService: _NotIdentifiedService(),
            cameraAvailable: false,
            imagePath: fakePath,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Retake button should be visible.
      expect(find.text('Retake'), findsOneWidget);

      // Tap Retake.
      await tester.tap(find.text('Retake'));
      await tester.pumpAndSettle();

      // After retake: the "PHOTO TAKEN" pill is gone and "PHOTO" pill is shown.
      expect(find.text('PHOTO TAKEN'), findsNothing);
      expect(find.text('PHOTO'), findsOneWidget);
      // The Retake button itself is gone.
      expect(find.text('Retake'), findsNothing);
    },
  );

  // ── 5. 8-second timeout enables Add Details ───────────────────────────────
  testWidgets(
    '8-second analysis timeout triggers not-identified state and enables Add Details',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      const fakePath = '/tmp/test_bike4.jpg';

      await tester.pumpWidget(
        const MaterialApp(
          home: BikeScanScreen(
            recognitionService: _HangingService(),
            cameraAvailable: false,
            imagePath: fakePath,
          ),
        ),
      );

      // Pump a single frame — recognition is pending.
      await tester.pump();

      // During analysis, "Analyzing photo…" should appear.
      expect(find.textContaining('Analyzing', findRichText: true), findsOneWidget);

      // Fast-forward past the 8-second timeout.
      await tester.pump(const Duration(seconds: 9));

      // After timeout, should show "Couldn't identify".
      expect(
        find.textContaining('Couldn\'t identify', findRichText: true),
        findsOneWidget,
      );

      // Add Details should be enabled (no longer in "analyzing" state).
      expect(find.text('Add Details'), findsOneWidget);
    },
  );
}
