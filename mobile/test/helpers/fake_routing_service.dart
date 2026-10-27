import 'package:camp/features/navigation/domain/routing_service.dart';
import 'package:latlong2/latlong.dart';

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
          streetName: 'Test Way',
          distanceMeters: 1600.0,
          durationSeconds: 180.0,
          location: start,
          instruction: 'Head out on Test Way',
        ),
        RouteStep(
          maneuverType: 'turn',
          maneuverModifier: 'right',
          streetName: 'Test Pass Rd',
          distanceMeters: 3800.0,
          durationSeconds: 480.0,
          location: mid,
          instruction: 'Turn right onto Test Pass Rd',
        ),
        RouteStep(
          maneuverType: 'arrive',
          streetName: 'Destination',
          distanceMeters: 0.0,
          durationSeconds: 0.0,
          location: end,
          instruction: 'Arrive at destination',
        ),
      ],
    );
  }
}
