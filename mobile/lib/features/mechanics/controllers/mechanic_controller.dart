import 'package:flutter/foundation.dart';
import '../../../core/storage/local_store.dart';
import '../domain/mechanic_model.dart';

/// Central state controller managing mechanics and emergency field workshops.
/// Persisted locally via [LocalStore].
class MechanicController extends ChangeNotifier {
  MechanicController._();

  static final MechanicController instance = MechanicController._();

  final List<Mechanic> _mechanics = [];

  List<Mechanic> get mechanics => List.unmodifiable(_mechanics);

  void addMechanic(Mechanic mechanic) {
    _mechanics.insert(0, mechanic);
    notifyListeners();
    save();
  }

  void updateMechanic(Mechanic mechanic) {
    final index = _mechanics.indexWhere((m) => m.id == mechanic.id);
    if (index != -1) {
      _mechanics[index] = mechanic;
      notifyListeners();
      save();
    }
  }

  void editMechanic(Mechanic mechanic) => updateMechanic(mechanic);

  void deleteMechanic(String id) {
    _mechanics.removeWhere((m) => m.id == id);
    notifyListeners();
    save();
  }

  /// Await completion of all pending storage writes.
  Future<void> flush() => LocalStore.instance.flush();

  @visibleForTesting
  void resetForTesting() {
    _mechanics.clear();
    notifyListeners();
  }

  /// Load mechanics list from [LocalStore].
  /// Gated: sample data is seeded ONLY when isFirstRun() AND kDebugMode.
  Future<void> load([LocalStore? store]) async {
    final localStore = store ?? LocalStore.instance;
    final isFirst = await localStore.isFirstRun();

    if (isFirst) {
      if (kDebugMode) {
        _mechanics.clear();
        _mechanics.addAll(Mechanic.sampleMechanics);
      } else {
        _mechanics.clear();
      }
      await save(localStore);
      notifyListeners();
      return;
    }

    try {
      final json = await localStore.readJson(LocalStore.keyMechanics);
      if (json is List) {
        final loaded = <Mechanic>[];
        for (final item in json) {
          if (item is Map<String, dynamic>) {
            loaded.add(Mechanic.fromJson(item));
          } else if (item is Map) {
            loaded.add(Mechanic.fromJson(item.cast<String, dynamic>()));
          }
        }
        _mechanics.clear();
        _mechanics.addAll(loaded);
        notifyListeners();
      }
    } catch (_) {
      // Gracefully fall back
    }
  }

  /// Save mechanics list to [LocalStore].
  Future<void> save([LocalStore? store]) async {
    final localStore = store ?? LocalStore.instance;
    final list = _mechanics.map((m) => m.toJson()).toList();
    await localStore.writeJson(LocalStore.keyMechanics, list);
  }
}
