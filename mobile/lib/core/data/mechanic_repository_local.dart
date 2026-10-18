import '../../features/mechanics/domain/mechanic_model.dart';
import '../storage/local_store.dart';
import 'mechanic_repository.dart';

class MechanicRepositoryLocal implements MechanicRepository {
  MechanicRepositoryLocal([LocalStore? store]) : _explicitStore = store;

  final LocalStore? _explicitStore;
  LocalStore get _store => _explicitStore ?? LocalStore.instance;

  @override
  Future<bool> isFirstRun() => _store.isFirstRun();

  @override
  Future<void> markFirstRunCompleted() => _store.markFirstRunCompleted();

  @override
  Future<List<Mechanic>> loadMechanics() async {
    final json = await _store.readJson(LocalStore.keyMechanics);
    if (json is! List) {
      return [];
    }

    bool needsMigration = false;
    final mechanics = <Mechanic>[];

    for (int i = 0; i < json.length; i++) {
      final raw = json[i];
      if (raw is Map) {
        final map = raw is Map<String, dynamic> ? raw : raw.cast<String, dynamic>();
        final mechanic = Mechanic.fromJson(map);
        if (mechanic.id.isEmpty || map['id'] == null || (map['id'] as String).isEmpty) {
          needsMigration = true;
          mechanics.add(mechanic.copyWith(id: 'mechanic_${DateTime.now().millisecondsSinceEpoch}_$i'));
        } else {
          if (map['createdAt'] == null || map['updatedAt'] == null) {
            needsMigration = true;
          }
          mechanics.add(mechanic);
        }
      }
    }

    if (needsMigration) {
      await saveMechanics(mechanics);
    }

    return mechanics;
  }

  @override
  Future<void> saveMechanics(List<Mechanic> mechanics) async {
    final now = DateTime.now().toUtc();
    final updated = mechanics.map((m) {
      return m.copyWith(
        id: m.effectiveId,
        createdAt: m.effectiveCreatedAt,
        updatedAt: now,
      );
    }).toList();

    await _store.writeJson(
      LocalStore.keyMechanics,
      updated.map((m) => m.toJson()).toList(),
    );
  }

  @override
  Future<void> deleteMechanic(String id) async {
    final current = await loadMechanics();
    final filtered = current.where((m) => m.effectiveId != id).toList();
    await saveMechanics(filtered);
  }

  @override
  Future<void> clear() async {
    await _store.writeJson(LocalStore.keyMechanics, null);
  }

  @override
  Future<void> flush() async {
    await _store.flush();
  }
}

MechanicRepository resolveMechanicRepository(dynamic source, [MechanicRepository? fallback]) {
  if (source is MechanicRepository) return source;
  if (source is LocalStore) return MechanicRepositoryLocal(source);
  return fallback ?? MechanicRepositoryLocal();
}
