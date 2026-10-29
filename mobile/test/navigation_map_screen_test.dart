import 'dart:convert';

import 'package:camp/core/widgets/camp_bottom_nav.dart';
import 'package:camp/features/navigation/controllers/navigation_controller.dart';
import 'package:camp/features/navigation/domain/geocoding_service.dart';
import 'package:camp/features/navigation/domain/location_service.dart';
import 'package:camp/features/navigation/presentation/screens/navigation_map_screen.dart';
import 'package:camp/features/navigation/presentation/widgets/nav_active_bottom_bar.dart';
import 'package:camp/features/navigation/presentation/widgets/nav_active_navigation_overlay.dart';
import 'package:camp/features/navigation/presentation/widgets/nav_location_sheet.dart';
import 'package:camp/features/navigation/presentation/widgets/nav_permission_banner.dart';
import 'package:camp/features/navigation/presentation/widgets/nav_route_preview_panel.dart';
import 'package:camp/features/navigation/presentation/widgets/nav_route_preview_sheet.dart';
import 'package:camp/features/navigation/presentation/widgets/nav_turn_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'helpers/fake_geocoding_service.dart';
import 'helpers/fake_location_service.dart';
import 'helpers/fake_routing_service.dart';

class FakeTileProvider extends TileProvider {
  FakeTileProvider();

  static const String _whiteTile =
      'iVBORw0KGgoAAAANSUhEUgAAAQAAAAEAAQMAAABmvDolAAAAAXNSR0IB2cksfwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAANQTFRF////p8QbyAAAAB9JREFUeJztwQENAAAAwqD3T20ON6AAAAAAAAAAAL4NIQAAAfFnIe4AAAAASUVORK5CYII=';
  static final _whiteTileBytes = base64Decode(_whiteTile);

  @override
  ImageProvider<Object> getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(_whiteTileBytes);
  }
}

void main() {
  Widget buildTestScreen({
    required NavigationController controller,
    required LocationService locationService,
  }) {
    return MaterialApp(
      routes: {
        '/profile': (ctx) => const Scaffold(body: Text('Profile Mock')),
        '/route-packs': (ctx) => const Scaffold(body: Text('Route Packs Mock')),
      },
      home: NavigationMapScreen(
        controller: controller,
        locationService: locationService,
        tileProvider: FakeTileProvider(),
      ),
    );
  }

  group('NavigationMapScreen 3-State Widget Tests', () {
    testWidgets('State 1 (Idle): Shows location sheet, search bar, and bottom nav', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeLocation = FakeLocationService();
      final fakeRouting = FakeRoutingService();
      final fakeGeocoding = FakeGeocodingService();
      final controller = NavigationController(
        locationService: fakeLocation,
        routingService: fakeRouting,
        geocodingService: fakeGeocoding,
      );

      await tester.pumpWidget(
        buildTestScreen(
          controller: controller,
          locationService: fakeLocation,
        ),
      );
      await tester.pumpAndSettle();

      // State 1 verifies
      expect(find.byType(NavLocationSheet), findsOneWidget);
      expect(find.text('YOUR LOCATION'), findsOneWidget);
      expect(find.text('Directions'), findsOneWidget);
      expect(find.byType(CampBottomNav), findsOneWidget);

      controller.dispose();
      fakeLocation.dispose();
    });

    testWidgets('State 1 -> State 2: Tapping Directions opens Route Preview', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeLocation = FakeLocationService();
      final fakeRouting = FakeRoutingService();
      final fakeGeocoding = FakeGeocodingService();
      final controller = NavigationController(
        locationService: fakeLocation,
        routingService: fakeRouting,
        geocodingService: fakeGeocoding,
      );
      controller.toggleSavedPlace(
        const PlaceSearchResult(
          name: 'Test Destination',
          displayName: 'Test Destination Point',
          location: LatLng(34.0, 74.0),
        ),
      );

      await tester.pumpWidget(
        buildTestScreen(
          controller: controller,
          locationService: fakeLocation,
        ),
      );
      await tester.pumpAndSettle();

      debugPrint('Scaffold rect: ${tester.getRect(find.byType(Scaffold))}');
      debugPrint('Stack rect: ${tester.getRect(find.byType(Stack).first)}');
      debugPrint('LocationSheet rect: ${tester.getRect(find.byType(NavLocationSheet))}');
      debugPrint('Directions rect: ${tester.getRect(find.text('Directions'))}');
      // Tap Directions button
      await tester.tap(find.text('Directions'));
      await tester.pumpAndSettle();

      // State 2: Route Preview verified
      expect(controller.state, NavigationState.previewing);
      expect(find.byType(NavRoutePreviewPanel), findsOneWidget);
      expect(find.byType(NavRoutePreviewSheet), findsOneWidget);
      expect(find.text('ROUTE PREVIEW'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);

      controller.dispose();
      fakeLocation.dispose();
    });

    testWidgets('State 2 -> State 3: Tapping Start enters active guidance and hides bottom nav', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeLocation = FakeLocationService();
      final fakeRouting = FakeRoutingService();
      final fakeGeocoding = FakeGeocodingService();
      final controller = NavigationController(
        locationService: fakeLocation,
        routingService: fakeRouting,
        geocodingService: fakeGeocoding,
      );
      controller.toggleSavedPlace(
        const PlaceSearchResult(
          name: 'Test Destination',
          displayName: 'Test Destination Point',
          location: LatLng(34.0, 74.0),
        ),
      );

      await tester.pumpWidget(
        buildTestScreen(
          controller: controller,
          locationService: fakeLocation,
        ),
      );
      await tester.pumpAndSettle();

      // Open preview then start navigation
      await tester.tap(find.text('Directions'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      // State 3: Guidance verified
      expect(controller.state, NavigationState.navigating);
      expect(find.byType(NavTurnBanner), findsOneWidget);
      expect(find.byType(NavActiveNavigationOverlay), findsOneWidget);
      expect(find.byType(NavActiveBottomBar), findsOneWidget);

      // Speedometer & shortcuts present
      expect(find.text('Google Maps'), findsOneWidget);
      expect(find.text('Offline Route Packs'), findsOneWidget);

      // CampBottomNav remains visible so rider can switch dock tabs without ending guidance
      expect(find.byType(CampBottomNav), findsOneWidget);
      // Slim bar is NOT shown on Maps screen itself
      expect(find.byKey(const ValueKey('active_navigation_slim_bar')), findsNothing);

      controller.dispose();
      fakeLocation.dispose();
    });

    testWidgets('State 3 Exit button displays confirmation dialog and resumes/ends', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeLocation = FakeLocationService();
      final fakeRouting = FakeRoutingService();
      final fakeGeocoding = FakeGeocodingService();
      final controller = NavigationController(
        locationService: fakeLocation,
        routingService: fakeRouting,
        geocodingService: fakeGeocoding,
      );
      controller.toggleSavedPlace(
        const PlaceSearchResult(
          name: 'Test Destination',
          displayName: 'Test Destination Point',
          location: LatLng(34.0, 74.0),
        ),
      );

      await tester.pumpWidget(
        buildTestScreen(
          controller: controller,
          locationService: fakeLocation,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Directions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      // Tap Exit button (close icon)
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Confirmation dialog appears
      expect(find.text('End navigation?'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
      expect(find.text('End Ride'), findsOneWidget);

      // Tap Resume: ride continues
      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();
      expect(controller.state, NavigationState.navigating);

      // Tap Exit again, then End Ride: exits to idle
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('End Ride'));
      await tester.pumpAndSettle();

      expect(controller.state, NavigationState.idle);
      expect(find.byType(CampBottomNav), findsOneWidget);

      controller.dispose();
      fakeLocation.dispose();
    });

    testWidgets('Permission denied displays the alert banner with Open Settings', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeLocation = FakeLocationService(hasPermission: false);
      final controller = NavigationController(locationService: fakeLocation);
      await controller.checkLocationPermissionAndStart();

      await tester.pumpWidget(
        buildTestScreen(
          controller: controller,
          locationService: fakeLocation,
        ),
      );
      await tester.pumpAndSettle();

      // Alert banner is displayed
      expect(find.byType(NavPermissionBanner), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);

      controller.dispose();
      fakeLocation.dispose();
    });

    testWidgets('When device location service is off, displays non-blocking hint banner and never blocks the screen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeLocation = FakeLocationService(
        serviceEnabled: false,
        nullInitialPosition: true,
      );
      final controller = NavigationController(locationService: fakeLocation);
      await controller.checkLocationPermissionAndStart();

      await tester.pumpWidget(
        buildTestScreen(
          controller: controller,
          locationService: fakeLocation,
        ),
      );
      await tester.pumpAndSettle();

      // Non-blocking hint banner is displayed
      expect(find.byType(NavPermissionBanner), findsOneWidget);
      expect(find.text('Location services are disabled on your device.'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);

      // Verify no blocking dialogs are present
      expect(find.byType(AlertDialog), findsNothing);

      // Verify userLatLng is null and camera center is positioned at Lahore fallback
      expect(controller.userLatLng, isNull);
      expect(controller.cameraCenter, NavigationController.defaultFallbackCenter);

      controller.dispose();
      fakeLocation.dispose();
    });
  });
}
