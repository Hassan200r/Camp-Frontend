import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';

import '../../navigation/domain/location_service.dart';
import '../controllers/active_bike_controller.dart';
import '../domain/fuel_estimator.dart';
import 'fuel_notification_service.dart';

/// Central singleton service tracking live motorcycle rides, accumulating distance,
/// updating the active bike's odometer and fuel estimate in real time, and alerting
/// riders on low fuel.
class FuelTrackerService extends ChangeNotifier with WidgetsBindingObserver {
  FuelTrackerService({
    LocationService? locationService,
    ActiveBikeController? bikeController,
    FuelNotificationService? notificationService,
  })  : _locationService = locationService ?? const GeolocatorLocationService(),
        _bikeController = bikeController ?? ActiveBikeController.instance,
        _notificationService =
            notificationService ?? FuelNotificationService() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Global singleton instance.
  static final FuelTrackerService instance = FuelTrackerService();

  LocationService _locationService;
  ActiveBikeController _bikeController;
  FuelNotificationService _notificationService;

  StreamSubscription<PositionData>? _positionSubscription;
  Timer? _throttleSaveTimer;
  PositionData? _lastAcceptedPosition;

  bool _isRiding = false;
  double _rideDistanceKm = 0.0;
  String? _locationErrorMessage;
  bool _hasShownLowFuelNotification = false;
  bool _hasRequestedNotificationPermission = false;
  bool _hasUnsavedChanges = false;

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isRiding => _isRiding;
  double get rideDistanceKm => _rideDistanceKm;
  String? get locationErrorMessage => _locationErrorMessage;
  bool get hasShownLowFuelNotification => _hasShownLowFuelNotification;
  bool get notificationPermissionGranted =>
      _notificationService.notificationPermissionGranted;

  /// Whether an in-app low fuel warning banner should be shown on the Active Rig card.
  bool get isLowFuelWarningActive {
    final bike = _bikeController.activeBike;
    if (bike == null) return false;
    final pct = FuelEstimator.percent(
      bike.fuelRemainingLiters,
      bike.fuelTankCapacityLiters,
    );
    return pct != null && pct < 15.0;
  }

  // ── Testing Hooks ──────────────────────────────────────────────────────────
  void setDependenciesForTesting({
    LocationService? locationService,
    ActiveBikeController? bikeController,
    FuelNotificationService? notificationService,
  }) {
    if (locationService != null) _locationService = locationService;
    if (bikeController != null) _bikeController = bikeController;
    if (notificationService != null) _notificationService = notificationService;
  }

  void resetForTesting() {
    _positionSubscription?.cancel();
    _throttleSaveTimer?.cancel();
    _isRiding = false;
    _rideDistanceKm = 0.0;
    _locationErrorMessage = null;
    _hasShownLowFuelNotification = false;
    _hasRequestedNotificationPermission = false;
    _hasUnsavedChanges = false;
    _lastAcceptedPosition = null;
    notifyListeners();
  }

  // ── Ride Lifecycle ─────────────────────────────────────────────────────────

  /// Toggle start/stop ride status.
  Future<bool> toggleRide() async {
    if (_isRiding) {
      await stopRide();
      return false;
    } else {
      return await startRide();
    }
  }

  /// Start live ride distance tracking and fuel estimation.
  Future<bool> startRide() async {
    if (_isRiding) return true;

    _locationErrorMessage = null;

    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _locationErrorMessage =
          'Location service is disabled. Please enable GPS in device settings.';
      notifyListeners();
      return false;
    }

    final hasPermission = await _locationService.checkPermission();
    if (!hasPermission) {
      final granted = await _locationService.requestPermission();
      if (!granted) {
        _locationErrorMessage =
            'Location permission is required for live ride and fuel tracking.';
        notifyListeners();
        return false;
      }
    }

    if (!_hasRequestedNotificationPermission) {
      _hasRequestedNotificationPermission = true;
      try {
        await _notificationService.requestPermission();
      } catch (_) {}
    }

    final bike = _bikeController.activeBike;
    if (bike != null) {
      final pct = FuelEstimator.percent(
        bike.fuelRemainingLiters,
        bike.fuelTankCapacityLiters,
      );
      if (pct != null && pct < 15.0) {
        _hasShownLowFuelNotification = true;
      }
    }

    _isRiding = true;
    _lastAcceptedPosition = null;

    _positionSubscription = _locationService
        .getPositionStream(
          highAccuracy: true,
          enableForegroundNotification: true,
        )
        .listen(handlePositionUpdate);

    _throttleSaveTimer?.cancel();
    _throttleSaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _flushPendingBikeSave(),
    );

    notifyListeners();
    return true;
  }

  /// Stop live ride tracking and flush all pending state to persistent storage.
  Future<void> stopRide() async {
    if (!_isRiding) return;

    _isRiding = false;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _throttleSaveTimer?.cancel();
    _throttleSaveTimer = null;
    _lastAcceptedPosition = null;

    await flush();
    notifyListeners();
  }

  // ── Position Processing & Distance Filtering ───────────────────────────────

  /// Process incoming location fix and accumulate valid movement.
  void handlePositionUpdate(PositionData position) {
    if (!_isRiding) return;

    // 1. Ignore fixes with accuracy > 30 m
    if (position.accuracy != null && position.accuracy! > 30.0) {
      return;
    }

    // Baseline fix establishing initial coordinate
    if (_lastAcceptedPosition == null) {
      _lastAcceptedPosition = position;
      return;
    }

    final distMeters = Geolocator.distanceBetween(
      _lastAcceptedPosition!.latitude,
      _lastAcceptedPosition!.longitude,
      position.latitude,
      position.longitude,
    );

    final timeElapsedSeconds = position.timestamp
            .difference(_lastAcceptedPosition!.timestamp)
            .inMilliseconds /
        1000.0;

    // 2. Ignore movement under 5 m or speed under 1 m/s (GPS jitter while parked)
    if (distMeters < 5.0) return;
    if (position.speed != null && position.speed! < 1.0) return;
    if (timeElapsedSeconds > 0 && (distMeters / timeElapsedSeconds) < 1.0) {
      return;
    }

    // 3. Ignore implausible jumps (speed > 200 km/h = ~55.56 m/s)
    if (position.speed != null && position.speed! > 55.56) return;
    if (timeElapsedSeconds > 0 && (distMeters / timeElapsedSeconds) > 55.56) {
      return;
    }

    // Valid movement segment accepted
    _lastAcceptedPosition = position;
    final segmentKm = distMeters / 1000.0;
    _rideDistanceKm += segmentKm;

    _applyDistanceToActiveBike(segmentKm);
  }

  void _applyDistanceToActiveBike(double segmentKm) {
    final bike = _bikeController.activeBike;
    if (bike == null) return;

    final updatedLiters = FuelEstimator.applyDistance(
      bike.fuelRemainingLiters,
      segmentKm,
      bike.fuelAverageKmPerLiter,
    );

    final currentPreciseOdo =
        bike.preciseOdometerKm ?? bike.odometerKm.toDouble();
    final newPreciseOdo =
        double.parse((currentPreciseOdo + segmentKm).toStringAsFixed(1));

    // Check low-fuel crossing below 15%
    final pct = FuelEstimator.percent(
      updatedLiters,
      bike.fuelTankCapacityLiters,
    );
    final range = FuelEstimator.rangeKm(
      updatedLiters,
      bike.fuelAverageKmPerLiter,
    );

    if (pct != null && pct < 15.0) {
      if (!_hasShownLowFuelNotification) {
        _hasShownLowFuelNotification = true;
        if (range != null) {
          _notificationService.showLowFuelAlert(rangeKm: range.round());
        }
      }
    } else if (pct != null && pct >= 15.0) {
      _hasShownLowFuelNotification = false;
    }

    final updatedBike = bike.copyWith(
      fuelRemainingLiters: updatedLiters,
      odometerKm: newPreciseOdo.round(),
      preciseOdometerKm: newPreciseOdo,
      lastFuelUpdate: DateTime.now(),
    );

    _bikeController.updateBike(updatedBike);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  /// Resets the low fuel single-trigger notification flag (e.g. after a refill).
  void resetLowFuelFlag() {
    _hasShownLowFuelNotification = false;
    notifyListeners();
  }

  // ── Persistence & Lifecycle ────────────────────────────────────────────────

  void _flushPendingBikeSave() {
    if (_hasUnsavedChanges) {
      _hasUnsavedChanges = false;
      _bikeController.save();
    }
  }

  /// Explicitly flushes any pending writes to persistent storage.
  Future<void> flush() async {
    _hasUnsavedChanges = false;
    await _bikeController.save();
    await _bikeController.flush();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      flush();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionSubscription?.cancel();
    _throttleSaveTimer?.cancel();
    flush();
    super.dispose();
  }
}
