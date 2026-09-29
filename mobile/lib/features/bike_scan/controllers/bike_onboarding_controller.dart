import 'package:flutter/foundation.dart';

import '../../garage/domain/bike_model.dart';

/// Controller that preserves motorcycle onboarding form state across screens
/// (e.g. when backing out to registration options or arriving from optical AI scan).
class BikeOnboardingController extends ChangeNotifier {
  BikeOnboardingController._();

  /// Shared singleton instance.
  static final BikeOnboardingController instance = BikeOnboardingController._();

  String _make = 'Honda';
  String _modelName = '';
  int _modelYear = 2024;
  int? _displacement = 1100;
  String _bikeType = 'Adventure';
  FuelSystem _fuelSystem = FuelSystem.carburetor;
  String? _carburetorType;
  double? _fuelTankCapacityLiters;
  int? _odometerKm;
  double? _currentFuelLiters;
  ServiceRecord _lastOilChange = const ServiceRecord(
    mode: TrackingMode.byDistance,
    km: 3200,
  );
  ServiceRecord _lastTuneUp = const ServiceRecord(
    mode: TrackingMode.byDistance,
    km: 5000,
  );
  String? _vin;
  String? _nickname;

  // ── Getters ────────────────────────────────────────────────────────────────
  String get make => _make;
  String get modelName => _modelName;
  int get modelYear => _modelYear;
  int? get displacement => _displacement;
  String get bikeType => _bikeType;
  FuelSystem get fuelSystem => _fuelSystem;
  String? get carburetorType => _carburetorType;
  double? get fuelTankCapacityLiters => _fuelTankCapacityLiters;
  int? get odometerKm => _odometerKm;
  double? get currentFuelLiters => _currentFuelLiters;
  ServiceRecord get lastOilChange => _lastOilChange;
  ServiceRecord get lastTuneUp => _lastTuneUp;
  String? get vin => _vin;
  String? get nickname => _nickname;

  /// Whether the 4 mandatory gating fields are populated and valid:
  /// 1. Make
  /// 2. Model Name
  /// 3. Model Year
  /// 4. Current Odometer
  bool get isFormValid {
    return _make.trim().isNotEmpty &&
        _modelName.trim().isNotEmpty &&
        _modelYear > 1900 &&
        _odometerKm != null &&
        _odometerKm! >= 0;
  }

  // ── Setters & Updaters ─────────────────────────────────────────────────────
  void setMake(String value) {
    if (_make == value) return;
    _make = value;
    notifyListeners();
  }

  void setModelName(String value) {
    if (_modelName == value) return;
    _modelName = value;
    notifyListeners();
  }

  void setModelYear(int value) {
    if (_modelYear == value) return;
    _modelYear = value;
    notifyListeners();
  }

  void setDisplacement(int? value) {
    if (_displacement == value) return;
    _displacement = value;
    notifyListeners();
  }

  void setBikeType(String value) {
    if (_bikeType == value) return;
    _bikeType = value;
    notifyListeners();
  }

  void setFuelSystem(FuelSystem value) {
    if (_fuelSystem == value) return;
    _fuelSystem = value;
    if (_fuelSystem == FuelSystem.efi) {
      _carburetorType = null;
    }
    notifyListeners();
  }

  void setCarburetorType(String? value) {
    if (_carburetorType == value) return;
    _carburetorType = value;
    notifyListeners();
  }

  void setFuelTankCapacity(double? value) {
    if (_fuelTankCapacityLiters == value) return;
    _fuelTankCapacityLiters = value;
    notifyListeners();
  }

  void setOdometerKm(int? value) {
    if (_odometerKm == value) return;
    _odometerKm = value;
    notifyListeners();
  }

  void setCurrentFuelLiters(double? value) {
    if (_currentFuelLiters == value) return;
    _currentFuelLiters = value;
    notifyListeners();
  }

  void setLastOilChange(ServiceRecord record) {
    _lastOilChange = record;
    notifyListeners();
  }

  void setLastTuneUp(ServiceRecord record) {
    _lastTuneUp = record;
    notifyListeners();
  }

  void setVin(String? value) {
    if (_vin == value) return;
    _vin = value;
    notifyListeners();
  }

  void setNickname(String? value) {
    if (_nickname == value) return;
    _nickname = value;
    notifyListeners();
  }

  /// Populate fields from an optical scan or photo analysis result.
  void populateFromScan({
    required String rawModel,
    required String rawVin,
    required String rawMileage,
    required String rawDisplacement,
  }) {
    // Attempt parse make from rawModel
    const knownMakes = [
      'Honda',
      'BMW',
      'Ducati',
      'KTM',
      'Yamaha',
      'Kawasaki',
      'Suzuki',
      'Triumph',
      'Harley-Davidson',
      'Royal Enfield',
    ];

    String detectedMake = _make;
    String detectedModel = rawModel.trim();

    for (final make in knownMakes) {
      if (rawModel.toLowerCase().startsWith(make.toLowerCase())) {
        detectedMake = make;
        detectedModel = rawModel.substring(make.length).trim();
        break;
      }
    }

    _make = detectedMake;
    _modelName = detectedModel.isNotEmpty ? detectedModel : rawModel;

    // Parse displacement (e.g. "1254 cc" or "1100")
    final dispDigits = RegExp(r'\d+').firstMatch(rawDisplacement)?.group(0);
    if (dispDigits != null) {
      _displacement = int.tryParse(dispDigits) ?? _displacement;
    }

    // Parse mileage (e.g. "14,820 km" -> 14820)
    final cleanMileage = rawMileage.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanMileage.isNotEmpty) {
      _odometerKm = int.tryParse(cleanMileage) ?? _odometerKm;
    }

    if (rawVin.isNotEmpty && rawVin != 'N/A') {
      _vin = rawVin;
    }

    _fuelSystem = FuelSystem.efi;
    notifyListeners();
  }

  /// Construct the immutable Bike model from current form state.
  Bike buildBike({String? id}) {
    return Bike(
      id: id ?? 'bike-${DateTime.now().millisecondsSinceEpoch}',
      make: _make,
      modelName: _modelName,
      modelYear: _modelYear,
      displacement: _displacement,
      bikeType: _bikeType,
      fuelSystem: _fuelSystem,
      carburetorType: _fuelSystem == FuelSystem.carburetor ? _carburetorType : null,
      fuelTankCapacityLiters: _fuelTankCapacityLiters,
      odometerKm: _odometerKm ?? 0,
      currentFuelLiters: _currentFuelLiters,
      lastOilChange: _lastOilChange,
      lastTuneUp: _lastTuneUp,
      vin: _vin,
      nickname: _nickname,
    );
  }

  /// Reset form state to defaults.
  void reset() {
    _make = 'Honda';
    _modelName = '';
    _modelYear = 2024;
    _displacement = 1100;
    _bikeType = 'Adventure';
    _fuelSystem = FuelSystem.carburetor;
    _carburetorType = null;
    _fuelTankCapacityLiters = null;
    _odometerKm = null;
    _currentFuelLiters = null;
    _lastOilChange = const ServiceRecord(
      mode: TrackingMode.byDistance,
      km: 3200,
    );
    _lastTuneUp = const ServiceRecord(
      mode: TrackingMode.byDistance,
      km: 5000,
    );
    _vin = null;
    _nickname = null;
    notifyListeners();
  }
}
