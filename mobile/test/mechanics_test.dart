import 'dart:convert';
import 'package:camp/app/routes.dart';
import 'package:camp/app/theme/app_colors.dart';
import 'package:camp/core/storage/local_store.dart';
import 'package:camp/core/widgets/camp_bottom_nav.dart';
import 'package:camp/core/widgets/camp_empty_state.dart';
import 'package:camp/core/widgets/primary_button.dart';
import 'package:camp/features/mechanics/controllers/mechanic_controller.dart';
import 'package:camp/features/mechanics/domain/mechanic_model.dart';
import 'package:camp/features/mechanics/presentation/screens/add_mechanic_screen.dart';
import 'package:camp/features/mechanics/presentation/screens/mechanics_home_screen.dart';
import 'package:camp/features/mechanics/presentation/widgets/mechanic_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    store = LocalStore(prefs);
    LocalStore.instance = store;
    MechanicController.instance.resetForTesting();
  });

  group('Mechanic Persistence & Model Tests', () {
    test('Add a mechanic with a photo path, reload from LocalStore and assert round-trips', () async {
      await store.markFirstRunCompleted();

      const newMechanic = Mechanic(
        id: 'mech-babusar-01',
        name: 'Babusar High Pass Moto Prep',
        distance: '1.2 km away',
        durationOrLocation: 'Mile Marker 88',
        badgeType: BadgeType.verified,
        badgeLabel: 'Verified Shop',
        beaconStatus: 'Active',
        beaconColor: AppColors.statusGreen,
        categoryTitle1: 'SPECIALTIES',
        tags1: ['Carb Jetting', 'Tire Vulcanizing'],
        categoryTitle2: 'LOCATION',
        tags2: ['Babusar Pass'],
        rating: 4.9,
        reviewCount: 42,
        openStatus: 'OPEN NOW',
        phone: '+92 300 1234567',
        address: 'Babusar Pass Summit Junction',
        notes: 'Has 220V arc welder and stocked spark plugs',
        photoPath: '/data/user/0/com.camp.app/app_flutter/mechanics/mech_123.jpg',
      );

      MechanicController.instance.addMechanic(newMechanic);
      await MechanicController.instance.flush();

      // Verify it was written to LocalStore JSON
      final savedRaw = await store.readJson(LocalStore.keyMechanics);
      expect(savedRaw, isA<List<dynamic>>());
      final savedList = savedRaw! as List<dynamic>;
      expect(savedList.length, 1);
      expect(savedList.first['photoPath'], '/data/user/0/com.camp.app/app_flutter/mechanics/mech_123.jpg');

      // Clear controller in memory
      MechanicController.instance.resetForTesting();
      expect(MechanicController.instance.mechanics.isEmpty, isTrue);

      // Reload controller from LocalStore
      await MechanicController.instance.load(store);

      expect(MechanicController.instance.mechanics.length, 1);
      final loaded = MechanicController.instance.mechanics.first;
      expect(loaded.id, 'mech-babusar-01');
      expect(loaded.name, 'Babusar High Pass Moto Prep');
      expect(loaded.phone, '+92 300 1234567');
      expect(loaded.address, 'Babusar Pass Summit Junction');
      expect(loaded.photoPath, '/data/user/0/com.camp.app/app_flutter/mechanics/mech_123.jpg');
      expect(loaded.tags1, ['Carb Jetting', 'Tire Vulcanizing']);
      expect(loaded.notes, 'Has 220V arc welder and stocked spark plugs');
    });

    test('Delete removes mechanic and persists to LocalStore', () async {
      await store.markFirstRunCompleted();

      const mech1 = Mechanic(
        id: 'mech-1',
        name: 'First Workshop',
        distance: 'Nearby',
        durationOrLocation: 'Town',
        badgeType: BadgeType.verified,
        badgeLabel: 'Verified',
        beaconStatus: 'Active',
        beaconColor: AppColors.statusGreen,
        categoryTitle1: 'SERVICES',
        tags1: ['Repair'],
        categoryTitle2: 'LOCATION',
        tags2: ['Town'],
        rating: 5.0,
        reviewCount: 1,
        openStatus: 'OPEN',
        phone: '111',
      );

      const mech2 = Mechanic(
        id: 'mech-2',
        name: 'Second Workshop',
        distance: 'Nearby',
        durationOrLocation: 'Town',
        badgeType: BadgeType.verified,
        badgeLabel: 'Verified',
        beaconStatus: 'Active',
        beaconColor: AppColors.statusGreen,
        categoryTitle1: 'SERVICES',
        tags1: ['Repair'],
        categoryTitle2: 'LOCATION',
        tags2: ['Town'],
        rating: 5.0,
        reviewCount: 1,
        openStatus: 'OPEN',
        phone: '222',
      );

      MechanicController.instance.addMechanic(mech1);
      MechanicController.instance.addMechanic(mech2);
      await MechanicController.instance.flush();

      expect(MechanicController.instance.mechanics.length, 2);

      // Delete mech1
      MechanicController.instance.deleteMechanic('mech-1');
      await MechanicController.instance.flush();

      expect(MechanicController.instance.mechanics.length, 1);
      expect(MechanicController.instance.mechanics.first.id, 'mech-2');

      // Reload from storage and verify mech1 is gone
      MechanicController.instance.resetForTesting();
      await MechanicController.instance.load(store);

      expect(MechanicController.instance.mechanics.length, 1);
      expect(MechanicController.instance.mechanics.first.id, 'mech-2');
    });

    test('Old saved JSON without a photo field still loads properly with null photoPath', () async {
      await store.markFirstRunCompleted();

      // Simulate legacy JSON saved before photoPath existed
      final legacyJson = [
        {
          'id': 'legacy-mech-1',
          'name': 'Old Shardu Trail Garage',
          'distance': '3.5 km away',
          'durationOrLocation': 'Skardu Road',
          'badgeType': 'verified',
          'badgeLabel': 'Verified Shop',
          'beaconStatus': 'Active',
          'beaconColor': 0xFF2E7D32,
          'categoryTitle1': 'SERVICES',
          'tags1': ['Tire Repair'],
          'categoryTitle2': 'LOCATION',
          'tags2': ['Skardu'],
          'rating': 4.7,
          'reviewCount': 19,
          'openStatus': 'OPEN NOW',
          'phone': '+92 312 9876543',
          'address': 'Main Bazar Skardu',
          'notes': 'Experienced with Honda CG125',
          // Note: NO 'photoPath' or 'photo' field
        }
      ];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LocalStore.keyMechanics, jsonEncode(legacyJson));

      await MechanicController.instance.load(store);

      expect(MechanicController.instance.mechanics.length, 1);
      final loaded = MechanicController.instance.mechanics.first;
      expect(loaded.id, 'legacy-mech-1');
      expect(loaded.name, 'Old Shardu Trail Garage');
      expect(loaded.photoPath, isNull);
    });

    test('Updating / editing a mechanic persists changes', () async {
      await store.markFirstRunCompleted();

      const original = Mechanic(
        id: 'mech-edit-1',
        name: 'Original Name',
        distance: '5 km',
        durationOrLocation: 'Valley',
        badgeType: BadgeType.verified,
        badgeLabel: 'Verified',
        beaconStatus: 'Active',
        beaconColor: AppColors.statusGreen,
        categoryTitle1: 'SERVICES',
        tags1: ['Oil Change'],
        categoryTitle2: 'LOCATION',
        tags2: ['Valley'],
        rating: 5.0,
        reviewCount: 1,
        openStatus: 'OPEN',
        phone: '123',
      );

      MechanicController.instance.addMechanic(original);
      await MechanicController.instance.flush();

      final updated = original.copyWith(
        name: 'Renamed & Upgraded Moto Garage',
        phone: '+92 333 9999999',
        photoPath: '/new/path/signboard.jpg',
      );

      MechanicController.instance.updateMechanic(updated);
      await MechanicController.instance.flush();

      // Reload from store
      MechanicController.instance.resetForTesting();
      await MechanicController.instance.load(store);

      expect(MechanicController.instance.mechanics.length, 1);
      expect(MechanicController.instance.mechanics.first.name, 'Renamed & Upgraded Moto Garage');
      expect(MechanicController.instance.mechanics.first.phone, '+92 333 9999999');
      expect(MechanicController.instance.mechanics.first.photoPath, '/new/path/signboard.jpg');
    });
  });

  group('Mechanic Widget & Screen Tests', () {
    // Helper: wraps a widget in MediaQuery(disableAnimations:true) so every
    // repeating AnimationController (CustomAppBar, TopographicMapCanvas, etc.)
    // holds a static value and pumpAndSettle() always terminates.
    Widget noAnimApp(Widget home, {Map<String, WidgetBuilder>? routes}) {
      return MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          routes: routes ?? {},
          home: home,
        ),
      );
    }

    testWidgets('Empty state shows icon, message and "+ Add Mechanic" button which navigates',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool navigatedToAdd = false;

      await tester.pumpWidget(
        noAnimApp(
          const MechanicsHomeScreen(),
          routes: {
            CampRoutes.addMechanic: (_) {
              navigatedToAdd = true;
              return const Scaffold(body: Text('Add Mechanic Screen Dummy'));
            },
          },
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CampEmptyState), findsOneWidget);
      expect(find.text('+ Add Mechanic'), findsWidgets);

      final ctaButton = find.descendant(
        of: find.byType(CampEmptyState),
        matching: find.text('+ Add Mechanic'),
      );
      expect(ctaButton, findsOneWidget);
      await tester.tap(ctaButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(navigatedToAdd, isTrue);
    });

    testWidgets('MechanicCard shows fallback icon when no photo is present (no empty gap)',
        (tester) async {
      const mechanicWithoutPhoto = Mechanic(
        id: 'no-photo-mech',
        name: 'Roadside Tube Shop',
        distance: '0.5 km away',
        durationOrLocation: 'KKH Mile 200',
        badgeType: BadgeType.verified,
        badgeLabel: 'Verified Shop',
        beaconStatus: 'Active',
        beaconColor: AppColors.statusGreen,
        categoryTitle1: 'SERVICES',
        tags1: ['Tube Repair'],
        categoryTitle2: 'LOCATION',
        tags2: ['KKH'],
        rating: 5.0,
        reviewCount: 2,
        openStatus: 'OPEN NOW',
        phone: '123456',
        photoPath: null,
      );

      await tester.pumpWidget(
        noAnimApp(const Scaffold(body: MechanicCard(mechanic: mechanicWithoutPhoto))),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.storefront_rounded), findsOneWidget);
      expect(find.text('Roadside Tube Shop'), findsOneWidget);
    });

    testWidgets('AddMechanicScreen validates shop name is required', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(noAnimApp(const AddMechanicScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Try tapping Save Mechanic with empty shop name
      final saveButton = find.widgetWithText(PrimaryButton, 'Save Mechanic');
      expect(saveButton, findsOneWidget);

      await tester.ensureVisible(saveButton);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Expect validation error text in the field helper only
      expect(find.text('Shop name is required'), findsOneWidget);
      expect(MechanicController.instance.mechanics.isEmpty, isTrue);
    });

    testWidgets('AddMechanicScreen submits mechanic and pops with saved mechanic', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      MechanicController.instance.resetForTesting();

      await tester.pumpWidget(noAnimApp(const AddMechanicScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Enter shop name in the first TextField (Shop / Mechanic Name)
      await tester.enterText(find.byType(TextField).first, 'Alpine Expeditions Garage');
      await tester.pump();

      // Tap Save Mechanic
      final saveButton = find.widgetWithText(PrimaryButton, 'Save Mechanic');
      await tester.ensureVisible(saveButton);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(MechanicController.instance.mechanics.length, 1);
      expect(MechanicController.instance.mechanics.first.name, 'Alpine Expeditions Garage');
    });

    testWidgets('Delete confirmation dialog confirms and deletes mechanic', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      MechanicController.instance.resetForTesting();

      const mech = Mechanic(
        id: 'mech-to-delete',
        name: 'Delete Me Garage',
        distance: '1 km',
        durationOrLocation: 'Valley',
        badgeType: BadgeType.verified,
        badgeLabel: 'Verified',
        beaconStatus: 'Active',
        beaconColor: AppColors.statusGreen,
        categoryTitle1: 'SERVICES',
        tags1: ['Repair'],
        categoryTitle2: 'LOCATION',
        tags2: ['Valley'],
        rating: 5.0,
        reviewCount: 1,
        openStatus: 'OPEN',
        phone: '123',
      );

      MechanicController.instance.addMechanic(mech);

      await tester.pumpWidget(noAnimApp(const MechanicsHomeScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Delete Me Garage'), findsOneWidget);

      // Tap delete icon on card
      final deleteIcon = find.byIcon(Icons.delete_outline_rounded).first;
      await tester.tap(deleteIcon);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify confirmation dialog
      expect(find.text('Delete Mechanic?'), findsOneWidget);
      expect(
        find.text('Are you sure you want to remove Delete Me Garage from your saved mechanics?'),
        findsOneWidget,
      );

      // Tap Delete in dialog
      final confirmDeleteBtn = find.widgetWithText(TextButton, 'Delete');
      await tester.tap(confirmDeleteBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verified removed from controller and screen
      expect(MechanicController.instance.mechanics.isEmpty, isTrue);
      expect(find.text('Delete Me Garage'), findsNothing);
    });

    testWidgets('Bottom nav is present in AddMechanicScreen when keyboard is closed', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(noAnimApp(const AddMechanicScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // CampBottomNav hides itself when keyboard is open; initially it must be present
      expect(find.byType(CampBottomNav), findsOneWidget);
    });
  });
}

