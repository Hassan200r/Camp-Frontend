import 'package:camp/features/garage/controllers/active_bike_controller.dart';
import 'package:camp/features/navigation/controllers/navigation_controller.dart';
import 'package:camp/features/navigation/domain/geocoding_service.dart';
import 'package:camp/features/navigation/domain/location_service.dart';
import 'package:camp/features/navigation/domain/routing_service.dart';
import 'package:camp/features/settings/controllers/settings_controller.dart';
import 'package:camp/features/settings/domain/units_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

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
    test('Converts speed in m/s to KM/H and MPH, clamped at 0 for null/negative', () async {
      final fakeLocation = FakeLocationService();
      final controller = NavigationController(locationService: fakeLocation);
      controller.startPositionStream();

      // 10 m/s in Metric -> 36 km/h
      SettingsController.instance.setUnits(UnitsSystem.metric);
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

      // 10 m/s in Imperial -> ~22 mph
      SettingsController.instance.setUnits(UnitsSystem.imperial);
      expect(controller.currentSpeed, 22);
      expect(controller.speedUnitLabel, 'MPH');

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

      // Reset units to metric
      SettingsController.instance.setUnits(UnitsSystem.metric);
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

      SettingsController.instance.setUnits(UnitsSystem.metric);

      final bike = ActiveBikeController.instance.activeBike;
      if (bike?.fuelAverageKmPerLiter != null) {
        expect(controller.fuelEstimateDisplay, contains('L'));

        SettingsController.instance.setUnits(UnitsSystem.imperial);
        expect(controller.fuelEstimateDisplay, contains('gal'));
      } else {
        expect(controller.fuelEstimateDisplay, isNull);
      }

      SettingsController.instance.setUnits(UnitsSystem.metric);
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
}
