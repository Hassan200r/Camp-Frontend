import 'package:camp/features/garage/controllers/active_bike_controller.dart';
import 'package:camp/features/garage/domain/bike_model.dart';
import 'package:camp/features/maintenance/controllers/post_ride_report_controller.dart';
import 'package:camp/features/maintenance/domain/carburetor_guidance_table.dart';
import 'package:camp/features/maintenance/domain/maintenance_prediction_engine.dart';
import 'package:camp/features/maintenance/domain/post_ride_report.dart';
import 'package:camp/features/maintenance/presentation/screens/maintenance_screen.dart';
import 'package:camp/features/maintenance/presentation/widgets/carburetor_tab.dart';
import 'package:camp/features/maintenance/presentation/widgets/post_ride_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    ActiveBikeController.instance.reset();
    PostRideReportController.instance.reset();
  });

  group('Phase 1 & 2: PostRideReport and MaintenancePredictionEngine Unit Tests', () {
    test('PostRideReport model stores debrief data correctly', () {
      final report = PostRideReport(
        id: 'rep-test-1',
        bikeId: 'bike-bmw-1250',
        date: DateTime(2026, 10, 1),
        distanceKm: 180.5,
        terrainTags: const ['Off-road', 'Mountain'],
        notes: 'Challenging gravel pass ascent',
        flaggedIssues: 'Chain rattle on rocky steps',
      );

      expect(report.id, 'rep-test-1');
      expect(report.bikeId, 'bike-bmw-1250');
      expect(report.distanceKm, 180.5);
      expect(report.terrainTags, ['Off-road', 'Mountain']);
      expect(report.combinedNotes, 'Challenging gravel pass ascent (Chain rattle on rocky steps)');
    });

    test('PostRideReportController manages reports per bike and supports reset', () {
      final controller = PostRideReportController.instance;
      expect(controller.reports.isNotEmpty, isTrue);

      final bmwReports = controller.getReportsForBike('bike-bmw-1250');
      expect(bmwReports.length, 5);

      final custom = PostRideReport(
        id: 'rep-custom',
        bikeId: 'bike-rebel-500',
        date: DateTime.now(),
        distanceKm: 50.0,
        terrainTags: const ['City'],
      );
      controller.addReport(custom);
      expect(controller.getReportsForBike('bike-rebel-500').length, 1);

      controller.reset();
      expect(controller.getReportsForBike('bike-rebel-500').isEmpty, isTrue);
    });

    test('MaintenancePredictionEngine computes deterministic component wear and health index', () {
      final bike = ActiveBikeController.instance.activeBike!;
      final reports = PostRideReportController.instance.getReportsForBike(bike.id);

      final assessment = MaintenancePredictionEngine.analyze(
        bike: bike,
        rideReports: reports,
      );

      // Verify health index is within realistic bounds
      expect(assessment.healthIndex, greaterThan(0));
      expect(assessment.healthIndex, lessThanOrEqualTo(100));

      // Verify 4 analyzed components
      expect(assessment.components.length, 4);

      final componentIds = assessment.components.map((c) => c.id).toSet();
      expect(componentIds, containsAll(['engine-oil', 'chain-sprocket', 'air-filter', 'brake-pads']));

      // Verify wear percentages are capped 0-100
      for (final comp in assessment.components) {
        expect(comp.wearPercent, greaterThanOrEqualTo(0));
        expect(comp.wearPercent, lessThanOrEqualTo(100));
        expect(comp.reason.isNotEmpty, isTrue);
        expect(comp.diySteps.isNotEmpty, isTrue);
      }

      // Verify next service estimate
      expect(assessment.nextServiceKm, greaterThan(0));
      expect(assessment.nextServiceDays, greaterThan(0));
    });

    test('Engine Oil interval is reduced by 15% when terrain contains Off-road or Mountain', () {
      const offRoadBike = Bike(
        id: 'bike-offroad',
        make: 'KTM',
        modelName: '890 Adventure R',
        modelYear: 2023,
        odometerKm: 8000,
        ridingTerrain: ['Off-road', 'Mountain'],
        lastOilChange: ServiceRecord(km: 2000),
      );

      const highwayBike = Bike(
        id: 'bike-highway',
        make: 'Honda',
        modelName: 'Gold Wing',
        modelYear: 2023,
        odometerKm: 8000,
        ridingTerrain: ['Highway'],
        lastOilChange: ServiceRecord(km: 2000),
      );

      final assessmentOffRoad = MaintenancePredictionEngine.analyze(
        bike: offRoadBike,
        rideReports: [],
      );
      final assessmentHighway = MaintenancePredictionEngine.analyze(
        bike: highwayBike,
        rideReports: [],
      );

      final oilOffRoad = assessmentOffRoad.components.firstWhere((c) => c.id == 'engine-oil');
      final oilHighway = assessmentHighway.components.firstWhere((c) => c.id == 'engine-oil');

      // Effective interval for off-road is 4,250 km (5000 * 0.85). 2000 / 4250 = ~47%
      // Effective interval for highway is 5,000 km. 2000 / 5000 = 40%
      expect(oilOffRoad.wearPercent, greaterThan(oilHighway.wearPercent));
      expect(oilOffRoad.reason, contains('reduced by 15%'));
    });

    test('Phase 3: Computes honest percentage from logged PostRideReports', () {
      final bike = ActiveBikeController.instance.activeBike!;
      final reports = PostRideReportController.instance.getReportsForBike(bike.id);

      // Default reports for BMW: 5 rides, 3 off-road (60%), 2 mountain (40%)
      final assessment = MaintenancePredictionEngine.analyze(
        bike: bike,
        rideReports: reports,
      );

      expect(assessment.hasSufficientRideLogs, isTrue);
      expect(assessment.patternInsights.isNotEmpty, isTrue);

      final chainInsight = assessment.patternInsights.firstWhere(
        (i) => i.title == 'Chain Wear Accelerating',
      );
      expect(chainInsight.percentageBadge, '60% Off-Road');
      expect(chainInsight.description, contains('3 of your last 5'));
    });

    test('Phase 3: Returns empty pattern insights when fewer than 3 reports exist', () {
      final bike = ActiveBikeController.instance.activeBike!;
      final assessment = MaintenancePredictionEngine.analyze(
        bike: bike,
        rideReports: [
          PostRideReport(
            id: 'one-rep',
            bikeId: bike.id,
            date: DateTime.now(),
            distanceKm: 100,
            terrainTags: const ['Off-road'],
          ),
        ],
      );

      expect(assessment.hasSufficientRideLogs, isFalse);
      expect(assessment.patternInsights.isEmpty, isTrue);
    });
  });

  group('Phase 4: MaintenanceScreen Widget Tests', () {
    testWidgets('Renders all header, health index, components, and insights matching design',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: const MaintenanceScreen(),
          routes: {
            '/finance-rig-health': (context) =>
                const Scaffold(body: Text('Finance Rig Health Destination')),
          },
        ),
      );
      await tester.pumpAndSettle();

      // 1. App Bar
      expect(find.text('CAMP'), findsWidgets);
      expect(find.text('• MAINTENANCE'), findsOneWidget);

      // 2. Bike context header (No OBD-II or hardware sensor language)
      expect(find.text('BMW R 1250 GS Adventure'), findsOneWidget);
      expect(find.textContaining('Last updated'), findsOneWidget);
      expect(find.textContaining('OBD-II'), findsNothing);
      expect(find.textContaining('Telemetry updated'), findsNothing);

      // 3. Tab Selector
      expect(find.text('Diagnostics'), findsOneWidget);
      expect(find.text('Pre-Ride'), findsOneWidget);
      expect(find.text('Post-Ride'), findsOneWidget);

      // 4. Maintenance Health Index (no "Telemetry Health Index", no "ECU Status", no "Pass Ready")
      expect(find.text('MAINTENANCE HEALTH INDEX'), findsOneWidget);
      expect(find.text('TELEMETRY HEALTH INDEX'), findsNothing);
      expect(find.textContaining('ECU Status'), findsNothing);
      expect(find.textContaining('Pass Ready'), findsNothing);
      expect(find.textContaining('Next service in'), findsOneWidget);

      // 5. Component Analysis & Wear (no critical limit in mm)
      expect(find.text('COMPONENT ANALYSIS & WEAR'), findsOneWidget);
      expect(find.text('Drive Chain & Sprocket'), findsOneWidget);
      expect(find.text('Engine Oil & Filter'), findsOneWidget);
      expect(find.text('Air Filter Element'), findsOneWidget);
      expect(find.text('Front Brake Pads'), findsOneWidget);
      expect(find.text('View DIY Guide >'), findsNWidgets(4));
      expect(find.textContaining('Critical limit:'), findsNothing);
      expect(find.textContaining('Min safe spec:'), findsNothing);

      // 6. CAMP Predictive Intelligence
      expect(find.text('CAMP PREDICTIVE INTELLIGENCE'), findsOneWidget);
      expect(find.text('Chain Wear Accelerating'), findsOneWidget);
      expect(find.text('60% Off-Road'), findsOneWidget);

      // 7. Finances & Rig Health Banner
      expect(
        find.textContaining('Estimated replacement parts costs and lifecycle budgets are managed separately in Finances & Rig Health.'),
        findsOneWidget,
      );
      expect(find.text('View →'), findsOneWidget);
    });

    testWidgets('Tapping View DIY Guide opens bottom sheet modal',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: MaintenanceScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('View DIY Guide >').first);
      await tester.pumpAndSettle();

      expect(find.textContaining('CAMP Field Service Guide'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Dismiss modal
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsNothing);
    });

    testWidgets('Pre-Ride tab supports checking items and Start Ride action',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: MaintenanceScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Pre-Ride tab
      await tester.tap(find.text('Pre-Ride'));
      await tester.pumpAndSettle();

      expect(find.text('PRE-RIDE SAFETY AUDIT'), findsOneWidget);
      expect(find.text('0 of 7 Done'), findsOneWidget);

      // Tap first checkpoint
      await tester.tap(find.text('Tire Pressures & Tread Inspection'));
      await tester.pumpAndSettle();
      expect(find.text('1 of 7 Done'), findsOneWidget);

      // Tap Start Ride button
      await tester.tap(find.text('Start Ride'));
      await tester.pump();
      expect(find.textContaining('items checked'), findsOneWidget);
    });

    testWidgets('Post-Ride tab allows entering debrief and saving report',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: MaintenanceScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Post-Ride tab
      await tester.tap(find.text('Post-Ride'));
      await tester.pumpAndSettle();

      expect(find.text('LOG POST-RIDE REPORT'), findsOneWidget);
      expect(find.text('EXPEDITION LOG HISTORY (5)'), findsOneWidget);

      // Enter distance
      await tester.enterText(find.byType(TextField).first, '120');
      await tester.pumpAndSettle();

      // Tap Save Post-Ride Report
      await tester.tap(find.text('Save Post-Ride Report'));
      await tester.pumpAndSettle();

      expect(find.text('EXPEDITION LOG HISTORY (6)'), findsOneWidget);
      expect(find.text('120 km'), findsOneWidget);
    });

    testWidgets('Carburetor tab renders for carburetor bikes with manual altitude calibration',
        (WidgetTester tester) async {
      // Set active bike to Honda Rebel 500 (carburetor)
      ActiveBikeController.instance.setActiveBike('bike-rebel-500');

      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: MaintenanceScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Carburetor tab appears
      expect(find.text('Carburetor'), findsOneWidget);

      // Switch to Carburetor tab
      await tester.tap(find.text('Carburetor'));
      await tester.pumpAndSettle();

      // Updated strings matching the new CarburetorTab layout
      expect(find.text('CARBURETOR SPECIFICATION'), findsOneWidget);
      expect(find.text('JETTING LOG'), findsOneWidget);
      expect(find.text('CURRENT ALTITUDE'), findsOneWidget);
      expect(find.text('Guidance only'), findsWidgets);
      // Empty state: no baseline altitude entered yet
      expect(find.text('Set your baseline altitude first.'), findsOneWidget);
    });
  });

  // ── Part 1: Oil formula edge-case unit tests ───────────────────────────────
  group('Oil formula: km-limited, days-limited, terrain-shortened', () {
    // Effective km interval flat: 5,000 km; terrain: 5,000 × 0.85 = 4,250 km.
    // Effective day interval flat: 90 d;   terrain: 90 × 0.85 = 76 d.

    test('km-limited: wear is driven by km when days is zero (no date recorded)', () {
      // 4,000 km since last change / 5,000 km interval = 80% → overdue
      const bike = Bike(
        id: 'test-km',
        make: 'Honda',
        modelName: 'CB500F',
        modelYear: 2022,
        odometerKm: 10000,
        ridingTerrain: ['Highway'], // no off-road / mountain
        lastOilChange: ServiceRecord(km: 4000), // 4,000 km since change, no date
      );

      final assessment = MaintenancePredictionEngine.analyze(
        bike: bike,
        rideReports: [],
      );
      final oil = assessment.components.firstWhere((c) => c.id == 'engine-oil');

      // 4000 / 5000 = 80% → exactly at overdue threshold
      expect(oil.wearPercent, equals(80));
      expect(oil.status, equals(ComponentStatus.overdue));
      // Reason must not mention terrain reduction
      expect(oil.reason, isNot(contains('reduced by 15%')));
    });

    test('days-limited: wear is driven by days when days > km wear', () {
      // 500 km since change / 5,000 km = 10% km-wear
      // 89 days since change / 90 d  ≈ 98% days-wear  → days wins
      final lastChangeDate = DateTime.now().subtract(const Duration(days: 89));
      final bike = Bike(
        id: 'test-days',
        make: 'Yamaha',
        modelName: 'MT-07',
        modelYear: 2023,
        odometerKm: 5500,
        ridingTerrain: const ['City'],
        lastOilChange: ServiceRecord(
          mode: TrackingMode.byDate,
          km: 500,
          date: lastChangeDate,
        ),
      );

      final assessment = MaintenancePredictionEngine.analyze(
        bike: bike,
        rideReports: [],
      );
      final oil = assessment.components.firstWhere((c) => c.id == 'engine-oil');

      // 89 / 90 ≈ 98.9% → rounds to 99; km wear is only 10%
      // wear = max(10, 99) = 99
      expect(oil.wearPercent, greaterThan(90));
      expect(oil.status, equals(ComponentStatus.overdue));
    });

    test('terrain-shortened: Off-road bike has higher wear % than highway bike at same km', () {
      // Already validated in Phase 1 group but this adds explicit value checks.
      // Off-road effective interval = 4,250 km; highway = 5,000 km.
      // Both bikes: 3,000 km since last change.
      const offRoadBike = Bike(
        id: 'terrain-off',
        make: 'KTM',
        modelName: '690 Enduro R',
        modelYear: 2024,
        odometerKm: 7000,
        ridingTerrain: ['Off-road'],
        lastOilChange: ServiceRecord(km: 3000),
      );
      const highwayBike = Bike(
        id: 'terrain-hi',
        make: 'BMW',
        modelName: 'R1250RT',
        modelYear: 2024,
        odometerKm: 7000,
        ridingTerrain: ['Highway'],
        lastOilChange: ServiceRecord(km: 3000),
      );

      final offRoadOil = MaintenancePredictionEngine.analyze(
        bike: offRoadBike,
        rideReports: [],
      ).components.firstWhere((c) => c.id == 'engine-oil');

      final highwayOil = MaintenancePredictionEngine.analyze(
        bike: highwayBike,
        rideReports: [],
      ).components.firstWhere((c) => c.id == 'engine-oil');

      // Off-road: 3000/4250 ≈ 70.6% → 71
      // Highway:  3000/5000 = 60%
      expect(offRoadOil.wearPercent, equals(71));
      expect(highwayOil.wearPercent, equals(60));
      expect(offRoadOil.wearPercent, greaterThan(highwayOil.wearPercent));
      expect(offRoadOil.reason, contains('reduced by 15%'));
      expect(highwayOil.reason, isNot(contains('reduced by 15%')));
    });

    test('Mountain terrain also triggers 15% interval reduction', () {
      const mountainBike = Bike(
        id: 'terrain-mount',
        make: 'Triumph',
        modelName: 'Tiger 900',
        modelYear: 2024,
        odometerKm: 5000,
        ridingTerrain: ['Mountain'],
        lastOilChange: ServiceRecord(km: 3000),
      );

      final oil = MaintenancePredictionEngine.analyze(
        bike: mountainBike,
        rideReports: [],
      ).components.firstWhere((c) => c.id == 'engine-oil');

      // 3000 / 4250 ≈ 70.6% → 71
      expect(oil.wearPercent, equals(71));
      expect(oil.reason, contains('reduced by 15%'));
    });
  });

  // ── Part 2: Altitude density ratio unit tests ──────────────────────────────
  group('Altitude density ratio: US Standard Atmosphere 1976 formula', () {
    test('Sea level (0 m) returns density ratio of exactly 1.0', () {
      expect(atmosphericDensityRatio(0), closeTo(1.0, 0.0001));
    });

    test('1,000 m vs sea level gives ~0.91 density ratio', () {
      // Expected: (1 - 2.25577e-5 * 1000)^4.25588 ≈ 0.9075
      final ratio = altitudeDensityRatio(1000, 0);
      expect(ratio, closeTo(0.907, 0.005));
    });

    test('2,000 m vs sea level gives ~0.82 density ratio', () {
      // Expected: ≈ 0.8216
      final ratio = altitudeDensityRatio(2000, 0);
      expect(ratio, closeTo(0.822, 0.005));
    });

    test('1,500 m vs sea level gives ~0.86 density ratio', () {
      // Expected: (1 - 2.25577e-5 * 1500)^4.25588 ≈ 0.8637
      final ratio = altitudeDensityRatio(1500, 0);
      expect(ratio, closeTo(0.864, 0.005));
    });

    test('3,000 m vs sea level gives ~0.74 density ratio', () {
      // Expected: ≈ 0.7423
      final ratio = altitudeDensityRatio(3000, 0);
      expect(ratio, closeTo(0.742, 0.005));
    });

    test('Same altitude as baseline always gives ratio of 1.0', () {
      expect(altitudeDensityRatio(1500, 1500), closeTo(1.0, 0.0001));
      expect(altitudeDensityRatio(3000, 3000), closeTo(1.0, 0.0001));
    });

    test('Lower altitude than baseline gives ratio > 1.0 (denser air)', () {
      // At sea level vs 1000 m baseline: denser, ratio > 1
      expect(altitudeDensityRatio(0, 1000), greaterThan(1.0));
    });
  });

  // ── Part 2: Guidance band boundary tests in both directions ──────────────
  group('Guidance band lookup covers all boundaries in both directions', () {
    test('Thinner air boundaries (ratio <= 1.0)', () {
      // < 5% change: minimal
      expect(densityBand(1.0), equals(DensityBand.minimal));
      expect(densityBand(0.951), equals(DensityBand.minimal));

      // 5% to 10% change: slight
      expect(densityBand(0.950), equals(DensityBand.slight));
      expect(densityBand(0.901), equals(DensityBand.slight));

      // 10% to 20% change: noticeable
      expect(densityBand(0.900), equals(DensityBand.noticeable));
      expect(densityBand(0.801), equals(DensityBand.noticeable));

      // >= 20% change: significant
      expect(densityBand(0.800), equals(DensityBand.significant));
      expect(densityBand(0.700), equals(DensityBand.significant));
    });

    test('Denser air boundaries (ratio >= 1.0)', () {
      // < 5% change: minimal
      expect(densityBand(1.000), equals(DensityBand.minimal));
      expect(densityBand(1.049), equals(DensityBand.minimal));

      // 5% to 10% change: slight
      expect(densityBand(1.050), equals(DensityBand.slight));
      expect(densityBand(1.099), equals(DensityBand.slight));

      // 10% to 20% change: noticeable
      expect(densityBand(1.100), equals(DensityBand.noticeable));
      expect(densityBand(1.199), equals(DensityBand.noticeable));

      // >= 20% change: significant
      expect(densityBand(1.200), equals(DensityBand.significant));
      expect(densityBand(1.282), equals(DensityBand.significant));
    });

    test('parseCarbType correctly identifies slide, CV and other carb types', () {
      expect(parseCarbType('Mikuni VM34 slide'), equals(CarbType.slide));
      expect(parseCarbType('Keihin CVK36'), equals(CarbType.cv));
      expect(parseCarbType('Mikuni BST33 CV'), equals(CarbType.cv));
      expect(parseCarbType(null), equals(CarbType.other));
      expect(parseCarbType('Unknown carb'), equals(CarbType.other));
    });
  });

  // ── Direction-aware carburetor guidance (safety tests) ────────────────────
  group('Direction-aware carburetor guidance (safety & lean-risk tests)', () {
    test('Baseline 3,000m with current 500m (ratio ~1.28) must NOT return minimal / no-adjustment', () {
      final ratio = altitudeDensityRatio(500, 3000);
      // Ratio should be approx 1.28 (denser air, descended from 3000m to 500m)
      expect(ratio, closeTo(1.28, 0.02));

      final band = densityBand(ratio);
      expect(band, isNot(equals(DensityBand.minimal)));
      expect(band, equals(DensityBand.significant));

      final text = jetingGuidanceText(band, CarbType.slide, densityRatio: ratio);
      // Must NOT claim no adjustment needed
      expect(text, isNot(contains('no adjustment needed')));

      // Must display prominent lean-risk warning
      expect(text, contains(leanRunningRiskWarning));
      expect(text, contains('LEAN-RISK WARNING'));
      expect(text, contains('CRITICAL RISK'));
      expect(text, contains(returnToBaselineWarning));
      expect(text, contains('TODO'));
    });

    test('Baseline 500m with current 500m returns minimal and confirms baseline match', () {
      final ratio = altitudeDensityRatio(500, 500);
      expect(ratio, closeTo(1.0, 0.0001));

      final band = densityBand(ratio);
      expect(band, equals(DensityBand.minimal));

      final text = jetingGuidanceText(band, CarbType.cv, densityRatio: ratio);
      expect(text, contains('Carburetor jetting likely matches this altitude — no adjustment needed.'));
      expect(text, contains(returnToBaselineWarning));
      expect(text, contains('TODO'));
    });

    test('Baseline 500m with current 3,000m returns thinner-air / rich-running result', () {
      final ratio = altitudeDensityRatio(3000, 500);
      // Ratio is approx 0.779 (< 0.80)
      expect(ratio, closeTo(0.779, 0.01));

      final band = densityBand(ratio);
      expect(band, equals(DensityBand.significant));

      final text = jetingGuidanceText(band, CarbType.slide, densityRatio: ratio);
      // Must NOT show the lean-risk warning (because air is thinner, not denser)
      expect(text, isNot(contains('LEAN-RISK WARNING')));
      expect(text, contains('Air density has dropped over 20%'));
      expect(text, contains('run very rich'));
      expect(text, contains(returnToBaselineWarning));
      expect(text, contains('TODO'));
    });

    test('All guidance recommendations in both directions contain returnToBaselineWarning', () {
      // Test thinner-air (ratio < 1)
      for (final band in DensityBand.values) {
        for (final carb in CarbType.values) {
          final richText = jetingGuidanceText(band, carb, densityRatio: 0.75);
          expect(richText, contains(returnToBaselineWarning));
          expect(richText, contains('⚠️'));
          expect(richText, contains('TODO'));

          final leanText = jetingGuidanceText(band, carb, densityRatio: 1.25);
          expect(leanText, contains(returnToBaselineWarning));
          expect(leanText, contains('⚠️'));
          expect(leanText, contains('TODO'));
        }
      }
    });

    test('All denser-air conditions beyond 5% contain the exact lean-risk warning', () {
      final bands = [DensityBand.slight, DensityBand.noticeable, DensityBand.significant];
      for (final band in bands) {
        for (final carb in CarbType.values) {
          final text = jetingGuidanceText(band, carb, densityRatio: 1.15);
          expect(text, contains(leanRunningRiskWarning));
        }
      }
    });

    test('returnToBaselineWarning constant mentions lean and baseline', () {
      expect(returnToBaselineWarning, contains('baseline'));
      expect(returnToBaselineWarning, contains('lean'));
    });
  });

  // ── Tab State Preservation Widget Tests ───────────────────────────────────
  group('Tab state preservation when switching tabs in MaintenanceScreen', () {
    testWidgets('Checklist ticks, jetting log entries and post-ride form keep state when switching tabs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Set active bike to carburetor bike
      const carbBike = Bike(
        id: 'test-carb-bike',
        make: 'Honda',
        modelName: 'XR650L',
        modelYear: 2021,
        odometerKm: 12000,
        ridingTerrain: ['Off-road', 'Mountain'],
        fuelSystem: FuelSystem.carburetor,
        carburetorType: 'Keihin CVK40',
      );
      ActiveBikeController.instance.addBike(carbBike);
      ActiveBikeController.instance.setActiveBike(carbBike.id);
      addTearDown(() {
        ActiveBikeController.instance.removeBike(carbBike.id);
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: MaintenanceScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Switch to Carburetor tab (index 1) and enter baseline altitude
      await tester.tap(find.text('Carburetor'));
      await tester.pumpAndSettle();

      final baselineFinder = find.descendant(
        of: find.byType(CarburetorTab),
        matching: find.byType(TextField),
      ).first;
      await tester.enterText(baselineFinder, '1850');
      await tester.pumpAndSettle();
      expect(find.text('1850'), findsOneWidget);

      // 2. Switch to Pre-Ride tab (index 2) and check an item
      await tester.tap(find.text('Pre-Ride'));
      await tester.pumpAndSettle();

      // Pre-ride audit should start with 0 of 7 Done
      expect(find.text('0 of 7 Done'), findsOneWidget);

      // Tap first checkbox item
      await tester.tap(find.text('Tire Pressures & Tread Inspection'));
      await tester.pumpAndSettle();
      expect(find.text('1 of 7 Done'), findsOneWidget);

      // 3. Switch to Post-Ride tab (index 3) and enter distance
      await tester.tap(find.text('Post-Ride'));
      await tester.pumpAndSettle();

      final distanceFinder = find.descendant(
        of: find.byType(PostRideTab),
        matching: find.byType(TextField),
      ).first;
      await tester.enterText(distanceFinder, '145.5');
      await tester.pumpAndSettle();
      expect(find.text('145.5'), findsOneWidget);

      // 4. Switch back to Diagnostics tab (index 0)
      await tester.tap(find.text('Diagnostics'));
      await tester.pumpAndSettle();
      expect(find.text('MAINTENANCE HEALTH INDEX'), findsOneWidget);

      // 5. Switch back to Carburetor tab — baseline altitude '1850' must STILL be there!
      await tester.tap(find.text('Carburetor'));
      await tester.pumpAndSettle();
      expect(find.text('1850'), findsOneWidget);

      // 6. Switch back to Pre-Ride tab — '1 of 7 Done' must STILL be there!
      await tester.tap(find.text('Pre-Ride'));
      await tester.pumpAndSettle();
      expect(find.text('1 of 7 Done'), findsOneWidget);

      // 7. Switch back to Post-Ride tab — '145.5' distance must STILL be there!
      await tester.tap(find.text('Post-Ride'));
      await tester.pumpAndSettle();
      expect(find.text('145.5'), findsOneWidget);
    });
  });
}
