import 'package:camp/features/bike_scan/presentation/screens/bike_details_screen.dart';
import 'package:camp/features/garage/controllers/active_bike_controller.dart';
import 'package:camp/features/garage/domain/bike_model.dart';
import 'package:camp/features/garage/presentation/screens/bike_profile_screen.dart';
import 'package:camp/features/garage/presentation/screens/garage_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    ActiveBikeController.instance.reset();
  });

  group('ActiveBikeController Unit Tests', () {
    test('Initializes with default fleet and active bike', () {
      final controller = ActiveBikeController.instance;
      expect(controller.bikes.length, greaterThanOrEqualTo(2));
      expect(controller.activeBikeId, 'bike-bmw-1250');
      expect(controller.activeBike?.modelName, 'R 1250 GS Adventure');
      expect(controller.isActive('bike-bmw-1250'), isTrue);
      expect(controller.isActive('bike-rebel-500'), isFalse);
    });

    test('setActiveBike changes the active rig', () {
      final controller = ActiveBikeController.instance;
      controller.setActiveBike('bike-rebel-500');
      expect(controller.activeBikeId, 'bike-rebel-500');
      expect(controller.activeBike?.modelName, 'Rebel 500');
      expect(controller.isActive('bike-rebel-500'), isTrue);
      expect(controller.isActive('bike-bmw-1250'), isFalse);
    });

    test('removeBike removes the bike and reassigns active rig if needed', () {
      final controller = ActiveBikeController.instance;
      expect(controller.bikes.any((b) => b.id == 'bike-bmw-1250'), isTrue);

      controller.removeBike('bike-bmw-1250');
      expect(controller.bikes.any((b) => b.id == 'bike-bmw-1250'), isFalse);
      expect(controller.activeBikeId, 'bike-rebel-500');
      expect(controller.activeBike?.id, 'bike-rebel-500');
    });
  });

  group('BikeProfileScreen Widget Tests', () {
    testWidgets('Renders all sections, single tracking badge, and real enum values',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final testBike = ActiveBikeController.instance.activeBike!;

      await tester.pumpWidget(
        MaterialApp(
          home: BikeProfileScreen(bike: testBike),
          routes: {
            '/finances-rig-health': (context) =>
                const Scaffold(body: Text('Finances & Rig Health Page')),
          },
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header: Back button, CAMP, and ACTIVE RIG pill
      expect(find.text('CAMP'), findsOneWidget);
      expect(find.text('ACTIVE RIG'), findsOneWidget);

      // 2. Hero Card: Overline, Bike Name, single MANUALLY TRACKED badge
      expect(find.text('ACTIVE TELEMETRY RIG'), findsOneWidget);
      expect(find.text('BMW R 1250 GS Adventure'), findsOneWidget);
      expect(find.text('MANUALLY TRACKED'), findsOneWidget);

      // Verify CONTRADICTION REMOVED: NO BLE / OBD-II pill overlay
      expect(find.textContaining('BLE Paired'), findsNothing);
      expect(find.textContaining('OBD-II Live'), findsNothing);

      // 3. Specifications Card: "As Entered" header and real Fuel System enum value
      expect(find.text('SPECIFICATIONS'), findsOneWidget);
      expect(find.text('As Entered'), findsOneWidget);
      expect(find.text('Fuel Injection (EFI)'), findsOneWidget);
      expect(find.text('Electronic'), findsOneWidget);
      expect(find.text('ENGINE'), findsOneWidget);
      expect(find.text('1,254 cc'), findsOneWidget);
      expect(find.text('RIG CATEGORY'), findsOneWidget);
      expect(find.text('Adventure'), findsOneWidget);

      // 4. Maintenance Health Card
      expect(find.text('MAINTENANCE HEALTH'), findsOneWidget);
      expect(find.text('Systems Nominal'), findsOneWidget);
      expect(find.textContaining('Next scheduled service due in'), findsOneWidget);
      expect(find.text('COMPONENT DIAGNOSTICS'), findsOneWidget);
      expect(find.text('View Full Rig Diagnostics Report'), findsOneWidget);

      // 5. Riding Profile Card
      expect(find.text('RIDING PROFILE'), findsOneWidget);
      expect(find.text('Primary Riding Terrain (Configured):'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Highway'), findsOneWidget);
      expect(find.text('Off-road'), findsOneWidget);
      expect(find.text('Mountain'), findsOneWidget);

      // 6. Recent Trips Card
      expect(find.text('RECENT TRIPS (ON THIS BIKE)'), findsOneWidget);
      expect(find.text('Alpine Ridge Tour'), findsOneWidget);

      // 7. Bottom Actions: Currently Active Rig state and Remove Bike link
      expect(find.text('Edit Specifications & Tires'), findsOneWidget);
      expect(find.text('Currently Active Rig'), findsOneWidget);
      expect(find.text('Remove Bike from Garage'), findsOneWidget);
    });

    testWidgets('Shows Carburetor fuel system when bike is carbureted',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final standbyBike = ActiveBikeController.instance
          .bikes
          .firstWhere((b) => b.fuelSystem == FuelSystem.carburetor);

      await tester.pumpWidget(
        MaterialApp(
          home: BikeProfileScreen(bike: standbyBike),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('STANDBY'), findsOneWidget);
      expect(find.text('STANDBY TELEMETRY'), findsOneWidget);
      expect(find.text('Carburetor'), findsOneWidget);
      expect(find.text('Keihin CVK'), findsOneWidget);
      expect(find.text('Set as Active Rig'), findsOneWidget);
    });

    testWidgets('Set as Active Rig button updates controller',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final standbyBike = ActiveBikeController.instance
          .bikes
          .firstWhere((b) => b.id == 'bike-rebel-500');

      await tester.pumpWidget(
        MaterialApp(
          home: BikeProfileScreen(bike: standbyBike),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Set as Active Rig'), findsOneWidget);
      await tester.tap(find.text('Set as Active Rig'));
      await tester.pumpAndSettle();

      // Controller should now have bike-rebel-500 as active
      expect(ActiveBikeController.instance.activeBikeId, 'bike-rebel-500');
      expect(find.text('Currently Active Rig'), findsOneWidget);
      expect(find.text('ACTIVE RIG'), findsOneWidget);
    });

    testWidgets('Remove Bike shows confirmation dialog before deletion',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bike = ActiveBikeController.instance.activeBike!;

      await tester.pumpWidget(
        MaterialApp(
          home: BikeProfileScreen(bike: bike),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Remove Bike from Garage'));
      await tester.pumpAndSettle();

      expect(find.text('Remove Motorcycle?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Remove Bike'), findsOneWidget);

      await tester.tap(find.text('Remove Bike'));
      await tester.pumpAndSettle();

      expect(ActiveBikeController.instance.bikes.any((b) => b.id == bike.id),
          isFalse);
    });
  });

  group('GarageScreen Navigation Wiring Tests', () {
    testWidgets('Tapping bike card navigates to BikeProfileScreen',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: GarageScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BMW R 1250 GS Adventure'), findsOneWidget);

      // Tap on the bike title / card area
      await tester.tap(find.text('BMW R 1250 GS Adventure'));
      await tester.pumpAndSettle();

      // Should now be on BikeProfileScreen
      expect(find.byType(BikeProfileScreen), findsOneWidget);
      expect(find.text('As Entered'), findsOneWidget);
    });

    testWidgets('Tapping Edit directly opens BikeDetailsScreen',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: GarageScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the "Edit" button on the first card
      final editFinder = find.text('Edit');
      expect(editFinder, findsWidgets);

      await tester.tap(editFinder.first);
      await tester.pumpAndSettle();

      // Should have navigated straight to BikeDetailsScreen, bypassing BikeProfileScreen
      expect(find.byType(BikeDetailsScreen), findsOneWidget);
      expect(find.byType(BikeProfileScreen), findsNothing);
    });
  });
}
