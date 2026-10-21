import '../../features/maintenance/domain/maintenance_item_model.dart';
import '../../features/maintenance/domain/service_schedule_item.dart';
import '../storage/local_store.dart';
import 'maintenance_repository.dart';

class MaintenanceRepositoryLocal implements MaintenanceRepository {
  MaintenanceRepositoryLocal([LocalStore? store]) : _explicitStore = store;

  final LocalStore? _explicitStore;
  LocalStore get _store => _explicitStore ?? LocalStore.instance;

  @override
  Future<List<MaintenanceItem>> loadMaintenanceItems() async {
    final json = await _store.readJson(LocalStore.keyMaintenanceItems);
    if (json is! List) {
      return [];
    }

    bool needsMigration = false;
    final items = <MaintenanceItem>[];

    for (int i = 0; i < json.length; i++) {
      final raw = json[i];
      if (raw is Map) {
        final map = raw is Map<String, dynamic> ? raw : raw.cast<String, dynamic>();
        final item = MaintenanceItem.fromJson(map);
        if (item.id.isEmpty || map['id'] == null || (map['id'] as String).isEmpty) {
          needsMigration = true;
          items.add(item.copyWith(id: 'maint_${DateTime.now().millisecondsSinceEpoch}_$i'));
        } else {
          if (map['createdAt'] == null || map['updatedAt'] == null) {
            needsMigration = true;
          }
          items.add(item);
        }
      }
    }

    if (needsMigration) {
      await saveMaintenanceItems(items);
    }

    return items;
  }

  @override
  Future<void> saveMaintenanceItems(List<MaintenanceItem> items) async {
    final now = DateTime.now().toUtc();
    final updated = items.map((item) {
      return item.copyWith(
        id: item.effectiveId,
        createdAt: item.effectiveCreatedAt,
        updatedAt: now,
      );
    }).toList();

    await _store.writeJson(
      LocalStore.keyMaintenanceItems,
      updated.map((i) => i.toJson()).toList(),
    );
  }

  @override
  Future<void> deleteMaintenanceItem(String id) async {
    final current = await loadMaintenanceItems();
    final filtered = current.where((item) => item.effectiveId != id).toList();
    await saveMaintenanceItems(filtered);
  }

  @override
  Future<List<ServiceScheduleItem>> loadServiceSchedule(String bikeId) async {
    final json = await _store.readJson(LocalStore.keyServiceSchedule);
    if (json is! Map) return [];
    final list = json[bikeId];
    if (list is! List) return [];
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => ServiceScheduleItem.fromJson(
            Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  Future<void> saveServiceSchedule(
      String bikeId, List<ServiceScheduleItem> items) async {
    final raw = await _store.readJson(LocalStore.keyServiceSchedule);
    final map = raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};
    final now = DateTime.now().toUtc();
    final updated = items.map((ServiceScheduleItem item) {
      return item.copyWith(
        id: item.effectiveId,
        createdAt: item.effectiveCreatedAt,
        updatedAt: now,
      );
    }).toList();
    map[bikeId] = updated.map((ServiceScheduleItem i) => i.toJson()).toList();
    await _store.writeJson(LocalStore.keyServiceSchedule, map);
  }

  @override
  Future<bool> loadHarshConditions(String bikeId) async {
    final json = await _store.readJson(LocalStore.keyHarshConditions);
    if (json is Map && json[bikeId] is bool) {
      return json[bikeId] as bool;
    }
    return false;
  }

  @override
  Future<void> saveHarshConditions(String bikeId, bool isHarsh) async {
    final raw = await _store.readJson(LocalStore.keyHarshConditions);
    final map = raw is Map
        ? (raw is Map<String, dynamic> ? raw : raw.cast<String, dynamic>())
        : <String, dynamic>{};
    map[bikeId] = isHarsh;
    await _store.writeJson(LocalStore.keyHarshConditions, map);
  }

  @override
  Future<void> deleteServiceSchedule(String bikeId) async {
    final raw = await _store.readJson(LocalStore.keyServiceSchedule);
    if (raw is Map) {
      final map =
          raw is Map<String, dynamic> ? raw : raw.cast<String, dynamic>();
      map.remove(bikeId);
      await _store.writeJson(LocalStore.keyServiceSchedule, map);
    }
  }

  @override
  Future<Map<String, dynamic>?> loadJettingBaseline() async {
    final json = await _store.readJson(LocalStore.keyJettingBaseline);
    if (json is Map) {
      return json is Map<String, dynamic> ? json : json.cast<String, dynamic>();
    }
    return null;
  }

  @override
  Future<void> saveJettingBaseline(Map<String, dynamic>? baseline) async {
    await _store.writeJson(LocalStore.keyJettingBaseline, baseline);
  }

  @override
  Future<Map<String, bool>> loadChecklist() async {
    final json = await _store.readJson(LocalStore.keyChecklist);
    if (json is Map) {
      final map = json is Map<String, dynamic> ? json : json.cast<String, dynamic>();
      return map.map((key, value) => MapEntry(key, value == true));
    }
    return {};
  }

  @override
  Future<void> saveChecklist(Map<String, bool> checklist) async {
    await _store.writeJson(LocalStore.keyChecklist, checklist);
  }

  @override
  Future<void> clear() async {
    await _store.writeJson(LocalStore.keyMaintenanceItems, null);
    await _store.writeJson(LocalStore.keyServiceSchedule, null);
    await _store.writeJson(LocalStore.keyHarshConditions, null);
    await _store.writeJson(LocalStore.keyJettingBaseline, null);
    await _store.writeJson(LocalStore.keyChecklist, null);
  }

  @override
  Future<void> flush() async {
    await _store.flush();
  }
}

MaintenanceRepository resolveMaintenanceRepository(dynamic source, [MaintenanceRepository? fallback]) {
  if (source is MaintenanceRepository) return source;
  if (source is LocalStore) return MaintenanceRepositoryLocal(source);
  return fallback ?? MaintenanceRepositoryLocal();
}
