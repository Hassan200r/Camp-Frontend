import 'dart:async';

import 'package:camp/features/garage/controllers/active_bike_controller.dart';
import 'package:camp/features/navigation/controllers/navigation_controller.dart';
import 'package:camp/features/navigation/domain/geocoding_service.dart';
import 'package:camp/features/navigation/domain/location_service.dart';
import 'package:camp/features/navigation/domain/places_poi_service.dart';
import 'package:camp/features/navigation/domain/routing_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'helpers/fake_location_service.dart';
import 'helpers/fake_routing_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OSRM JSON Parsing & Route Construction', () {
    test('Parses complete OSRM payload including polyline, steps, metrics, and alternate', () {
      final sampleOsrmJson = {
        'code': 'Ok',
        'routes': [
          {
            'distance': 4333.3,
            'duration': 201.5,
            'geometry': {
              'coordinates': [
                [-120.687716, 48.513488],
                [-120.654240, 48.523575],
                [-120.642503, 48.514646],
              ],
              'type': 'LineString',
            },
            'legs': [
              {
                'steps': [
                  {
                    'name': 'North Cascades Highway',
                    'distance': 2900.3,
                    'duration': 134.6,
                    'maneuver': {
                      'type': 'depart',
                      'modifier': 'left',
                      'location': [-120.687716, 48.513488],
                    },
                  },
                  {
                    'name': 'Highway 20',
                    'distance': 1433.0,
                    'duration': 66.9,
                    'maneuver': {
                      'type': 'turn',
                      'modifier': 'right',
                      'location': [-120.654240, 48.523575],
                    },
                  },
                  {
                    'name': 'Timber Ridge Moto Outpost',
                    'distance': 0.0,
                    'duration': 0.0,
                    'maneuver': {
                      'type': 'arrive',
                      'location': [-120.642503, 48.514646],
                    },
                  },
                ],
              },
            ],
          },
          {
            'distance': 5100.0,
            'duration': 240.0,
            'geometry': {
              'coordinates': [
                [-120.687716, 48.513488],
                [-120.642503, 48.514646],
              ],
              'type': 'LineString',
            },
          },
        ],
      };

      final result = OsrmRoutingService.parseOsrmResponse(sampleOsrmJson);

      expect(result.polyline.length, 3);
      expect(result.polyline.first.latitude, 48.513488);
      expect(result.polyline.first.longitude, -120.687716);
      expect(result.distanceMeters, 4333.3);
      expect(result.durationSeconds, 201.5);
      expect(result.formattedDuration, '3 min');

      // Steps verification
      expect(result.steps.length, 3);
      expect(result.steps[0].maneuverType, 'depart');
      expect(result.steps[0].instruction, 'Head out on North Cascades Highway');
      expect(result.steps[1].maneuverType, 'turn');
      expect(result.steps[1].instruction, 'Turn right onto Highway 20');
      expect(result.steps[2].maneuverType, 'arrive');
      expect(result.steps[2].instruction, 'Arrive at destination');

      // Alternate polyline
      expect(result.alternatePolyline, isNotNull);
      expect(result.alternatePolyline!.length, 2);
      expect(result.alternateDurationSeconds, 240.0);
    });
  });

  group('Instruction Text Synthesis', () {
    test('Synthesizes depart, arrive, turns, and continues accurately', () {
      expect(
        RouteStep.synthesizeInstruction(
          type: 'depart',
          streetName: 'Cascade Loop',
          distanceMeters: 500,
        ),
        'Head out on Cascade Loop',
      );

      expect(
        RouteStep.synthesizeInstruction(
          type: 'turn',
          modifier: 'right',
          streetName: 'Bear Creek Pass Rd',
          distanceMeters: 3800,
        ),
        'Turn right onto Bear Creek Pass Rd',
      );

      expect(
        RouteStep.synthesizeInstruction(
          type: 'turn',
          modifier: 'left',
          streetName: 'Highway 20',
          distanceMeters: 1200,
        ),
        'Turn left onto Highway 20',
      );

      expect(
        RouteStep.synthesizeInstruction(
          type: 'turn',
          modifier: 'slight right',
          streetName: 'Forest Spur',
          distanceMeters: 400,
        ),
        'Slight right onto Forest Spur',
      );

      expect(
        RouteStep.synthesizeInstruction(
          type: 'turn',
          modifier: 'uturn',
          streetName: 'Main St',
          distanceMeters: 100,
        ),
        'Make a U-turn onto Main St',
      );

      expect(
        RouteStep.synthesizeInstruction(
          type: 'arrive',
          streetName: '',
          distanceMeters: 0,
        ),
        'Arrive at destination',
      );
    });
  });

  group('Off-Route Distance & Step Progression', () {
    test('Calculates distance from point to polyline accurately', () {
      final polyline = [
        const LatLng(48.500, -120.600),
        const LatLng(48.500, -120.700),
      ];

      // Point directly on segment
      const onLine = LatLng(48.500, -120.650);
      expect(
        NavigationController.calculateDistanceToPolyline(onLine, polyline),
        lessThan(5.0),
      );

      // Point roughly 110m north
      const offLine = LatLng(48.501, -120.650);
      final dist = NavigationController.calculateDistanceToPolyline(offLine, polyline);
      expect(dist, greaterThan(80.0));
      expect(dist, lessThan(140.0));
    });

    test('Step advance when within ~30m of maneuver point', () async {
      final fakeLocation = FakeLocationService(
        initialPosition: PositionData(
          latitude: 48.500,
          longitude: -120.600,
          timestamp: DateTime.now(),
        ),
      );
      final fakeRouting = FakeRoutingService();
      final controller = NavigationController(
        locationService: fakeLocation,
        routingService: fakeRouting,
      );

      await controller.openRoutePreview(
        const PlaceSearchResult(
          name: 'Summit Outpost',
          displayName: 'Summit Outpost, WA',
          location: LatLng(48.520, -120.650),
        ),
      );

      controller.startNavigation();
      expect(controller.currentStepIndex, 0);

      // Move vehicle to within 20m of step 1 maneuver location
      final step1Loc = controller.route!.steps[1].location;
      fakeLocation.emitPosition(
        PositionData(
          latitude: step1Loc.latitude,
          longitude: step1Loc.longitude,
          timestamp: DateTime.now(),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentStepIndex, 1);
      controller.dispose();
    });

    test('Transitions to arrived state when within ~30m of destination', () async {
      final fakeLocation = FakeLocationService();
      final fakeRouting = FakeRoutingService();
      final controller = NavigationController(
        locationService: fakeLocation,
        routingService: fakeRouting,
      );

      await controller.openRoutePreview(
        const PlaceSearchResult(
          name: 'Summit Outpost',
          displayName: 'Summit Outpost, WA',
          location: LatLng(48.520, -120.650),
        ),
      );

      controller.startNavigation();
      expect(controller.state, NavigationState.navigating);

      // Move within 10 meters of destination (last polyline coordinate)
      final destLoc = controller.route!.polyline.last;
      fakeLocation.emitPosition(
        PositionData(
          latitude: destLoc.latitude,
          longitude: destLoc.longitude,
          timestamp: DateTime.now(),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(controller.state, NavigationState.arrived);
      controller.dispose();
    });
  });

  group('Speed Conversion across Unit Systems', () {
    test('Converts speed in m/s to KM/H, clamped at 0 for null/negative', () async {
      final fakeLocation = FakeLocationService();
      final controller = NavigationController(locationService: fakeLocation);
      controller.startPositionStream();

      // 10 m/s in Metric -> 36 km/h
      fakeLocation.emitPosition(
        PositionData(
          latitude: 48.0,
          longitude: -120.0,
          speed: 10.0,
          timestamp: DateTime.now(),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.currentSpeed, 36);
      expect(controller.speedUnitLabel, 'KM / H');

      // Negative or null speed returns 0
      fakeLocation.emitPosition(
        PositionData(
          latitude: 48.0,
          longitude: -120.0,
          speed: -1.0,
          timestamp: DateTime.now(),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.currentSpeed, 0);

      fakeLocation.emitPosition(
        PositionData(
          latitude: 48.0,
          longitude: -120.0,
          speed: null,
          timestamp: DateTime.now(),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.currentSpeed, 0);

      controller.dispose();
    });
  });

  group('Fuel Estimate Calculation', () {
    test('Calculates fuel estimate when bike has fuelAverageKmPerLiter, hides when null', () async {
      final fakeRouting = FakeRoutingService();
      final controller = NavigationController(routingService: fakeRouting);

      // Test route distance is 5.4 km
      await controller.openRoutePreview(
        const PlaceSearchResult(
          name: 'Outpost',
          displayName: 'Outpost',
          location: LatLng(48.5, -120.6),
        ),
      );

      final bike = ActiveBikeController.instance.activeBike;
      if (bike?.fuelAverageKmPerLiter != null) {
        expect(controller.fuelEstimateDisplay, contains('L'));
      } else {
        expect(controller.fuelEstimateDisplay, isNull);
      }

      controller.dispose();
    });
  });

  group('Google Maps Link Builder', () {
    test('Constructs standard Google Maps URL in two-wheeler mode', () {
      const dest = LatLng(48.520000, -120.650000);
      final url = NavigationController.buildGoogleMapsUrl(dest);

      expect(
        url,
        'https://www.google.com/maps/dir/?api=1&destination=48.520000,-120.650000&travelmode=two-wheeler',
      );
    });
  });

  group('NavigationController Lifecycle & Stability', () {
    test('Disposing controller while permission request is pending completes without throwing', () async {
      final permCompleter = Completer<bool>();
      final locationService = _PendingPermissionLocationService(permCompleter);
      final controller = NavigationController(locationService: locationService);

      final initFuture = controller.initialize();
      controller.dispose();
      expect(controller.isDisposed, isTrue);

      permCompleter.complete(true);
      await expectLater(initFuture, completes);
    });

    test('Disposing controller while getCurrentPosition is pending completes without throwing', () async {
      final posCompleter = Completer<PositionData?>();
      final locationService = _PendingPositionLocationService(posCompleter);
      final controller = NavigationController(locationService: locationService);

      final initFuture = controller.initialize();
      controller.dispose();
      expect(controller.isDisposed, isTrue);

      posCompleter.complete(
        PositionData(
          latitude: 48.515,
          longitude: -120.690,
          timestamp: DateTime.now(),
        ),
      );
      await expectLater(initFuture, completes);
    });

    test('Disposing controller while route request is pending completes without throwing', () async {
      final routeCompleter = Completer<RouteResult>();
      final routingService = _PendingRouteRoutingService(routeCompleter);
      final controller = NavigationController(routingService: routingService);

      final previewFuture = controller.openRoutePreview(
        const PlaceSearchResult(
          name: 'Summit Outpost',
          displayName: 'Summit Outpost, WA',
          location: LatLng(48.520, -120.650),
        ),
      );
      controller.dispose();
      expect(controller.isDisposed, isTrue);

      routeCompleter.complete(
        const RouteResult(
          polyline: [LatLng(48.515, -120.690), LatLng(48.520, -120.650)],
          distanceMeters: 1200.0,
          durationSeconds: 150.0,
          steps: [],
        ),
      );
      await expectLater(previewFuture, completes);
    });
  });

  group('Fallback Centre & Location Off Safety Tests', () {
    test('Fallback centre does not affect distance or ETA calculations when location is off', () async {
      final fakeLocation = FakeLocationService(
        nullInitialPosition: true,
        serviceEnabled: false,
      );
      final fakeRouting = FakeRoutingService();
      final controller = NavigationController(
        locationService: fakeLocation,
        routingService: fakeRouting,
      );

      // Verify initial state: userLatLng is null and camera center points to Lahore fallback
      expect(controller.userLatLng, isNull);
      expect(controller.cameraCenter, NavigationController.defaultFallbackCenter);
      expect(controller.cameraCenter.latitude, 31.5204);
      expect(controller.cameraCenter.longitude, 74.3587);

      const destination = PlaceSearchResult(
        name: 'Margalla Ridge',
        displayName: 'Margalla Ridge Trailhead, Islamabad',
        location: LatLng(33.74, 73.05),
      );

      // Attempt to preview route when GPS location is unavailable
      await controller.openRoutePreview(destination);

      // Verify that Lahore fallback centre is NEVER used in route, distance, or ETA
      expect(controller.route, isNull);
      expect(controller.remainingDistanceMeters, 0.0);
      expect(controller.remainingDurationSeconds, 0.0);
      expect(controller.eta, isNull);
      expect(
        controller.routeError,
        'Location unavailable. Turn on GPS to calculate route.',
      );

      // Verify cameraCenter now points to destination rather than user position
      expect(controller.cameraCenter, destination.location);
      expect(controller.userLatLng, isNull);

      // Attempting to calculate route again with location off must still result in 0 distance and null ETA
      await controller.calculateRoute();
      expect(controller.route, isNull);
      expect(controller.remainingDistanceMeters, 0.0);
      expect(controller.remainingDurationSeconds, 0.0);
      expect(controller.eta, isNull);

      // Swapping endpoints when GPS is off must not set destination to Lahore fallback center
      controller.swapStartAndDestination();
      expect(controller.destination?.name, 'Margalla Ridge');
      expect(controller.destination?.location, destination.location);

      // When GPS fix is later acquired, real route and distance can be calculated
      controller.startPositionStream();
      fakeLocation.emitPosition(
        PositionData(
          latitude: 33.70,
          longitude: 73.00,
          timestamp: DateTime.now(),
        ),
      );
      // Allow stream and calculateRoute async future to settle
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.userLatLng, isNotNull);
      expect(controller.userLatLng!.latitude, 33.70);
      expect(controller.route, isNotNull);
      expect(controller.remainingDistanceMeters, greaterThan(0.0));
      expect(controller.eta, isNotNull);

      controller.dispose();
      fakeLocation.dispose();
    });

    test('POIs and reverse geocoding do not run around fallback centre when location is off', () async {
      final fakeLocation = FakeLocationService(
        nullInitialPosition: true,
        serviceEnabled: false,
      );
      final controller = NavigationController(
        locationService: fakeLocation,
      );

      expect(controller.userLatLng, isNull);

      // Toggle mechanic POI filter with location off
      await controller.togglePoiFilter(PoiType.mechanic);
      expect(controller.poiMarkers, isEmpty);

      // Toggle fuel POI filter with location off
      await controller.togglePoiFilter(PoiType.fuel);
      expect(controller.poiMarkers, isEmpty);

      controller.dispose();
      fakeLocation.dispose();
    });
  });
}

class _PendingPermissionLocationService extends FakeLocationService {
  _PendingPermissionLocationService(this.permissionCompleter);
  final Completer<bool> permissionCompleter;

  @override
  Future<bool> checkPermission() async => false;

  @override
  Future<bool> requestPermission() => permissionCompleter.future;
}

class _PendingPositionLocationService extends FakeLocationService {
  _PendingPositionLocationService(this.positionCompleter);
  final Completer<PositionData?> positionCompleter;

  @override
  Future<bool> checkPermission() async => true;

  @override
  Future<PositionData?> getCurrentPosition() => positionCompleter.future;
}

class _PendingRouteRoutingService extends FakeRoutingService {
  _PendingRouteRoutingService(this.routeCompleter);
  final Completer<RouteResult> routeCompleter;

  @override
  Future<RouteResult> getRoute({
    required List<LatLng> waypoints,
    String mode = 'motorcycle',
    bool requestAlternatives = false,
  }) =>
      routeCompleter.future;
}
