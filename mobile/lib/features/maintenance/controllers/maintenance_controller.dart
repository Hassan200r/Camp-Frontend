import 'package:flutter/foundation.dart';

import '../../../core/data/app_repositories.dart';
import '../../../core/data/maintenance_repository.dart';
import '../../../core/data/service_visit_repository.dart';
import '../../garage/controllers/active_bike_controller.dart';
import '../../garage/domain/bike_model.dart';
import '../domain/expense_model.dart';
import '../domain/maintenance_prediction_engine.dart';
import '../domain/service_schedule_engine.dart';
import '../domain/service_schedule_item.dart';
import '../domain/service_visit_model.dart';
import 'post_ride_report_controller.dart';
import 'trip_budget_controller.dart';

/// Helper value object representing a found historical service record.
@immutable
class ServiceRecordMatch {
  const ServiceRecordMatch({this.km, this.date, this.description});
  final double? km;
  final DateTime? date;
  final String? description;
}

/// Singleton ChangeNotifier controller exposing rider-configured service schedules,
/// urgency predictions, and maintenance workflows across the entire app.
///
/// Serves as the single source of truth for:
/// - Home maintenance alert
/// - Home Service Status card
/// - Cockpit status line
/// - Drawer due count
/// - Maintenance hub & diagnostics
class MaintenanceController extends ChangeNotifier {
  MaintenanceController._() {
    _init();
  }

  static final MaintenanceController instance = MaintenanceController._();

  MaintenanceRepository _repository = AppRepositories.instance.maintenanceRepository;
  ServiceVisitRepository _serviceVisitRepository = AppRepositories.instance.serviceVisitRepository;

  @visibleForTesting
  set repository(MaintenanceRepository repo) => _repository = repo;

  @visibleForTesting
  set serviceVisitRepository(ServiceVisitRepository repo) => _serviceVisitRepository = repo;

  @visibleForTesting
  void reset() {
    _schedules.clear();
    _harshConditions.clear();
    _carburetorOverrides.clear();
    _loadedBikes.clear();
    notifyListeners();
  }

  final Map<String, List<ServiceScheduleItem>> _schedules = {};
  final Map<String, bool> _harshConditions = {};
  final Map<String, bool> _carburetorOverrides = {};
  final Set<String> _loadedBikes = {};

  void _init() {
    ActiveBikeController.instance.addListener(_onActiveBikeChanged);
    final active = ActiveBikeController.instance.activeBike;
    if (active != null) {
      loadSchedule(active.id);
    }
  }

  void _onActiveBikeChanged() {
    final active = ActiveBikeController.instance.activeBike;
    if (active != null && !_loadedBikes.contains(active.id)) {
      loadSchedule(active.id);
    }
  }

  /// Whether the rider has configured any service schedule items with an interval for this bike.
  ///
  /// Returns false when nothing has been configured, triggering the "Set up your service schedule" state.
  bool hasMaintenanceData(Bike? bike) {
    if (bike == null) return false;
    final itemsList = _schedules[bike.id];
    if (itemsList == null || itemsList.isEmpty) {
      return false;
    }
    return itemsList.any((i) => i.enabled && i.hasInterval);
  }

  /// Load persisted schedule and conditions for the specified bike.
  Future<void> loadSchedule(String bikeId) async {
    try {
      final items = await _repository.loadServiceSchedule(bikeId);
      final isHarsh = await _repository.loadHarshConditions(bikeId);
      if (!_schedules.containsKey(bikeId) || _schedules[bikeId]!.isEmpty || items.isNotEmpty) {
        _schedules[bikeId] = items;
      }
      _harshConditions[bikeId] = isHarsh;
      _loadedBikes.add(bikeId);
      notifyListeners();
    } catch (_) {}
  }

  /// Whether harsh riding conditions (20% interval reduction) are active for the bike.
  bool isHarshConditions(String? bikeId) {
    if (bikeId == null) return false;
    return _harshConditions[bikeId] ?? false;
  }

  /// Set and persist harsh riding conditions for the bike.
  Future<void> setHarshConditions(String bikeId, bool isHarsh) async {
    _harshConditions[bikeId] = isHarsh;
    await _repository.saveHarshConditions(bikeId, isHarsh);
    notifyListeners();
  }

  /// Whether this bike is considered carbureted (from model field or user toggle override).
  bool isCarbureted(Bike? bike) {
    if (bike == null) return false;
    if (bike.fuelSystem == FuelSystem.carburetor) return true;
    return _carburetorOverrides[bike.id] ?? false;
  }

  /// Set the "My bike has a carburetor" toggle override.
  void setCarburetorOverride(String bikeId, bool hasCarb) {
    _carburetorOverrides[bikeId] = hasCarb;
    notifyListeners();
  }

  /// Returns all schedule items configured for the bike, creating unconfigured
  /// items for any missing types.
  List<ServiceScheduleItem> getScheduleItems(String bikeId) {
    final bike = _resolveBike(bikeId);
    final isCarb = isCarbureted(bike);

    final stored = _schedules[bikeId] ?? [];
    final storedMap = {for (final item in stored) item.type: item};

    final result = <ServiceScheduleItem>[];
    for (final type in ServiceItemType.values) {
      if (type == ServiceItemType.carburetor && !isCarb) {
        continue;
      }
      if (storedMap.containsKey(type)) {
        result.add(storedMap[type]!);
      } else {
        double? lastKm;
        DateTime? lastDate;
        if (type == ServiceItemType.oilAndSmallService && bike?.lastOilChange != null) {
          lastKm = bike!.lastOilChange!.km?.toDouble();
          lastDate = bike.lastOilChange!.date;
        } else if (type == ServiceItemType.tuning && bike?.lastTuneUp != null) {
          lastKm = bike!.lastTuneUp!.km?.toDouble();
          lastDate = bike.lastTuneUp!.date;
        }
        result.add(ServiceScheduleItem(
          id: 'sched_${bikeId}_${type.name}',
          bikeId: bikeId,
          type: type,
          lastDoneKm: lastKm,
          lastDoneDate: lastDate,
        ));
      }
    }
    return result;
  }

  /// Immediately sets in-memory schedule and notifies listeners (persisting in background).
  void setSchedule(String bikeId, List<ServiceScheduleItem> items) {
    _schedules[bikeId] = List.from(items);
    _loadedBikes.add(bikeId);
    notifyListeners();
    _repository.saveServiceSchedule(bikeId, items);
  }

  /// Saves the full service schedule for the bike.
  Future<void> saveSchedule(String bikeId, List<ServiceScheduleItem> items) async {
    _schedules[bikeId] = List.from(items);
    _loadedBikes.add(bikeId);
    notifyListeners();
    await _repository.saveServiceSchedule(bikeId, items);
  }

  /// Returns computed health and due predictions for all relevant service items of the bike.
  List<ServiceSchedulePrediction> items(String? bikeId) {
    final bike = _resolveBike(bikeId);
    if (bike == null) return const [];
    return itemsForBike(bike);
  }

  /// Returns computed health and due predictions for a given bike instance directly.
  List<ServiceSchedulePrediction> itemsForBike(Bike bike) {
    final scheduleItems = getScheduleItems(bike.id);
    final reports = PostRideReportController.instance.getReportsForBike(bike.id);
    final isHarsh = isHarshConditions(bike.id) ||
        (bike.ridingTerrain?.any((t) =>
                t.toLowerCase() == 'off-road' ||
                t.toLowerCase() == 'mountain') ??
            false);

    return scheduleItems.map((item) {
      return ServiceScheduleEngine.evaluateItem(
        item: item,
        currentOdometerKm: bike.odometerKm.toDouble(),
        isHarshConditions: isHarsh,
        recentReports: reports,
      );
    }).toList();
  }

  /// Returns the most urgent maintenance item (Overdue > Due soon).
  ///
  /// Returns `null` if nothing is overdue or due soon, or if no schedule is configured.
  ServiceSchedulePrediction? mostUrgentItem(String? bikeId) {
    final bike = _resolveBike(bikeId);
    if (bike == null || !hasMaintenanceData(bike)) {
      return null;
    }

    final all = items(bike.id);

    // Filter to items that are actually configured (have interval and last done)
    final configured = all.where((i) =>
        i.item.enabled &&
        i.item.hasInterval &&
        i.item.hasLastDone).toList();

    // 1. Overdue items take absolute priority
    final overdue = configured
        .where((i) => i.scheduleStatus == ScheduleItemStatus.overdue)
        .toList();
    if (overdue.isNotEmpty) {
      // Sort by greatest overdue (smallest remainingKm or highest wear)
      overdue.sort((a, b) => b.wearPercent.compareTo(a.wearPercent));
      return overdue.first;
    }

    // 2. Due soon items are second priority
    final dueSoon = configured
        .where((i) => i.scheduleStatus == ScheduleItemStatus.dueSoon)
        .toList();
    if (dueSoon.isNotEmpty) {
      dueSoon.sort((a, b) => (a.remainingKm ?? 999999).compareTo(b.remainingKm ?? 999999));
      return dueSoon.first;
    }

    // All items OK
    return null;
  }

  /// Returns the total count of components that are overdue or due soon.
  int countDueItems(String? bikeId) {
    final bike = _resolveBike(bikeId);
    if (bike == null || !hasMaintenanceData(bike)) {
      return 0;
    }

    final all = items(bike.id);
    return all.where((i) =>
        i.item.enabled &&
        i.item.hasInterval &&
        i.item.hasLastDone &&
        (i.scheduleStatus == ScheduleItemStatus.overdue ||
            i.scheduleStatus == ScheduleItemStatus.dueSoon)).length;
  }

  /// Marks a specific service item as done at the given odometer reading and date.
  ///
  /// Optionally records rider-entered cost as an expense into Finances.
  Future<void> markItemDone(
    String bikeId,
    String itemId, {
    required double odometerKm,
    required DateTime date,
    double? cost,
  }) async {
    final currentList = getScheduleItems(bikeId);
    final index = currentList.indexWhere((i) => i.id == itemId);

    final itemToUpdate = index != -1
        ? currentList[index]
        : currentList.firstWhere((i) => i.type.name == itemId || i.id.contains(itemId));

    final updatedItem = itemToUpdate.copyWith(
      lastDoneKm: odometerKm,
      lastDoneDate: date,
      updatedAt: DateTime.now().toUtc(),
    );

    final updatedList = currentList.map((i) => i.id == updatedItem.id ? updatedItem : i).toList();
    await saveSchedule(bikeId, updatedList);

    // Update bike's milestone if applicable
    final bike = _resolveBike(bikeId);
    if (bike != null) {
      Bike updatedBike = bike;
      if (odometerKm > bike.odometerKm) {
        updatedBike = updatedBike.copyWith(
          odometerKm: odometerKm.round(),
          preciseOdometerKm: odometerKm,
        );
      }
      if (updatedItem.type == ServiceItemType.oilAndSmallService) {
        updatedBike = updatedBike.copyWith(
          lastOilChange: ServiceRecord(km: odometerKm.round(), date: date),
        );
      } else if (updatedItem.type == ServiceItemType.tuning) {
        updatedBike = updatedBike.copyWith(
          lastTuneUp: ServiceRecord(km: odometerKm.round(), date: date),
        );
      }
      ActiveBikeController.instance.updateBike(updatedBike);
    }

    // Write a service visit record
    try {
      final visits = await _serviceVisitRepository.loadServiceVisits();
      final newVisit = ServiceVisit(
        id: 'visit-${DateTime.now().millisecondsSinceEpoch}',
        dateTime: date,
        shopName: '${updatedItem.type.displayName} Service',
        note: 'Completed at ${odometerKm.round()} km',
      );
      await _serviceVisitRepository.saveServiceVisits([...visits, newVisit]);
    } catch (_) {}

    // Record optional rider-entered cost in Finances
    if (cost != null && cost > 0) {
      TripBudgetController.instance.addExpense(
        Expense(
          id: 'exp-${DateTime.now().millisecondsSinceEpoch}',
          category: ExpenseCategory.service,
          title: '${updatedItem.type.displayName} Service',
          amount: cost,
          dateRecorded: date,
          note: 'Marked service done at ${odometerKm.round()} km',
          trackingMode: ExpenseTrackingMode.manualEntry,
        ),
      );
    }

    notifyListeners();
  }

  /// Locates the most recent logged service record matching this type for "Use last logged service".
  ServiceRecordMatch? findLastLoggedService(String bikeId, ServiceItemType type) {
    final bike = _resolveBike(bikeId);
    if (bike == null) return null;

    if (type == ServiceItemType.oilAndSmallService && bike.lastOilChange != null) {
      final rec = bike.lastOilChange!;
      if (rec.km != null || rec.date != null) {
        return ServiceRecordMatch(
          km: rec.km?.toDouble(),
          date: rec.date,
          description: 'Last Oil Change (${rec.km ?? 0} km)',
        );
      }
    }

    if (type == ServiceItemType.tuning && bike.lastTuneUp != null) {
      final rec = bike.lastTuneUp!;
      if (rec.km != null || rec.date != null) {
        return ServiceRecordMatch(
          km: rec.km?.toDouble(),
          date: rec.date,
          description: 'Last Tune-up (${rec.km ?? 0} km)',
        );
      }
    }

    return null;
  }

  /// Calculates the full maintenance assessment for the given bike.
  MaintenanceAssessment? getAssessment(String? bikeId) {
    final bike = _resolveBike(bikeId);
    if (bike == null) return null;

    final reports = PostRideReportController.instance.getReportsForBike(bike.id);
    return MaintenancePredictionEngine.analyze(
      bike: bike,
      rideReports: reports,
    );
  }

  /// Resolves bike by id or defaults to activeBike.
  Bike? _resolveBike(String? bikeId) {
    if (bikeId != null && bikeId.isNotEmpty) {
      return ActiveBikeController.instance.getBikeById(bikeId);
    }
    return ActiveBikeController.instance.activeBike;
  }

  /// Refreshes state and notifies listeners.
  void refresh() {
    notifyListeners();
  }

  @visibleForTesting
  void resetForTesting() {
    _schedules.clear();
    _harshConditions.clear();
    _carburetorOverrides.clear();
    _loadedBikes.clear();
    _repository = AppRepositories.instance.maintenanceRepository;
    _serviceVisitRepository = AppRepositories.instance.serviceVisitRepository;
    notifyListeners();
  }
}
