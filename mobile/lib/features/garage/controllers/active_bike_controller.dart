import 'package:flutter/foundation.dart';

import '../../../core/storage/local_store.dart';
import '../domain/bike_model.dart';

/// Central state controller managing the rider's garage fleet and the current active telemetry rig.
/// Provides reactive state for both the Garage overview screen and individual BikeProfileScreens.
class ActiveBikeController extends ChangeNotifier {
  ActiveBikeController._() {
    _initializeDefaultFleet();
  }

  /// Shared singleton instance across the application.
  static final ActiveBikeController instance = ActiveBikeController._();

  /// Registered motorcycles in the rider's garage fleet.
  final List<Bike> _bikes = [];

  /// Unique identifier of the motorcycle currently selected as the active rig.
  String? _activeBikeId;

  // ── Getters ────────────────────────────────────────────────────────────────
  List<Bike> get bikes => List.unmodifiable(_bikes);

  String? get activeBikeId => _activeBikeId;

  Bike? get activeBike {
    if (_activeBikeId == null) {
      return _bikes.isNotEmpty ? _bikes.first : null;
    }
    return _bikes.cast<Bike?>().firstWhere(
          (b) => b?.id == _activeBikeId,
          orElse: () => _bikes.isNotEmpty ? _bikes.first : null,
        );
  }

  bool isActive(String bikeId) => _activeBikeId == bikeId;

  Bike? getBikeById(String id) {
    return _bikes.cast<Bike?>().firstWhere(
          (b) => b?.id == id,
          orElse: () => null,
        );
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Designate a motorcycle as the active telemetry rig.
  void setActiveBike(String bikeId) {
    if (_activeBikeId == bikeId) return;
    final exists = _bikes.any((b) => b.id == bikeId);
    if (exists) {
      _activeBikeId = bikeId;
      notifyListeners();
      save();
    }
  }

  /// Remove a motorcycle from the garage.
  /// If the removed bike was active, sets the active rig to the first remaining bike.
  void removeBike(String bikeId) {
    final index = _bikes.indexWhere((b) => b.id == bikeId);
    if (index != -1) {
      _bikes.removeAt(index);
      if (_activeBikeId == bikeId) {
        _activeBikeId = _bikes.isNotEmpty ? _bikes.first.id : null;
      }
      notifyListeners();
      save();
    }
  }

  /// Register a new motorcycle into the garage fleet.
  void addBike(Bike bike, {bool setActive = false}) {
    _bikes.add(bike);
    if (setActive || _bikes.length == 1) {
      _activeBikeId = bike.id;
    }
    notifyListeners();
    save();
  }

  /// Update specifications or telemetry milestone records of an existing bike.
  void updateBike(Bike updatedBike) {
    final index = _bikes.indexWhere((b) => b.id == updatedBike.id);
    if (index != -1) {
      _bikes[index] = updatedBike;
      notifyListeners();
      save();
    }
  }

  /// Reset the controller to default fleet state (useful for tests and mock reset).
  void reset() {
    _initializeDefaultFleet();
    notifyListeners();
  }

  /// Reset in-memory state for testing without persisting.
  void resetForTesting() {
    _bikes.clear();
    _activeBikeId = null;
    notifyListeners();
  }

  /// Await completion of all pending storage writes.
  Future<void> flush() => LocalStore.instance.flush();

  /// Load garage fleet and active bike selection from persistent store.
  Future<void> load([LocalStore? store]) async {
    final localStore = store ?? LocalStore.instance;
    final isFirst = await localStore.isFirstRun();

    if (isFirst) {
      _initializeDefaultFleet();
      await save(localStore);
      return;
    }

    try {
      final bikesJson = await localStore.readJson(LocalStore.keyBikes);
      final activeId = await localStore.readString(LocalStore.keyActiveBikeId);

      if (bikesJson == null || bikesJson is! List) {
        // Corrupted or missing data falls back to defaults without crashing
        _initializeDefaultFleet();
        notifyListeners();
        return;
      }

      final schemaVer = await localStore.getSchemaVersion();
      if (schemaVer == null || schemaVer > LocalStore.currentSchemaVersion) {
        _initializeDefaultFleet();
        notifyListeners();
        return;
      }

      final loadedBikes = <Bike>[];
      for (final item in bikesJson) {
        if (item is Map<String, dynamic>) {
          loadedBikes.add(Bike.fromJson(item));
        } else if (item is Map) {
          loadedBikes.add(Bike.fromJson(item.cast<String, dynamic>()));
        }
      }

      _bikes.clear();
      _bikes.addAll(loadedBikes);
      _activeBikeId = activeId;

      if (_bikes.isNotEmpty &&
          (_activeBikeId == null || !_bikes.any((b) => b.id == _activeBikeId))) {
        _activeBikeId = _bikes.first.id;
      }

      notifyListeners();
    } catch (_) {
      // Fallback without crashing
      _initializeDefaultFleet();
      notifyListeners();
    }
  }

  /// Persist current garage fleet and active bike selection.
  Future<void> save([LocalStore? store]) async {
    final localStore = store ?? LocalStore.instance;
    try {
      await localStore.writeJson(
        LocalStore.keyBikes,
        _bikes.map((b) => b.toJson()).toList(),
      );
      if (_activeBikeId != null) {
        await localStore.writeString(LocalStore.keyActiveBikeId, _activeBikeId!);
      } else {
        await localStore.remove(LocalStore.keyActiveBikeId);
      }
    } catch (_) {
      // Ignore background write errors
    }
  }

  void _initializeDefaultFleet() {
    _bikes.clear();
    _bikes.addAll([
      Bike(
        id: 'bike-bmw-1250',
        make: 'BMW',
        modelName: 'R 1250 GS Adventure',
        modelYear: 2023,
        displacement: 1254,
        bikeType: 'Adventure',
        fuelSystem: FuelSystem.efi,
        carburetorType: null,
        fuelTankCapacityLiters: 30.0,
        fuelAverageKmPerLiter: 22.5,
        ridingTerrain: const ['City', 'Highway', 'Off-road'],
        edition: 'Triple Black',
        imagePath: 'assets/images/bmw_r1250_scan_placeholder.jpg',
        odometerKm: 14820,
        fuelRemainingLiters: 23.4,
        lastFuelUpdate: DateTime(2026, 10, 1),
        currentFuelLiters: 23.4,
        lastOilChange: ServiceRecord(
          mode: TrackingMode.byDistance,
          km: 3200,
          date: DateTime(2026, 6, 1),
        ),
        lastTuneUp: ServiceRecord(
          mode: TrackingMode.byDistance,
          km: 5000,
          date: DateTime(2026, 6, 4),
        ),
        vin: 'WB10J9309PZE84102',
        nickname: 'GS #441',
      ),
      Bike(
        id: 'bike-rebel-500',
        make: 'Honda',
        modelName: 'Rebel 500',
        modelYear: 2022,
        displacement: 471,
        bikeType: 'Cruiser',
        fuelSystem: FuelSystem.carburetor,
        carburetorType: 'Keihin CVK',
        fuelTankCapacityLiters: 11.2,
        fuelAverageKmPerLiter: 26.0,
        ridingTerrain: const ['City', 'Highway'],
        edition: 'Special Edition',
        odometerKm: 4120,
        fuelRemainingLiters: 8.0,
        lastFuelUpdate: DateTime(2026, 10, 1),
        currentFuelLiters: 8.0,
        lastOilChange: ServiceRecord(
          mode: TrackingMode.byDistance,
          km: 3940,
          date: DateTime(2026, 2, 10),
        ),
        lastTuneUp: ServiceRecord(
          mode: TrackingMode.byDistance,
          km: 4000,
          date: DateTime(2026, 1, 15),
        ),
        vin: 'JH2PC5601NM000000',
        nickname: 'Urban Shadow',
      ),
    ]);
    _activeBikeId = 'bike-bmw-1250';
  }
}
