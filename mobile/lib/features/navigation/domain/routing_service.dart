import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../settings/domain/units_system.dart';

/// Public demo server URL. Replace with self-hosted OSRM cluster or API key in production.
const String kOsrmBaseUrl = 'https://router.project-osrm.org';

/// Single step / maneuver in a turn-by-turn route.
class RouteStep {
  const RouteStep({
    required this.maneuverType,
    required this.streetName,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.location,
    required this.instruction,
    this.maneuverModifier,
  });

  final String maneuverType; // depart, turn, new name, continue, arrive, fork, roundabout, etc.
  final String? maneuverModifier; // left, right, slight left, slight right, sharp left, sharp right, straight, uturn
  final String streetName;
  final double distanceMeters;
  final double durationSeconds;
  final LatLng location;
  final String instruction;

  /// Synthesize clean, natural spoken / written instruction from maneuver attributes.
  static String synthesizeInstruction({
    required String type,
    required String streetName,
    required double distanceMeters,
    String? modifier,
  }) {
    final cleanStreet = streetName.trim();
    final hasStreet = cleanStreet.isNotEmpty;
    final streetPhrase = hasStreet ? ' onto $cleanStreet' : '';
    final onStreetPhrase = hasStreet ? ' on $cleanStreet' : ' straight';

    switch (type.toLowerCase()) {
      case 'depart':
        return hasStreet ? 'Head out on $cleanStreet' : 'Head out';
      case 'arrive':
        return 'Arrive at destination';
      case 'turn':
        switch (modifier?.toLowerCase()) {
          case 'left':
            return 'Turn left$streetPhrase';
          case 'right':
            return 'Turn right$streetPhrase';
          case 'slight left':
            return 'Slight left$streetPhrase';
          case 'slight right':
            return 'Slight right$streetPhrase';
          case 'sharp left':
            return 'Sharp left$streetPhrase';
          case 'sharp right':
            return 'Sharp right$streetPhrase';
          case 'uturn':
            return 'Make a U-turn$streetPhrase';
          default:
            return 'Turn$streetPhrase';
        }
      case 'new name':
      case 'continue':
        return 'Continue$onStreetPhrase';
      case 'fork':
        if (modifier == 'left' || modifier == 'slight left') {
          return 'Keep left$streetPhrase';
        } else if (modifier == 'right' || modifier == 'slight right') {
          return 'Keep right$streetPhrase';
        }
        return 'Keep straight$streetPhrase';
      case 'roundabout':
        return 'Take roundabout$streetPhrase';
      case 'ramp':
        return 'Take the ramp$streetPhrase';
      case 'merge':
        return 'Merge$onStreetPhrase';
      default:
        return hasStreet ? 'Continue on $cleanStreet' : 'Continue straight';
    }
  }

  /// Appropriate icon for this maneuver.
  IconData get icon {
    final mod = maneuverModifier?.toLowerCase();
    switch (maneuverType.toLowerCase()) {
      case 'depart':
        return Icons.navigation_rounded;
      case 'arrive':
        return Icons.place_rounded;
      case 'turn':
        if (mod == 'left') return Icons.turn_left_rounded;
        if (mod == 'right') return Icons.turn_right_rounded;
        if (mod == 'slight left') return Icons.turn_slight_left_rounded;
        if (mod == 'slight right') return Icons.turn_slight_right_rounded;
        if (mod == 'sharp left') return Icons.turn_sharp_left_rounded;
        if (mod == 'sharp right') return Icons.turn_sharp_right_rounded;
        if (mod == 'uturn') return Icons.u_turn_left_rounded;
        return Icons.turn_right_rounded;
      case 'fork':
        if (mod == 'left' || mod == 'slight left') return Icons.fork_left_rounded;
        return Icons.fork_right_rounded;
      case 'roundabout':
        return Icons.roundabout_right_rounded;
      case 'ramp':
        return Icons.ramp_right_rounded;
      default:
        return Icons.straight_rounded;
    }
  }

  /// Formatted distance string based on units.
  String formattedDistance(UnitsSystem units) {
    if (units == UnitsSystem.imperial) {
      final miles = distanceMeters / 1609.344;
      if (miles < 0.1) {
        final feet = (distanceMeters * 3.28084).round();
        return '$feet ft';
      }
      return '${miles.toStringAsFixed(1)} mi';
    } else {
      if (distanceMeters < 1000) {
        return '${distanceMeters.round()} m';
      }
      final km = distanceMeters / 1000.0;
      return '${km.toStringAsFixed(1)} km';
    }
  }
}

/// Complete routing calculation result including full polyline, metrics, and turn steps.
class RouteResult {
  const RouteResult({
    required this.polyline,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.steps,
    this.alternatePolyline,
    this.alternateDurationSeconds,
  });

  final List<LatLng> polyline;
  final double distanceMeters;
  final double durationSeconds;
  final List<RouteStep> steps;

  /// Optional alternate route polyline (rendered in subtle gray).
  final List<LatLng>? alternatePolyline;
  final double? alternateDurationSeconds;

  /// Formatted duration string (e.g. "11 min", "1h 8m").
  String get formattedDuration {
    final totalMinutes = (durationSeconds / 60).round();
    if (totalMinutes < 60) {
      return '$totalMinutes min';
    }
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }

  /// Formatted distance string according to active [UnitsSystem].
  String formattedDistance(UnitsSystem units) {
    if (units == UnitsSystem.imperial) {
      final miles = distanceMeters / 1609.344;
      return '${miles.toStringAsFixed(1)} mi';
    } else {
      final km = distanceMeters / 1000.0;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  /// Distance in kilometers.
  double get distanceKm => distanceMeters / 1000.0;

  /// Distance in miles.
  double get distanceMiles => distanceMeters / 1609.344;
}

/// Abstract routing engine interface.
abstract class RoutingService {
  /// Calculate route passing through [waypoints] (must have at least 2 points: start and end).
  /// Intermediate points act as via-stops.
  Future<RouteResult> getRoute({
    required List<LatLng> waypoints,
    bool requestAlternatives = true,
  });
}

/// Production implementation backed by the Open Source Routing Machine (OSRM).
class OsrmRoutingService implements RoutingService {
  OsrmRoutingService({
    this.baseUrl = kOsrmBaseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  @override
  Future<RouteResult> getRoute({
    required List<LatLng> waypoints,
    bool requestAlternatives = true,
  }) async {
    if (waypoints.length < 2) {
      throw ArgumentError('At least 2 waypoints required for routing.');
    }

    // Coordinates format: {lon},{lat};{lon},{lat}...
    final coordsString = waypoints
        .map((p) => '${p.longitude.toStringAsFixed(6)},${p.latitude.toStringAsFixed(6)}')
        .join(';');

    final uri = Uri.parse(
      '$baseUrl/route/v1/driving/$coordsString?overview=full&geometries=geojson&steps=true${requestAlternatives ? '&alternatives=true' : ''}',
    );

    try {
      final response = await _httpClient.get(
        uri,
        headers: {
          'User-Agent': 'CAMP-App/1.0 (Mobile Navigation)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        throw Exception(
          'Routing server error (${response.statusCode}): ${response.reasonPhrase}',
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['code'] != 'Ok') {
        throw Exception(data['message'] ?? 'Routing calculation failed');
      }

      return parseOsrmResponse(data);
    } on http.ClientException {
      throw Exception('Route needs an internet connection');
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception('Route needs an internet connection');
      }
      rethrow;
    }
  }

  /// Parses OSRM JSON response payload into a strongly-typed [RouteResult].
  static RouteResult parseOsrmResponse(Map<String, dynamic> data) {
    final routes = data['routes'] as List<dynamic>;
    if (routes.isEmpty) {
      throw Exception('No routes found in OSRM response');
    }

    final primaryRoute = routes.first as Map<String, dynamic>;
    final distance = (primaryRoute['distance'] as num).toDouble();
    final duration = (primaryRoute['duration'] as num).toDouble();

    // Primary polyline coordinates [lon, lat]
    final geometry = primaryRoute['geometry'] as Map<String, dynamic>;
    final coordList = geometry['coordinates'] as List<dynamic>;
    final polyline = coordList.map((pt) {
      final lon = (pt[0] as num).toDouble();
      final lat = (pt[1] as num).toDouble();
      return LatLng(lat, lon);
    }).toList();

    // Turn steps across all legs
    final steps = <RouteStep>[];
    final legs = primaryRoute['legs'] as List<dynamic>? ?? [];
    for (final leg in legs) {
      final legSteps = leg['steps'] as List<dynamic>? ?? [];
      for (final s in legSteps) {
        final maneuver = s['maneuver'] as Map<String, dynamic>? ?? {};
        final type = (maneuver['type'] as String?) ?? 'continue';
        final modifier = maneuver['modifier'] as String?;
        final locCoords = maneuver['location'] as List<dynamic>?;
        final loc = (locCoords != null && locCoords.length >= 2)
            ? LatLng((locCoords[1] as num).toDouble(), (locCoords[0] as num).toDouble())
            : (polyline.isNotEmpty ? polyline.first : const LatLng(0, 0));

        final name = (s['name'] as String?) ?? '';
        final stepDist = (s['distance'] as num?)?.toDouble() ?? 0.0;
        final stepDuration = (s['duration'] as num?)?.toDouble() ?? 0.0;

        final instruction = RouteStep.synthesizeInstruction(
          type: type,
          modifier: modifier,
          streetName: name,
          distanceMeters: stepDist,
        );

        steps.add(
          RouteStep(
            maneuverType: type,
            maneuverModifier: modifier,
            streetName: name,
            distanceMeters: stepDist,
            durationSeconds: stepDuration,
            location: loc,
            instruction: instruction,
          ),
        );
      }
    }

    // Parse alternate route if present
    List<LatLng>? alternatePolyline;
    double? alternateDuration;
    if (routes.length > 1) {
      final alt = routes[1] as Map<String, dynamic>;
      alternateDuration = (alt['duration'] as num?)?.toDouble();
      final altGeom = alt['geometry'] as Map<String, dynamic>?;
      if (altGeom != null && altGeom['coordinates'] is List) {
        final altCoords = altGeom['coordinates'] as List<dynamic>;
        alternatePolyline = altCoords.map((pt) {
          final lon = (pt[0] as num).toDouble();
          final lat = (pt[1] as num).toDouble();
          return LatLng(lat, lon);
        }).toList();
      }
    }

    return RouteResult(
      polyline: polyline,
      distanceMeters: distance,
      durationSeconds: duration,
      steps: steps,
      alternatePolyline: alternatePolyline,
      alternateDurationSeconds: alternateDuration,
    );
  }
}

/// Fake implementation of [RoutingService] for unit and widget testing.
class FakeRoutingService implements RoutingService {
  FakeRoutingService({
    this.cannedResult,
    this.shouldThrow = false,
    this.errorMessage = 'Route needs an internet connection',
  });

  RouteResult? cannedResult;
  bool shouldThrow;
  String errorMessage;

  @override
  Future<RouteResult> getRoute({
    required List<LatLng> waypoints,
    bool requestAlternatives = true,
  }) async {
    if (shouldThrow) {
      throw Exception(errorMessage);
    }

    if (cannedResult != null) {
      return cannedResult!;
    }

    // Generate a simple synthetic route between the waypoints
    final start = waypoints.first;
    final end = waypoints.last;
    final mid = LatLng(
      (start.latitude + end.latitude) / 2 + 0.005,
      (start.longitude + end.longitude) / 2 + 0.005,
    );

    final line = [start, mid, end];
    return RouteResult(
      polyline: line,
      distanceMeters: 5400.0,
      durationSeconds: 660.0, // 11 min
      steps: [
        RouteStep(
          maneuverType: 'depart',
          streetName: 'Cascade Alpine Way',
          distanceMeters: 1600.0,
          durationSeconds: 180.0,
          location: start,
          instruction: 'Head out on Cascade Alpine Way',
        ),
        RouteStep(
          maneuverType: 'turn',
          maneuverModifier: 'right',
          streetName: 'Bear Creek Pass Rd',
          distanceMeters: 3800.0,
          durationSeconds: 480.0,
          location: mid,
          instruction: 'Turn right onto Bear Creek Pass Rd',
        ),
        RouteStep(
          maneuverType: 'arrive',
          streetName: 'Timber Ridge Moto Outpost',
          distanceMeters: 0.0,
          durationSeconds: 0.0,
          location: end,
          instruction: 'Arrive at destination',
        ),
      ],
    );
  }
}
