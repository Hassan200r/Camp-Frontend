import 'package:camp/core/storage/local_store.dart';
import 'package:camp/features/garage/controllers/active_bike_controller.dart';
import 'package:camp/features/garage/domain/bike_model.dart';
import 'package:camp/features/maintenance/controllers/post_ride_report_controller.dart';
import 'package:camp/features/maintenance/controllers/trip_budget_controller.dart';
import 'package:camp/features/maintenance/domain/expense_model.dart';
import 'package:camp/features/maintenance/domain/post_ride_report.dart';
import 'package:camp/features/maintenance/domain/trip_budget_model.dart';
import 'package:camp/features/settings/controllers/settings_controller.dart';
import 'package:camp/features/settings/domain/units_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LocalStore.instance.resetForTesting();
    ActiveBikeController.instance.reset();
    SettingsController.instance.reset();
    PostRideReportController.instance.reset();
    TripBudgetController.instance.reset();
  });

  group('First-run demo data seeding', () {
    test('Seeds demo fleet, settings, reports, and trip budget on first run', () async {
      SharedPreferences.setMockInitialValues({});
      final store = LocalStore();
      store.resetForTesting();

      expect(await store.isFirstRun(), isTrue);

      await ActiveBikeController.instance.load(store);
      await SettingsController.instance.load(store);
      await PostRideReportController.instance.load(store);
      await TripBudgetController.instance.load(store);

      expect(ActiveBikeController.instance.bikes.isNotEmpty, isTrue);
      expect(ActiveBikeController.instance.activeBikeId, 'bike-bmw-1250');
      expect(SettingsController.instance.units, UnitsSystem.metric);
      expect(PostRideReportController.instance.reports.isNotEmpty, isTrue);
      expect(TripBudgetController.instance.budget.tripName, 'Alpine Ridge Tour');
      expect(TripBudgetController.instance.expenses.isNotEmpty, isTrue);

      await store.markFirstRunCompleted();
      expect(await store.isFirstRun(), isFalse);
    });

    test('User data wins on subsequent runs even if modified or empty', () async {
      final store = LocalStore();
      store.resetForTesting();

      // Seed first run
      await ActiveBikeController.instance.load(store);
      await store.markFirstRunCompleted();

      // User removes all bikes except a custom one
      const customBike = Bike(
        id: 'custom-bike-99',
        make: 'Yamaha',
        modelName: 'Tenere 700',
        modelYear: 2024,
        odometerKm: 500,
      );
      ActiveBikeController.instance.addBike(customBike, setActive: true);
      ActiveBikeController.instance.removeBike('bike-bmw-1250');
      ActiveBikeController.instance.removeBike('bike-rebel-500');

      // Reload controller from store
      final freshStore = LocalStore();
      freshStore.resetForTesting();
      await ActiveBikeController.instance.load(freshStore);

      // Custom bike wins and defaults are NOT re-seeded
      expect(ActiveBikeController.instance.bikes.length, 1);
      expect(ActiveBikeController.instance.bikes.first.id, 'custom-bike-99');
      expect(ActiveBikeController.instance.activeBikeId, 'custom-bike-99');
    });
  });

  group('Round-trip persistence for each controller', () {
    test('ActiveBikeController round-trip saves and restores bikes & activeBikeId', () async {
      final store = LocalStore();
      store.resetForTesting();

      // Mark first run completed so user data rules apply
      await store.markFirstRunCompleted();

      const testBike = Bike(
        id: 'test-ducati-v4',
        make: 'Ducati',
        modelName: 'DesertX',
        modelYear: 2025,
        odometerKm: 1200,
        displacement: 937,
      );

      ActiveBikeController.instance.addBike(testBike, setActive: true);
      await ActiveBikeController.instance.save(store);

      // Reset in-memory state
      ActiveBikeController.instance.reset();
      expect(ActiveBikeController.instance.activeBikeId, isNot('test-ducati-v4'));

      // Restore from persistent store
      await ActiveBikeController.instance.load(store);
      expect(ActiveBikeController.instance.activeBikeId, 'test-ducati-v4');
      expect(
        ActiveBikeController.instance.bikes.any((b) => b.id == 'test-ducati-v4'),
        isTrue,
      );
    });

    test('SettingsController round-trip saves and restores preferences', () async {
      final store = LocalStore();
      store.resetForTesting();
      await store.markFirstRunCompleted();

      SettingsController.instance.setUnits(UnitsSystem.imperial);
      SettingsController.instance.setNotificationsEnabled(false);
      SettingsController.instance.setPrivacySharingEnabled(false);
      await SettingsController.instance.save(store);

      // Reset to defaults
      SettingsController.instance.reset();
      expect(SettingsController.instance.units, UnitsSystem.metric);
      expect(SettingsController.instance.notificationsEnabled, isTrue);

      // Restore
      await SettingsController.instance.load(store);
      expect(SettingsController.instance.units, UnitsSystem.imperial);
      expect(SettingsController.instance.notificationsEnabled, isFalse);
      expect(SettingsController.instance.privacySharingEnabled, isFalse);
    });

    test('PostRideReportController round-trip saves and restores reports', () async {
      final store = LocalStore();
      store.resetForTesting();
      await store.markFirstRunCompleted();

      final customReport = PostRideReport(
        id: 'rep-custom-roundtrip',
        bikeId: 'bike-bmw-1250',
        date: DateTime(2026, 9, 20),
        distanceKm: 312.4,
        terrainTags: const ['Mountain', 'Highway'],
        notes: 'High alpine test run',
        flaggedIssues: 'None',
      );

      PostRideReportController.instance.addReport(customReport);
      await PostRideReportController.instance.save(store);

      PostRideReportController.instance.clearAll();
      expect(PostRideReportController.instance.reports, isEmpty);

      await PostRideReportController.instance.load(store);
      expect(PostRideReportController.instance.reports.isNotEmpty, isTrue);
      expect(
        PostRideReportController.instance.reports.first.id,
        'rep-custom-roundtrip',
      );
      expect(
        PostRideReportController.instance.reports.first.distanceKm,
        312.4,
      );
    });

    test('TripBudgetController round-trip saves and restores budget & expenses', () async {
      final store = LocalStore();
      store.resetForTesting();
      await store.markFirstRunCompleted();

      const customBudget = TripBudget(
        tripName: 'Karakoram Highway Expedition',
        capAmount: 850.0,
        allocatedSoFar: 220.0,
        startDate: 'Aug 1, 2026',
        endDate: 'Aug 10, 2026',
      );
      const customExpense = Expense(
        id: 'exp-roundtrip-1',
        category: ExpenseCategory.fuel,
        title: 'High Altitude High Octane',
        amount: 85.0,
        trackingMode: ExpenseTrackingMode.manualEntry,
      );

      TripBudgetController.instance.setBudget(customBudget);
      TripBudgetController.instance.addExpense(customExpense);
      await TripBudgetController.instance.save(store);

      TripBudgetController.instance.reset();
      expect(
        TripBudgetController.instance.budget.tripName,
        'Alpine Ridge Tour',
      );

      await TripBudgetController.instance.load(store);
      expect(
        TripBudgetController.instance.budget.tripName,
        'Karakoram Highway Expedition',
      );
      expect(TripBudgetController.instance.budget.capAmount, 850.0);
      expect(
        TripBudgetController.instance.expenses.any((e) => e.id == 'exp-roundtrip-1'),
        isTrue,
      );
    });
  });

  group('Corrupt JSON fallback', () {
    test('Corrupted or invalid JSON falls back to defaults without crashing', () async {
      SharedPreferences.setMockInitialValues({
        LocalStore.schemaVersionKey: 1,
        LocalStore.keyFirstRunCompleted: true,
        LocalStore.keyBikes: '{corrupt json syntax::: invalid',
        LocalStore.keySettings: 'not valid json at all',
        LocalStore.keyPostRideReports: '{"broken": [true, false]}',
        LocalStore.keyTripBudget: '{"tripName": null, "capAmount": "invalid_num"}',
        LocalStore.keyTripExpenses: 'not_a_list',
      });

      final store = LocalStore();
      store.resetForTesting();

      // Must execute cleanly without unhandled exceptions or crashes
      await ActiveBikeController.instance.load(store);
      await SettingsController.instance.load(store);
      await PostRideReportController.instance.load(store);
      await TripBudgetController.instance.load(store);

      expect(ActiveBikeController.instance.bikes.isNotEmpty, isTrue);
      expect(SettingsController.instance.units, UnitsSystem.metric);
      expect(PostRideReportController.instance.reports.isNotEmpty, isTrue);
      expect(TripBudgetController.instance.budget.tripName, 'Alpine Ridge Tour');
    });

    test('Older or incompatible schema version falls back safely', () async {
      SharedPreferences.setMockInitialValues({
        LocalStore.schemaVersionKey: 999, // Incompatible future version
        LocalStore.keyFirstRunCompleted: true,
        LocalStore.keySettings: '{"units": "imperial"}',
      });

      final store = LocalStore();
      store.resetForTesting();

      await SettingsController.instance.load(store);
      // Falls back to defaults because schema version 999 is incompatible
      expect(SettingsController.instance.units, UnitsSystem.metric);
    });
  });

  group('Clear Cache Isolation', () {
    test('Settings clearLocalCache leaves garage, reports, and settings intact', () async {
      final store = LocalStore();
      store.resetForTesting();
      await store.markFirstRunCompleted();

      // Configure garage, reports, and settings
      SettingsController.instance.setUnits(UnitsSystem.imperial);
      SettingsController.instance.setPrivacySharingEnabled(false);
      expect(SettingsController.instance.localCacheSizeGb, greaterThan(0.0));

      final bikeCountBefore = ActiveBikeController.instance.bikes.length;
      final reportsCountBefore = PostRideReportController.instance.reports.length;

      // Execute Clear Local Cache from Settings
      SettingsController.instance.clearLocalCache();

      // Verify cache display is 0.0 GB
      expect(SettingsController.instance.localCacheSizeGb, 0.0);
      expect(SettingsController.instance.localCacheDisplay, '0 B');

      // Verify garage, reports, and settings preferences are untouched
      expect(ActiveBikeController.instance.bikes.length, bikeCountBefore);
      expect(PostRideReportController.instance.reports.length, reportsCountBefore);
      expect(SettingsController.instance.units, UnitsSystem.imperial);
      expect(SettingsController.instance.privacySharingEnabled, isFalse);
    });
  });
}
