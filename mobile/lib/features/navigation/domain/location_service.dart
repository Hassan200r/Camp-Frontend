import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Normalized snapshot of GPS position, heading, speed and accuracy.
class PositionData {
  const PositionData({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.heading,
    this.speed,
    this.accuracy,
    this.altitude,
  });

  final double latitude;
  final double longitude;

  /// Heading/bearing in degrees (0..360, where 0 is true north).
  final double? heading;

  /// Speed over ground in meters per second (m/s).
  final double? speed;

  /// Estimated horizontal accuracy in meters.
  final double? accuracy;

  /// Altitude in meters above mean sea level.
  final double? altitude;

  final DateTime timestamp;

  LatLng toLatLng() => LatLng(latitude, longitude);

  @override
  String toString() =>
      'PositionData(lat: $latitude, lon: $longitude, heading: $heading, speed: $speed m/s, accuracy: $accuracy m)';
}

/// Abstract interface for device location access and GPS telemetry streaming.
abstract class LocationService {
  Future<bool> isLocationServiceEnabled();
  Future<bool> checkPermission();
  Future<bool> requestPermission();
  Future<PositionData?> getCurrentPosition();
  Stream<PositionData> getPositionStream({bool highAccuracy = false});
  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
}

/// Production implementation backed by the [Geolocator] plugin.
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> checkPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<PositionData?> getCurrentPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return _mapPosition(pos);
    } catch (_) {
      // Fallback to last known position if immediate fix fails or times out
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return _mapPosition(last);
      } catch (_) {}
      return null;
    }
  }

  @override
  Stream<PositionData> getPositionStream({bool highAccuracy = false}) {
    final settings = LocationSettings(
      accuracy: highAccuracy ? LocationAccuracy.high : LocationAccuracy.medium,
      distanceFilter: highAccuracy ? 2 : 10,
    );
    return Geolocator.getPositionStream(locationSettings: settings)
        .map(_mapPosition);
  }

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  static PositionData _mapPosition(Position p) {
    return PositionData(
      latitude: p.latitude,
      longitude: p.longitude,
      heading: p.heading >= 0 ? p.heading : null,
      speed: p.speed >= 0 ? p.speed : null,
      accuracy: p.accuracy >= 0 ? p.accuracy : null,
      altitude: p.altitude,
      timestamp: p.timestamp,
    );
  }
}

/// Fake implementation of [LocationService] for testing.
class FakeLocationService implements LocationService {
  FakeLocationService({
    PositionData? initialPosition,
    this.hasPermission = true,
    this.serviceEnabled = true,
  }) : _currentPosition = initialPosition ??
            PositionData(
              latitude: 48.515,
              longitude: -120.690,
              heading: 45.0,
              speed: 16.7, // ~60 km/h
              accuracy: 5.0,
              timestamp: DateTime.now(),
            );

  PositionData? _currentPosition;
  bool hasPermission;
  bool serviceEnabled;
  final StreamController<PositionData> _controller =
      StreamController<PositionData>.broadcast();

  void emitPosition(PositionData position) {
    _currentPosition = position;
    _controller.add(position);
  }

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<bool> checkPermission() async => hasPermission;

  @override
  Future<bool> requestPermission() async => hasPermission;

  @override
  Future<PositionData?> getCurrentPosition() async => _currentPosition;

  @override
  Stream<PositionData> getPositionStream({bool highAccuracy = false}) {
    return _controller.stream;
  }

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;

  void dispose() {
    _controller.close();
  }
}
