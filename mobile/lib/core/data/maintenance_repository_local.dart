import '../../features/maintenance/domain/maintenance_item_model.dart';
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
