import 'package:camp/core/data/maintenance_repository.dart';
import 'package:camp/core/data/service_visit_repository.dart';
import 'package:camp/features/maintenance/domain/maintenance_item_model.dart';
import 'package:camp/features/maintenance/domain/service_schedule_item.dart';
import 'package:camp/features/maintenance/domain/service_visit_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory fake implementation of MaintenanceRepository for test isolation.
class FakeMaintenanceRepository extends Fake implements MaintenanceRepository {
  final Map<String, List<ServiceScheduleItem>> schedules = {};
  final Map<String, bool> harshConditions = {};
  final List<MaintenanceItem> items = [];
  Map<String, bool> checklist = {};
  Map<String, dynamic>? jettingBaseline;

  @override
  Future<List<ServiceScheduleItem>> loadServiceSchedule(String bikeId) async =>
      List.from(schedules[bikeId] ?? []);

  @override
  Future<void> saveServiceSchedule(String bikeId, List<ServiceScheduleItem> list) async {
    schedules[bikeId] = List.from(list);
  }

  @override
  Future<bool> loadHarshConditions(String bikeId) async => harshConditions[bikeId] ?? false;

  @override
  Future<void> saveHarshConditions(String bikeId, bool isHarsh) async {
    harshConditions[bikeId] = isHarsh;
  }

  @override
  Future<List<MaintenanceItem>> loadMaintenanceItems() async => List.from(items);

  @override
  Future<void> saveMaintenanceItems(List<MaintenanceItem> newItems) async {
    items.clear();
    items.addAll(newItems);
  }

  @override
  Future<void> deleteMaintenanceItem(String id) async {
    items.removeWhere((i) => i.id == id);
  }

  @override
  Future<Map<String, bool>> loadChecklist() async => Map.from(checklist);

  @override
  Future<void> saveChecklist(Map<String, bool> list) async {
    checklist = Map.from(list);
  }

  @override
  Future<Map<String, dynamic>?> loadJettingBaseline() async => jettingBaseline;

  @override
  Future<void> saveJettingBaseline(Map<String, dynamic>? baseline) async {
    jettingBaseline = baseline;
  }

  @override
  Future<void> deleteServiceSchedule(String bikeId) async {
    schedules.remove(bikeId);
  }

  @override
  Future<void> clear() async {
    schedules.clear();
    harshConditions.clear();
    items.clear();
  }

  @override
  Future<void> flush() async {}
}

/// In-memory fake implementation of ServiceVisitRepository for test isolation.
class FakeServiceVisitRepository extends Fake implements ServiceVisitRepository {
  final List<ServiceVisit> visits = [];

  @override
  Future<List<ServiceVisit>> loadServiceVisits() async => List.from(visits);

  @override
  Future<void> saveServiceVisits(List<ServiceVisit> newVisits) async {
    visits.clear();
    visits.addAll(newVisits);
  }

  @override
  Future<void> deleteServiceVisit(String id) async {
    visits.removeWhere((v) => v.id == id);
  }

  @override
  Future<void> clear() async {
    visits.clear();
  }

  @override
  Future<void> flush() async {}
}

