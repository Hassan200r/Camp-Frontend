import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/camp_bottom_nav.dart';
import '../../controllers/navigation_controller.dart';
import '../../domain/geocoding_service.dart';
import '../../domain/location_service.dart';
import '../widgets/nav_active_bottom_bar.dart';
import '../widgets/nav_active_navigation_overlay.dart';
import '../widgets/nav_arrived_sheet.dart';
import '../widgets/nav_filter_chips.dart';
import '../widgets/nav_location_sheet.dart';
import '../widgets/nav_map_controls.dart';
import '../widgets/nav_map_view.dart';
import '../widgets/nav_permission_banner.dart';
import '../widgets/nav_poi_detail_sheet.dart';
import '../widgets/nav_route_preview_panel.dart';
import '../widgets/nav_route_preview_sheet.dart';
import '../widgets/nav_search_bar.dart';
import '../widgets/nav_turn_banner.dart';

/// Preset locations for quick navigation previews.
/// Rebuilt Navigation Map Screen matching the 3-state design:
/// State 1: Default map with search, filter chips, controls & "Your Location" sheet
/// State 2: Route preview with waypoints, swap, fuel estimate & Start button
/// State 3: Active navigation with turn banner, speedometer, Google Maps link, and bottom bar
class NavigationMapScreen extends StatefulWidget {
  const NavigationMapScreen({
    super.key,
    this.initialDestination,
    this.onNavigateToHome,
    this.controller,
    this.locationService,
    this.tileProvider,
  });

  final PlaceSearchResult? initialDestination;
  final VoidCallback? onNavigateToHome;
  final NavigationController? controller;
  final LocationService? locationService;
  final TileProvider? tileProvider;

  @override
  State<NavigationMapScreen> createState() => _NavigationMapScreenState();
}

class _NavigationMapScreenState extends State<NavigationMapScreen>
    with WidgetsBindingObserver {
  late final NavigationController _controller;
  late final LocationService _locationService;
  late final MapController _mapController;
  bool _ownsController = false;
  bool _hasCenteredOnInitialPosition = false;
  bool _hasOpenedInitialDestination = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mapController = MapController();
    _locationService = widget.locationService ?? const GeolocatorLocationService();

    if (widget.controller != null) {
      _controller = widget.controller!;
      _controller.checkLocationPermissionAndStart();
    } else {
      _ownsController = false;
      _controller = NavigationController.instance;
      _controller.initialize();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasOpenedInitialDestination) {
      final modalDest = ModalRoute.of(context)?.settings.arguments;
      final dest = widget.initialDestination ??
          (modalDest is PlaceSearchResult ? modalDest : null);
      if (dest != null) {
        _hasOpenedInitialDestination = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _controller.openRoutePreview(dest);
            _fitRouteBounds();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsController) {
      _controller.dispose();
    }
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Silently check location service status upon returning to foreground.
      // Shows non-blocking banner if location is off; never shows a blocking dialog.
      _controller.checkLocationPermissionAndStart();
    }
  }

  void _openDefaultDirections() {
    if (_controller.savedPlaces.isNotEmpty) {
      final destination = _controller.savedPlaces.first;
      _controller.openRoutePreview(destination);
      _fitRouteBounds();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Search or select a destination to preview route'),
          backgroundColor: AppColors.darkCharcoal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _fitRouteBounds() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.route != null && _controller.route!.polyline.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(_controller.route!.polyline);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.fromLTRB(50, 180, 50, 220),
          ),
        );
      }
    });
  }

  void _handleBack() {
    if (_controller.state == NavigationState.previewing) {
      _controller.cancelRoutePreview();
      return;
    }
    if (_controller.state == NavigationState.arrived) {
      _controller.dismissArrived();
      return;
    }
    // Leaving the Maps screen never ends navigation and never shows the dialog.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      CampBottomNav.navigateToTab(context, CampTab.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;
        final isNavigating = state == NavigationState.navigating;
        final isPreviewing = state == NavigationState.previewing;
        final isArrived = state == NavigationState.arrived;

        // Auto-center camera during navigation when requested
        if (isNavigating && _controller.isScreenCentered) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _mapController.move(_controller.cameraCenter, 17.0);
          });
        } else if (!_hasCenteredOnInitialPosition && _controller.currentPosition != null) {
          _hasCenteredOnInitialPosition = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _controller.state == NavigationState.idle) {
              _mapController.move(_controller.cameraCenter, 15.0);
            }
          });
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              _handleBack();
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFF141210),
            body: Stack(
              fit: StackFit.expand,
              children: [
                // ── 1. Fullscreen Map Canvas ─────────────────────────────────
                Positioned.fill(
                  child: NavMapView(
                    controller: _controller,
                    mapController: _mapController,
                    tileProvider: widget.tileProvider,
                    onTapMap: () {
                      _controller.clearSelectedPoiMarker();
                    },
                  ),
                ),

                // ── 2. Top Bar & Panels (State Dependent) ────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),

                        if (state == NavigationState.idle) ...[
                          // State 1: Search Bar
                          NavSearchBar(
                            controller: _controller,
                            onOpenProfile: () {
                              Navigator.of(context).pushNamed(CampRoutes.profile);
                            },
                            onSelectPlace: (place) {
                              _controller.openRoutePreview(place);
                              _fitRouteBounds();
                            },
                          ),
                          const SizedBox(height: 10),

                          // State 1: Filter Chips
                          NavFilterChips(controller: _controller),

                          // Location Permission Alert Banner
                          NavPermissionBanner(
                            controller: _controller,
                            locationService: _locationService,
                          ),
                        ] else if (isPreviewing) ...[
                          // State 2: Route Preview Waypoints Top Card
                          NavRoutePreviewPanel(
                            controller: _controller,
                            onBack: _controller.cancelRoutePreview,
                            onAddStop: () {
                              if (_controller.savedPlaces.length > 1) {
                                _controller.addStop(_controller.savedPlaces[1]);
                                _fitRouteBounds();
                              }
                            },
                          ),
                        ] else if (isNavigating) ...[
                          // State 3: Turn-by-Turn Maneuver Top Banner
                          NavTurnBanner(controller: _controller),
                        ],
                      ],
                    ),
                  ),
                ),

                // ── 3. Right Floating Map Controls (State 1 & 2) ─────────────
                if (!isNavigating)
                  Positioned(
                    right: 16,
                    top: isPreviewing ? 270 : 160,
                    child: NavMapControls(
                      controller: _controller,
                      mapController: _mapController,
                    ),
                  ),

                // ── 4. State 3 Mid Overlay: Speedometer & External Shortcuts ─
                if (isNavigating)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 170,
                    child: NavActiveNavigationOverlay(
                      controller: _controller,
                      mapController: _mapController,
                    ),
                  ),

                // ── 5. Bottom Sheets & Bars ──────────────────────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: isNavigating ? 84 : 80,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Selected POI Detail Sheet
                      if (_controller.selectedPoiMarker != null && !isNavigating)
                        NavPoiDetailSheet(
                          marker: _controller.selectedPoiMarker!,
                          controller: _controller,
                          onClose: _controller.clearSelectedPoiMarker,
                        ),

                      // State 1: Collapsed Your Location Card
                      if (state == NavigationState.idle &&
                          _controller.selectedPoiMarker == null)
                        NavLocationSheet(
                          controller: _controller,
                          onTapDirections: _openDefaultDirections,
                        ),

                      // State 2: Route Preview Metrics & Start Button
                      if (isPreviewing)
                        NavRoutePreviewSheet(
                          controller: _controller,
                          onStartNavigation: () {
                            _controller.startNavigation();
                          },
                          onAddStop: () {
                            if (_controller.savedPlaces.length > 1) {
                              _controller.addStop(_controller.savedPlaces[1]);
                              _fitRouteBounds();
                            }
                          },
                        ),

                      // State 3: Active Guidance Bottom Bar (ETA & Exit Button)
                      if (isNavigating)
                        NavActiveBottomBar(
                          controller: _controller,
                          onConfirmExit: _controller.stopNavigation,
                          onToggleOverview: _fitRouteBounds,
                        ),

                      // Arrived Destination Modal Sheet
                      if (isArrived)
                        NavArrivedSheet(
                          controller: _controller,
                          onDone: _controller.dismissArrived,
                        ),
                    ],
                  ),
                ),

                // ── 6. Bottom Dock Navigation ───────────────────────────────
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24,
                  child: Center(
                    child: CampBottomNav(
                      selected: CampTab.navigation,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
