import 'package:camp/features/garage/controllers/active_bike_controller.dart';
import 'package:camp/features/settings/controllers/settings_controller.dart';
import 'package:camp/features/settings/domain/units_system.dart';
import 'package:camp/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    SettingsController.instance.reset();
    ActiveBikeController.instance.reset();
  });

  group('SettingsController Unit Tests', () {
    test('Initializes with default settings', () {
      final controller = SettingsController.instance;
      expect(controller.units, UnitsSystem.metric);
      expect(controller.isMetric, isTrue);
      expect(controller.isImperial, isFalse);
      expect(controller.notificationsEnabled, isTrue);
      expect(controller.privacySharingEnabled, isTrue);
      expect(controller.cachedPacksSizeGb, 14.2);
      expect(controller.cachedPacksSubtitle, 'Cascades & Alps Route Packs');
      expect(controller.localCacheSizeGb, 1.4);
      expect(controller.localCacheDisplay, '1.4 GB');
      expect(controller.language, 'English');
    });

    test('setUnits updates measurement system reactively', () {
      final controller = SettingsController.instance;
      var notified = false;
      controller.addListener(() => notified = true);

      controller.setUnits(UnitsSystem.imperial);
      expect(controller.units, UnitsSystem.imperial);
      expect(controller.isImperial, isTrue);
      expect(controller.isMetric, isFalse);
      expect(notified, isTrue);
    });

    test('toggleNotifications updates notifications preference', () {
      final controller = SettingsController.instance;
      controller.setNotificationsEnabled(false);
      expect(controller.notificationsEnabled, isFalse);

      controller.toggleNotifications();
      expect(controller.notificationsEnabled, isTrue);
    });

    test('togglePrivacySharing updates telemetry sharing preference', () {
      final controller = SettingsController.instance;
      controller.setPrivacySharingEnabled(false);
      expect(controller.privacySharingEnabled, isFalse);

      controller.togglePrivacySharing();
      expect(controller.privacySharingEnabled, isTrue);
    });

    test('clearLocalCache resets local cache size to 0', () {
      final controller = SettingsController.instance;
      expect(controller.localCacheSizeGb, 1.4);

      controller.clearLocalCache();
      expect(controller.localCacheSizeGb, 0.0);
      expect(controller.localCacheDisplay, '0 B');
    });
  });

  group('SettingsScreen Widget Tests', () {
    testWidgets('Renders all cards, rows, dynamic bike name, and elements matching reference',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: const SettingsScreen(),
          routes: {
            '/profile': (context) => const Scaffold(body: Text('Profile Screen')),
            '/edit-profile': (context) => const Scaffold(body: Text('Edit Profile Screen')),
            '/route-packs': (context) => const Scaffold(body: Text('Route Packs Screen')),
            '/sign-in': (context) => const Scaffold(body: Text('Sign In Screen')),
          },
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header
      expect(find.text('SETTINGS'), findsOneWidget);

      // 2. Hero Row with Rider & Active Rig read from ActiveBikeController
      expect(find.text('Alex Henderson'), findsOneWidget);
      expect(find.text('PRO'), findsOneWidget);
      final activeBike = ActiveBikeController.instance.activeBike!;
      expect(find.text('Active Rig: ${activeBike.make} ${activeBike.modelName}'), findsOneWidget);

      // 3. Card Account
      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('Edit Personal Info'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Linked Accounts'), findsOneWidget);
      expect(find.text('Connected as alex@bmwmoto.com'), findsOneWidget);

      // 4. Card Preferences
      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('Units'), findsOneWidget);
      expect(find.text('Metric (km, °C)'), findsOneWidget);
      expect(find.text('Imperial (mi, °F)'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Maintenance alerts, trip reminders'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      // 5. Card Storage & Data
      expect(find.text('STORAGE & DATA'), findsOneWidget);
      expect(find.text('Offline Maps'), findsOneWidget);
      expect(find.text('Cascades & Alps Route Packs'), findsOneWidget);
      expect(find.text('14.2 GB used'), findsOneWidget);
      expect(find.text('Privacy & Data Sharing'), findsOneWidget);
      expect(find.text('Clear Local Cache'), findsOneWidget);
      expect(find.text('Free up temporary storage (1.4 GB)'), findsOneWidget);

      // 6. Card Support
      expect(find.text('SUPPORT'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('About CAMP'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);

      // 7. Danger Log Out button
      expect(find.text('Log Out'), findsOneWidget);

      // 8. Footer text
      expect(find.text('CAMP v1.0.0 • Built for adventure riders'), findsOneWidget);
    });

    testWidgets('Toggling Units switches shared state in SettingsController',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(SettingsController.instance.units, UnitsSystem.metric);

      // Tap "Imperial (mi, °F)"
      await tester.tap(find.text('Imperial (mi, °F)'));
      await tester.pumpAndSettle();

      expect(SettingsController.instance.units, UnitsSystem.imperial);

      // Tap back to "Metric (km, °C)"
      await tester.tap(find.text('Metric (km, °C)'));
      await tester.pumpAndSettle();

      expect(SettingsController.instance.units, UnitsSystem.metric);
    });

    testWidgets('Clear Local Cache shows confirmation dialog and updates storage display',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Free up temporary storage (1.4 GB)'), findsOneWidget);

      // Tap Clear Local Cache
      await tester.tap(find.text('Clear Local Cache'));
      await tester.pumpAndSettle();

      // Verify dialog
      expect(find.text('Clear Local Cache?'), findsOneWidget);
      expect(find.text('Clear Cache'), findsOneWidget);

      // Confirm clear
      await tester.tap(find.text('Clear Cache'));
      await tester.pumpAndSettle();

      expect(SettingsController.instance.localCacheSizeGb, 0.0);
      expect(find.text('Free up temporary storage (0 B)'), findsOneWidget);
    });

    testWidgets('Offline Maps row navigates to /route-packs', (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: const SettingsScreen(),
          routes: {
            '/route-packs': (context) => const Scaffold(body: Text('Route Packs Screen View')),
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Offline Maps'));
      await tester.pumpAndSettle();

      expect(find.text('Route Packs Screen View'), findsOneWidget);
    });

    testWidgets('Hero row navigates to /profile', (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: const SettingsScreen(),
          routes: {
            '/profile': (context) => const Scaffold(body: Text('Profile Screen View')),
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alex Henderson'));
      await tester.pumpAndSettle();

      expect(find.text('Profile Screen View'), findsOneWidget);
    });
  });
}
