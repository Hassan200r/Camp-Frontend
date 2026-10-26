import 'package:camp/core/data/app_repositories.dart';
import 'package:camp/features/navigation/presentation/screens/route_packs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSettingsRepository fakeSettingsRepo;

  Widget noAnimApp(Widget home) {
    return MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: MaterialApp(home: home),
    );
  }

  setUp(() async {
    fakeSettingsRepo = FakeSettingsRepository();
    AppRepositories.resetWith(settingsRepository: fakeSettingsRepo);
  });

  tearDown(() async {
    AppRepositories.resetToDefault();
  });

  group('Route Packs Honesty Pass Tests', () {
    testWidgets('Every pack shows Coming soon and no sizes, download buttons, or progress',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360 * 2, 2400 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(noAnimApp(RoutePacksScreen(settingsRepository: fakeSettingsRepo)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Pack titles are present
      expect(find.text('Karakoram Highway (KKH)'), findsOneWidget);
      expect(find.text('Babusar Pass & Kaghan'), findsOneWidget);
      expect(find.text('Makran Coastal Highway'), findsOneWidget);
      expect(find.text('Cholistan Desert Rally Route'), findsOneWidget);
      expect(find.text('Deosai Plains Plateau'), findsOneWidget);

      // 2. Every pack displays "Coming soon"
      final comingSoonPills = find.text('Coming soon');
      expect(comingSoonPills, findsWidgets);
      // Section header + 5 pack cards = at least 6 "Coming soon" texts
      expect(comingSoonPills.evaluate().length, greaterThanOrEqualTo(6));

      // 3. NO size claims (GB or MB) anywhere on screen
      expect(find.textContaining(' GB'), findsNothing);
      expect(find.textContaining(' MB'), findsNothing);
      expect(find.textContaining('GB Free'), findsNothing);

      // 4. NO fake download / sync / pause buttons or progress
      expect(find.text('Download Pack'), findsNothing);
      expect(find.text('Sync Update'), findsNothing);
      expect(find.text('Pause'), findsNothing);
      expect(find.text('Saved'), findsNothing);
      expect(find.textContaining('DOWNLOADING'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);

      // 5. NO unbacked region claims
      expect(find.text('5 Regions Available'), findsNothing);
      expect(find.text('OFFLINE TELEMETRY & TOPO PACKS'), findsNothing);
      expect(find.textContaining('Alps'), findsNothing);
      expect(find.textContaining('Cascades'), findsNothing);

      // 6. Header is honest and displays Route Packs without Topo V4.8 button
      expect(find.text('ROUTE PACKS'), findsOneWidget);
      expect(find.text('Topo V4.8'), findsNothing);
      expect(find.textContaining('Topo V4.8'), findsNothing);
      expect(find.byIcon(Icons.sync_rounded), findsNothing);

      // No overflows occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('Wi-Fi auto-update toggle loads from and persists to SettingsRepository',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360 * 2, 2400 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      // 1. Initially default is true
      final initialSettings = await fakeSettingsRepo.loadSettings();
      expect(initialSettings.wifiAutoUpdateRoutePacks, isTrue);

      await tester.pumpWidget(noAnimApp(RoutePacksScreen(settingsRepository: fakeSettingsRepo)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      final initialSwitch = tester.widget<Switch>(switchFinder);
      expect(initialSwitch.value, isTrue);

      // 2. Toggle the switch off
      await tester.tap(switchFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify state updated in UI
      final updatedSwitch = tester.widget<Switch>(switchFinder);
      expect(updatedSwitch.value, isFalse);

      // Verify persisted to SettingsRepository
      final savedSettings = await fakeSettingsRepo.loadSettings();
      expect(savedSettings.wifiAutoUpdateRoutePacks, isFalse);

      // 3. Re-launch screen and assert it loads the persisted 'false' value
      await tester.pumpWidget(noAnimApp(RoutePacksScreen(settingsRepository: fakeSettingsRepo)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final reloadedSwitch = tester.widget<Switch>(find.byType(Switch));
      expect(reloadedSwitch.value, isFalse);
    });
  });
}
