import 'package:flutter/foundation.dart';

/// Fuel delivery system types for a motorcycle.
enum FuelSystem {
  carburetor,
  efi,
}

/// Mode selection for recording last serviced milestone.
enum TrackingMode {
  byDistance,
  byDate,
}

/// Value object representing a service milestone (distance or calendar date).
@immutable
class ServiceRecord {
  const ServiceRecord({
    this.mode = TrackingMode.byDistance,
    this.km,
    this.date,
  });

  factory ServiceRecord.fromJson(Map<String, dynamic> json) {
    return ServiceRecord(
      mode: json['mode'] == 'byDate'
          ? TrackingMode.byDate
          : TrackingMode.byDistance,
      km: json['km'] as int?,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String)
          : null,
    );
  }

  final TrackingMode mode;
  final int? km;
  final DateTime? date;

  ServiceRecord copyWith({
    TrackingMode? mode,
    int? km,
    DateTime? date,
  }) {
    return ServiceRecord(
      mode: mode ?? this.mode,
      km: km ?? this.km,
      date: date ?? this.date,
    );
  }

  @override
  String toString() => 'ServiceRecord(mode: $mode, km: $km, date: $date)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceRecord &&
          runtimeType == other.runtimeType &&
          mode == other.mode &&
          km == other.km &&
          date == other.date;

  @override
  int get hashCode => Object.hash(mode, km, date);

  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        'km': km,
        'date': date?.toIso8601String(),
      };
}

/// Motorcycle domain model representing a registered vehicle in CAMP.
@immutable
class Bike {
  const Bike({
    required this.id,
    required this.make,
    required this.modelName,
    required this.modelYear,
    required this.odometerKm,
    this.displacement,
    this.bikeType,
    this.fuelSystem = FuelSystem.carburetor,
    this.carburetorType,
    this.fuelTankCapacityLiters,
    this.fuelAverageKmPerLiter,
    this.ridingTerrain,
    this.edition,
    this.imagePath,
    this.currentFuelLiters,
    this.lastOilChange,
    this.lastTuneUp,
    this.vin,
    this.nickname,
    this.lastUpdated,
  });

  factory Bike.fromJson(Map<String, dynamic> json) {
    return Bike(
      id: json['id'] as String,
      make: json['make'] as String? ?? 'Unknown',
      modelName: json['modelName'] as String? ?? 'Unknown',
      modelYear: json['modelYear'] as int? ?? DateTime.now().year,
      odometerKm: json['odometerKm'] as int? ?? 0,
      displacement: json['displacement'] as int?,
      bikeType: json['bikeType'] as String?,
      fuelSystem: json['fuelSystem'] == 'efi'
          ? FuelSystem.efi
          : FuelSystem.carburetor,
      carburetorType: json['carburetorType'] as String?,
      fuelTankCapacityLiters:
          (json['fuelTankCapacityLiters'] as num?)?.toDouble(),
      fuelAverageKmPerLiter:
          (json['fuelAverageKmPerLiter'] as num?)?.toDouble(),
      ridingTerrain: (json['ridingTerrain'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      edition: json['edition'] as String?,
      imagePath: json['imagePath'] as String?,
      currentFuelLiters: (json['currentFuelLiters'] as num?)?.toDouble(),
      lastOilChange: json['lastOilChange'] != null
          ? ServiceRecord.fromJson(
              Map<String, dynamic>.from(json['lastOilChange'] as Map))
          : null,
      lastTuneUp: json['lastTuneUp'] != null
          ? ServiceRecord.fromJson(
              Map<String, dynamic>.from(json['lastTuneUp'] as Map))
          : null,
      vin: json['vin'] as String?,
      nickname: json['nickname'] as String?,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String)
          : null,
    );
  }

  /// Unique identifier for the bike.
  final String id;

  /// Manufacturer/Make (e.g. Honda, BMW, Yamaha).
  final String make;

  /// Specific model name (e.g. Africa Twin, CB650R).
  final String modelName;

  /// Model production year (e.g. 2024).
  final int modelYear;

  /// Displacement in cubic centimeters (cc).
  final int? displacement;

  /// Category/classification (e.g. Adventure, Commuter, Sport, Cruiser, Scooter, Electric).
  final String? bikeType;

  /// Fuel delivery system (Carburetor or Fuel Injection EFI).
  final FuelSystem fuelSystem;

  /// Carburetor brand/spec (e.g. Mikuni, Keihin, CV) — only valid if fuelSystem == carburetor.
  final String? carburetorType;

  /// Total fuel tank capacity in liters.
  final double? fuelTankCapacityLiters;

  /// User reported average fuel consumption in km per liter.
  final double? fuelAverageKmPerLiter;

  /// Configured primary riding terrain types (e.g. City, Highway, Off-road, Mountain).
  final List<String>? ridingTerrain;

  /// Special trim or edition name (e.g. Edition Triple Black).
  final String? edition;

  /// Local asset image path or remote URL for bike photograph.
  final String? imagePath;

  /// Mandatory operational field: current total odometer reading in km.
  final int odometerKm;

  /// Current estimated fuel volume in liters.
  final double? currentFuelLiters;

  /// Last oil change milestone (either distance in km or date).
  final ServiceRecord? lastOilChange;

  /// Last comprehensive tune-up milestone (either distance in km or date).
  final ServiceRecord? lastTuneUp;

  /// Serial / Vehicle Identification Number (VIN).
  final String? vin;

  /// Optional rider nickname for the motorcycle (e.g. Black Beast).
  final String? nickname;

  /// Timestamp of when the motorcycle profile/mileage/service was last updated.
  final DateTime? lastUpdated;

  /// Friendly display name (nickname if present, else "$make $modelName").
  String get name =>
      nickname?.isNotEmpty == true ? nickname! : '$make $modelName';

  /// Convenience getter for modelYear.
  int get year => modelYear;

  /// Fallback getter ensuring a non-null timestamp for relative time display.
  DateTime get lastUpdatedAt =>
      lastUpdated ?? DateTime.now().subtract(const Duration(hours: 2, minutes: 15));

  Bike copyWith({
    String? id,
    String? make,
    String? modelName,
    int? modelYear,
    int? displacement,
    String? bikeType,
    FuelSystem? fuelSystem,
    String? carburetorType,
    double? fuelTankCapacityLiters,
    double? fuelAverageKmPerLiter,
    List<String>? ridingTerrain,
    String? edition,
    String? imagePath,
    int? odometerKm,
    double? currentFuelLiters,
    ServiceRecord? lastOilChange,
    ServiceRecord? lastTuneUp,
    String? vin,
    String? nickname,
    DateTime? lastUpdated,
  }) {
    return Bike(
      id: id ?? this.id,
      make: make ?? this.make,
      modelName: modelName ?? this.modelName,
      modelYear: modelYear ?? this.modelYear,
      displacement: displacement ?? this.displacement,
      bikeType: bikeType ?? this.bikeType,
      fuelSystem: fuelSystem ?? this.fuelSystem,
      carburetorType: carburetorType ?? this.carburetorType,
      fuelTankCapacityLiters:
          fuelTankCapacityLiters ?? this.fuelTankCapacityLiters,
      fuelAverageKmPerLiter:
          fuelAverageKmPerLiter ?? this.fuelAverageKmPerLiter,
      ridingTerrain: ridingTerrain ?? this.ridingTerrain,
      edition: edition ?? this.edition,
      imagePath: imagePath ?? this.imagePath,
      odometerKm: odometerKm ?? this.odometerKm,
      currentFuelLiters: currentFuelLiters ?? this.currentFuelLiters,
      lastOilChange: lastOilChange ?? this.lastOilChange,
      lastTuneUp: lastTuneUp ?? this.lastTuneUp,
      vin: vin ?? this.vin,
      nickname: nickname ?? this.nickname,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() =>
      'Bike(id: $id, make: $make, modelName: $modelName, year: $modelYear, odo: $odometerKm)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bike &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          make == other.make &&
          modelName == other.modelName &&
          modelYear == other.modelYear &&
          displacement == other.displacement &&
          bikeType == other.bikeType &&
          fuelSystem == other.fuelSystem &&
          carburetorType == other.carburetorType &&
          fuelTankCapacityLiters == other.fuelTankCapacityLiters &&
          fuelAverageKmPerLiter == other.fuelAverageKmPerLiter &&
          listEquals(ridingTerrain, other.ridingTerrain) &&
          edition == other.edition &&
          imagePath == other.imagePath &&
          odometerKm == other.odometerKm &&
          currentFuelLiters == other.currentFuelLiters &&
          lastOilChange == other.lastOilChange &&
          lastTuneUp == other.lastTuneUp &&
          vin == other.vin &&
          nickname == other.nickname &&
          lastUpdated == other.lastUpdated;

  @override
  int get hashCode => Object.hashAll([
        id,
        make,
        modelName,
        modelYear,
        displacement,
        bikeType,
        fuelSystem,
        carburetorType,
        fuelTankCapacityLiters,
        fuelAverageKmPerLiter,
        ridingTerrain == null ? null : Object.hashAll(ridingTerrain!),
        edition,
        imagePath,
        odometerKm,
        currentFuelLiters,
        lastOilChange,
        lastTuneUp,
        vin,
        nickname,
        lastUpdated,
      ]);

  Map<String, dynamic> toJson() => {
        'id': id,
        'make': make,
        'modelName': modelName,
        'modelYear': modelYear,
        'odometerKm': odometerKm,
        'displacement': displacement,
        'bikeType': bikeType,
        'fuelSystem': fuelSystem.name,
        'carburetorType': carburetorType,
        'fuelTankCapacityLiters': fuelTankCapacityLiters,
        'fuelAverageKmPerLiter': fuelAverageKmPerLiter,
        'ridingTerrain': ridingTerrain,
        'edition': edition,
        'imagePath': imagePath,
        'currentFuelLiters': currentFuelLiters,
        'lastOilChange': lastOilChange?.toJson(),
        'lastTuneUp': lastTuneUp?.toJson(),
        'vin': vin,
        'nickname': nickname,
        'lastUpdated': lastUpdated?.toIso8601String(),
      };
}
