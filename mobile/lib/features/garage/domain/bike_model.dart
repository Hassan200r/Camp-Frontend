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
    this.currentFuelLiters,
    this.lastOilChange,
    this.lastTuneUp,
    this.vin,
    this.nickname,
  });

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
    int? odometerKm,
    double? currentFuelLiters,
    ServiceRecord? lastOilChange,
    ServiceRecord? lastTuneUp,
    String? vin,
    String? nickname,
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
      odometerKm: odometerKm ?? this.odometerKm,
      currentFuelLiters: currentFuelLiters ?? this.currentFuelLiters,
      lastOilChange: lastOilChange ?? this.lastOilChange,
      lastTuneUp: lastTuneUp ?? this.lastTuneUp,
      vin: vin ?? this.vin,
      nickname: nickname ?? this.nickname,
    );
  }

  @override
  String toString() =>
      'Bike(id: $id, make: $make, modelName: $modelName, year: $modelYear, odo: $odometerKm)';
}
