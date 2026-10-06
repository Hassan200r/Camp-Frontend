import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../garage/controllers/active_bike_controller.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../settings/domain/units_system.dart';
import '../domain/geocoding_service.dart';
import '../domain/location_service.dart';
import '../domain/places_poi_service.dart';
import '../domain/routing_service.dart';

/// Navigation workflow states.
enum NavigationState {
  /// State 1: Default interactive map overview with search and POI discovery.
  idle,

  /// State 2: Route inspection and departure preview before starting guidance.
  previewing,

  /// State 3: Active turn-by-turn guidance, speed tracking and maneuver prompts.
  navigating,

  /// Reached destination waypoint.
  arrived,
}

/// Central state controller managing map interaction, route calculation,
/// GPS position tracking, step advancement, and active guidance telemetry.
class NavigationController extends ChangeNotifier {
  NavigationController({
    LocationService? locationService,
    RoutingService? routingService,
    GeocodingService? geocodingService,
    PlacesPoiService? placesPoiService,
    ActiveBikeController? bikeController,
    SettingsController? settingsController,
  })  : _locationService = locationService ?? const GeolocatorLocationService(),
        _routingService = routingService ?? OsrmRoutingService(),
        _geocodingService = geocodingService ?? NominatimGeocodingService(),
        _placesPoiService = placesPoiService ?? PlacesPoiService(),
        _bikeController = bikeController ?? ActiveBikeController.instance,
        _settingsController = settingsController ?? SettingsController.instance {
    _initDefaultPlaces();
  }

  final LocationService _locationService;
  final RoutingService _routingService;
  final GeocodingService _geocodingService;
  final PlacesPoiService _placesPoiService;
  final ActiveBikeController _bikeController;
  final SettingsController _settingsController;

  static const Distance _distanceCalc = Distance();

  // ── State ──────────────────────────────────────────────────────────────────
  NavigationState _state = NavigationState.idle;
  PositionData? _currentPosition;
  double? _currentHeading;
  StreamSubscription<PositionData>? _positionSub;

  PlaceSearchResult? _destination;
  final List<PlaceSearchResult> _stops = [];
  String _selectedMode = 'motorcycle'; // Motorcycle is the primary profile

  RouteResult? _route;
  int _currentStepIndex = 0;
  double _remainingDistanceMeters = 0.0;
  double _remainingDurationSeconds = 0.0;
  DateTime? _eta;

  bool _isMuted = false;
  bool _isScreenCentered = true;
  bool _isCalculatingRoute = false;
  String? _routeError;

  bool _permissionDenied = false;
  bool _isLocationServiceEnabled = true;

  String _currentLocationName = 'Cascade Alpine Loop';
  String _currentLocationSubtitle = 'GPS Ready';
  DateTime? _lastReverseGeocodeTime;

  // Off-route tracking
  int _offRouteConsecutiveFixes = 0;
  DateTime? _lastRerouteTime;

  // In-memory recents and saved places
  final List<PlaceSearchResult> _recentPlaces = [];
  final List<PlaceSearchResult> _savedPlaces = [];

  // POI Markers
  List<PoiMarker> _poiMarkers = [];
  PoiType? _activePoiFilter;
  PoiMarker? _selectedPoiMarker;

  // Map layer toggle: false = Standard OSM, true = OpenTopoMap
  bool _isTopoLayer = false;

  // ── Getters ────────────────────────────────────────────────────────────────
  NavigationState get state => _state;
  PositionData? get currentPosition => _currentPosition;
  double? get currentHeading => _currentHeading ?? _currentPosition?.heading;

  /// Latitude & Longitude of current position or fallback center.
  LatLng get userLatLng =>
      _currentPosition?.toLatLng() ?? const LatLng(48.515, -120.690);

  PlaceSearchResult? get destination => _destination;
  List<PlaceSearchResult> get stops => List.unmodifiable(_stops);
  String get selectedMode => _selectedMode;
  RouteResult? get route => _route;
  int get currentStepIndex => _currentStepIndex;
  double get remainingDistanceMeters => _remainingDistanceMeters;
  double get remainingDurationSeconds => _remainingDurationSeconds;
  DateTime? get eta => _eta;

  bool get isMuted => _isMuted;
  bool get isScreenCentered => _isScreenCentered;
  bool get isCalculatingRoute => _isCalculatingRoute;
  String? get routeError => _routeError;
  bool get permissionDenied => _permissionDenied;
  bool get isLocationServiceEnabled => _isLocationServiceEnabled;

  String get currentLocationName => _currentLocationName;
  String get currentLocationSubtitle => _currentLocationSubtitle;

  List<PlaceSearchResult> get recentPlaces => List.unmodifiable(_recentPlaces);
  List<PlaceSearchResult> get savedPlaces => List.unmodifiable(_savedPlaces);

  List<PoiMarker> get poiMarkers => List.unmodifiable(_poiMarkers);
  PoiType? get activePoiFilter => _activePoiFilter;
  PoiMarker? get selectedPoiMarker => _selectedPoiMarker;
  bool get isTopoLayer => _isTopoLayer;

  /// Current step in turn-by-turn guidance.
  RouteStep? get currentStep {
    if (_route == null || _route!.steps.isEmpty) return null;
    if (_currentStepIndex >= _route!.steps.length) {
      return _route!.steps.last;
    }
    return _route!.steps[_currentStepIndex];
  }

  /// Next step after current for previewing turn progression.
  RouteStep? get nextStep {
    if (_route == null || _route!.steps.isEmpty) return null;
    final nextIndex = _currentStepIndex + 1;
    if (nextIndex < _route!.steps.length) {
      return _route!.steps[nextIndex];
    }
    return null;
  }

  /// Current speed formatted according to active [UnitsSystem].
  /// Shows 0 when speed is null or negative.
  int get currentSpeed {
    final rawSpeedMs = _currentPosition?.speed;
    if (rawSpeedMs == null || rawSpeedMs <= 0) return 0;
    if (_settingsController.isImperial) {
      // m/s to mph: 1 m/s = 2.23694 mph
      return (rawSpeedMs * 2.23694).round();
    } else {
      // m/s to km/h: 1 m/s = 3.6 km/h
      return (rawSpeedMs * 3.6).round();
    }
  }

  /// Speed unit label ('KM / H' or 'MPH').
  String get speedUnitLabel =>
      _settingsController.isImperial ? 'MPH' : 'KM / H';

  /// Distance unit label.
  String get distanceUnitLabel =>
      _settingsController.isImperial ? 'mi' : 'km';

  /// Formatted remaining distance string (e.g. "5.4 km" or "3.4 mi").
  String get formattedRemainingDistance {
    if (_settingsController.isImperial) {
      final miles = _remainingDistanceMeters / 1609.344;
      return '${miles.toStringAsFixed(1)} mi';
    } else {
      final km = _remainingDistanceMeters / 1000.0;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  /// Formatted remaining duration string (e.g. "11 min").
  String get formattedRemainingDuration {
    final minutes = (_remainingDurationSeconds / 60).round();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remMins = minutes % 60;
    return remMins > 0 ? '${hours}h ${remMins}m' : '${hours}h';
  }

  /// Formatted ETA string (e.g. "09:52").
  String get formattedEta {
    final time = _eta ?? DateTime.now().add(Duration(seconds: _remainingDurationSeconds.round()));
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Fuel consumption estimate based on route distance and active motorcycle spec.
  /// Returns null if activeBike has no fuelAverageKmPerLiter.
  String? get fuelEstimateDisplay {
    if (_route == null) return null;
    final activeBike = _bikeController.activeBike;
    final kmPerL = activeBike?.fuelAverageKmPerLiter;
    if (kmPerL == null || kmPerL <= 0) return null;

    final distanceKm = _route!.distanceKm;
    final liters = distanceKm / kmPerL;

    if (_settingsController.isImperial) {
      // 1 liter = 0.264172 gallons
      final gallons = liters * 0.264172;
      return '${gallons.toStringAsFixed(2)} gal';
    } else {
      return '${liters.toStringAsFixed(2)} L';
    }
  }

  /// Google Maps deep-link URL for opening navigation externally in two-wheeler mode.
  static String buildGoogleMapsUrl(LatLng destination) {
    return 'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude.toStringAsFixed(6)},${destination.longitude.toStringAsFixed(6)}&travelmode=two-wheeler';
  }

  String get googleMapsUrl {
    final dest = _destination?.location ?? (_route?.polyline.isNotEmpty == true ? _route!.polyline.last : userLatLng);
    return buildGoogleMapsUrl(dest);
  }

  // ── Initialization & Lifecycle ─────────────────────────────────────────────

  Future<void> initialize() async {
    await checkLocationPermissionAndStart();
    _reverseGeocodeCurrentLocation();
  }

  Future<void> checkLocationPermissionAndStart() async {
    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    _isLocationServiceEnabled = serviceEnabled;
    if (!serviceEnabled) {
      _currentLocationSubtitle = 'Location off';
      notifyListeners();
    }

    final hasPerm = await _locationService.checkPermission();
    if (!hasPerm) {
      final granted = await _locationService.requestPermission();
      _permissionDenied = !granted;
      if (!granted) {
        _currentLocationSubtitle = 'Location permission denied';
        notifyListeners();
        return;
      }
    }

    _permissionDenied = false;
    _currentLocationSubtitle = 'GPS Ready';
    notifyListeners();

    // Fetch single current position fix
    final initialPos = await _locationService.getCurrentPosition();
    if (initialPos != null) {
      _currentPosition = initialPos;
      _currentHeading = initialPos.heading;
      notifyListeners();
    }

    startPositionStream();
  }

  void startPositionStream() {
    _positionSub?.cancel();
    final isNav = _state == NavigationState.navigating;
    _positionSub = _locationService
        .getPositionStream(highAccuracy: isNav)
        .listen(_handlePositionUpdate);
  }

  void stopPositionStream() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  void _handlePositionUpdate(PositionData pos) {
    _currentPosition = pos;
    if (pos.heading != null && pos.heading! >= 0) {
      _currentHeading = pos.heading;
    }

    if (_state == NavigationState.navigating && _route != null) {
      _processNavigationStepProgression(pos);
    }

    notifyListeners();
  }

  // ── Navigation Engine Logic ────────────────────────────────────────────────

  void _processNavigationStepProgression(PositionData pos) {
    if (_route == null || _route!.steps.isEmpty) return;

    final userLoc = pos.toLatLng();

    // 1. Check Arrival at Destination (within ~30m)
    final destLoc = _route!.polyline.isNotEmpty ? _route!.polyline.last : (_destination?.location ?? userLoc);
    final distanceToDest = _distanceCalc.as(LengthUnit.Meter, userLoc, destLoc);
    if (distanceToDest <= 30.0) {
      _transitionToArrived();
      return;
    }

    // 2. Advance Step when within ~30m of the next maneuver point
    if (_currentStepIndex < _route!.steps.length - 1) {
      final nextManeuver = _route!.steps[_currentStepIndex + 1];
      final distToManeuver =
          _distanceCalc.as(LengthUnit.Meter, userLoc, nextManeuver.location);

      if (distToManeuver <= 30.0) {
        _currentStepIndex++;
      }
    }

    // 3. Update remaining metrics along polyline
    _updateRemainingDistanceAndEta(userLoc);

    // 4. Off-Route Check (>50m away from polyline for multiple consecutive fixes)
    final distToPolyline = _distanceToPolyline(userLoc, _route!.polyline);
    if (distToPolyline > 50.0) {
      _offRouteConsecutiveFixes++;
      if (_offRouteConsecutiveFixes >= 3) {
        _checkAndTriggerReroute(userLoc);
      }
    } else {
      _offRouteConsecutiveFixes = 0;
    }
  }

  void _updateRemainingDistanceAndEta(LatLng userLoc) {
    if (_route == null || _route!.polyline.isEmpty) return;

    // Sum remaining polyline distance from closest point forward
    final poly = _route!.polyline;
    int closestIdx = 0;
    double minD = double.infinity;
    for (int i = 0; i < poly.length; i++) {
      final d = _distanceCalc.as(LengthUnit.Meter, userLoc, poly[i]);
      if (d < minD) {
        minD = d;
        closestIdx = i;
      }
    }

    double remDist = 0.0;
    for (int i = closestIdx; i < poly.length - 1; i++) {
      remDist += _distanceCalc.as(LengthUnit.Meter, poly[i], poly[i + 1]);
    }

    _remainingDistanceMeters = remDist;
    // Estimate remaining seconds based on route average speed
    if (_route!.distanceMeters > 0) {
      final avgSpeed = _route!.distanceMeters / math.max(1.0, _route!.durationSeconds);
      _remainingDurationSeconds = remDist / math.max(1.0, avgSpeed);
    }
    _eta = DateTime.now().add(Duration(seconds: _remainingDurationSeconds.round()));
  }

  /// Calculates shortest perpendicular distance in meters from [point] to [polyline].
  static double calculateDistanceToPolyline(LatLng point, List<LatLng> polyline) {
    if (polyline.isEmpty) return double.infinity;
    if (polyline.length == 1) {
      return _distanceCalc.as(LengthUnit.Meter, point, polyline.first);
    }

    double minDistance = double.infinity;
    for (int i = 0; i < polyline.length - 1; i++) {
      final d = _distanceToSegmentMeters(point, polyline[i], polyline[i + 1]);
      if (d < minDistance) {
        minDistance = d;
      }
    }
    return minDistance;
  }

  double _distanceToPolyline(LatLng point, List<LatLng> polyline) {
    return calculateDistanceToPolyline(point, polyline);
  }

  static double _distanceToSegmentMeters(LatLng p, LatLng a, LatLng b) {
    // Project p onto line segment ab using equirectangular projection
    final latP = p.latitudeInRad;
    final lonP = p.longitudeInRad;
    final latA = a.latitudeInRad;
    final lonA = a.longitudeInRad;
    final latB = b.latitudeInRad;
    final lonB = b.longitudeInRad;

    final cosMeanLat = math.cos((latA + latB) / 2);
    final dx = (lonB - lonA) * cosMeanLat;
    final dy = latB - latA;
    final segLenSq = dx * dx + dy * dy;

    if (segLenSq == 0) {
      return _distanceCalc.as(LengthUnit.Meter, p, a);
    }

    final px = (lonP - lonA) * cosMeanLat;
    final py = latP - latA;
    final t = math.max(0.0, math.min(1.0, (px * dx + py * dy) / segLenSq));

    final projLat = latA + t * (latB - latA);
    final projLon = lonA + t * (lonB - lonA);

    return _distanceCalc.as(
      LengthUnit.Meter,
      p,
      LatLng(projLat * (180 / math.pi), projLon * (180 / math.pi)),
    );
  }

  Future<void> _checkAndTriggerReroute(LatLng currentLoc) async {
    final now = DateTime.now();
    if (_lastRerouteTime != null && now.difference(_lastRerouteTime!).inSeconds < 10) {
      return; // Throttled to once every 10s
    }

    _lastRerouteTime = now;
    _offRouteConsecutiveFixes = 0;

    if (_destination == null) return;

    try {
      final waypoints = [currentLoc, ..._stops.map((s) => s.location), _destination!.location];
      final newRoute = await _routingService.getRoute(
        waypoints: waypoints,
        requestAlternatives: false,
      );

      _route = newRoute;
      _currentStepIndex = 0;
      _remainingDistanceMeters = newRoute.distanceMeters;
      _remainingDurationSeconds = newRoute.durationSeconds;
      _eta = DateTime.now().add(Duration(seconds: newRoute.durationSeconds.round()));
      notifyListeners();
    } catch (_) {
      // Retain existing route if re-routing network request fails
    }
  }

  void _transitionToArrived() {
    _state = NavigationState.arrived;
    _disableWakelock();
    startPositionStream(); // Return to standard accuracy
    notifyListeners();
  }

  // ── Actions & State Transitions ────────────────────────────────────────────

  /// State 1 -> State 2: Prepare preview with given destination.
  Future<void> openRoutePreview(PlaceSearchResult destinationPlace) async {
    _destination = destinationPlace;
    _addRecentPlace(destinationPlace);
    _routeError = null;
    _state = NavigationState.previewing;
    notifyListeners();

    await calculateRoute();
  }

  /// Recalculate route between current position, stops, and destination.
  Future<void> calculateRoute() async {
    if (_destination == null) return;

    _isCalculatingRoute = true;
    _routeError = null;
    notifyListeners();

    try {
      final waypoints = [
        userLatLng,
        ..._stops.map((s) => s.location),
        _destination!.location,
      ];

      final res = await _routingService.getRoute(
        waypoints: waypoints,
        requestAlternatives: true,
      );

      _route = res;
      _remainingDistanceMeters = res.distanceMeters;
      _remainingDurationSeconds = res.durationSeconds;
      _currentStepIndex = 0;
      _eta = DateTime.now().add(Duration(seconds: res.durationSeconds.round()));
      _isCalculatingRoute = false;
      notifyListeners();
    } catch (e) {
      _isCalculatingRoute = false;
      _routeError = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// State 2 -> State 3: Enter active guidance.
  void startNavigation() {
    if (_route == null) return;
    _state = NavigationState.navigating;
    _currentStepIndex = 0;
    _isScreenCentered = true;
    _enableWakelock();
    startPositionStream(); // High accuracy
    notifyListeners();
  }

  /// State 3 -> State 1: Exit navigation guidance.
  void stopNavigation() {
    _state = NavigationState.idle;
    _route = null;
    _destination = null;
    _stops.clear();
    _currentStepIndex = 0;
    _disableWakelock();
    startPositionStream(); // Medium accuracy
    notifyListeners();
  }

  /// State 2 -> State 1: Back to default map view.
  void cancelRoutePreview() {
    _state = NavigationState.idle;
    _route = null;
    _destination = null;
    _stops.clear();
    notifyListeners();
  }

  /// Close the "You have arrived" sheet and reset to default map.
  void dismissArrived() {
    stopNavigation();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  void recenterMap() {
    _isScreenCentered = true;
    notifyListeners();
  }

  void markUserPanned() {
    if (_isScreenCentered) {
      _isScreenCentered = false;
      notifyListeners();
    }
  }

  void toggleTopoLayer() {
    _isTopoLayer = !_isTopoLayer;
    notifyListeners();
  }

  void setMode(String mode) {
    if (_selectedMode == mode) return;
    _selectedMode = mode;
    calculateRoute();
  }

  void swapStartAndDestination() {
    if (_destination == null) return;
    // Swap start and destination endpoints
    _destination = PlaceSearchResult(
      name: _currentLocationName,
      displayName: '$_currentLocationName, WA',
      location: userLatLng,
    );
    calculateRoute();
  }

  void addStop(PlaceSearchResult stop) {
    if (_stops.length < 2) {
      _stops.add(stop);
      calculateRoute();
    }
  }

  void removeStop(int index) {
    if (index >= 0 && index < _stops.length) {
      _stops.removeAt(index);
      calculateRoute();
    }
  }

  void toggleSavedPlace(PlaceSearchResult place) {
    final idx = _savedPlaces.indexWhere((p) => p.name == place.name);
    if (idx >= 0) {
      _savedPlaces.removeAt(idx);
    } else {
      _savedPlaces.add(place);
    }
    notifyListeners();
  }

  bool isPlaceSaved(PlaceSearchResult place) {
    return _savedPlaces.any((p) => p.name == place.name);
  }

  // ── POI Markers ────────────────────────────────────────────────────────────

  Future<void> togglePoiFilter(PoiType type) async {
    if (_activePoiFilter == type) {
      _activePoiFilter = null;
      _poiMarkers = [];
      _selectedPoiMarker = null;
      notifyListeners();
      return;
    }

    _activePoiFilter = type;
    _selectedPoiMarker = null;
    notifyListeners();

    switch (type) {
      case PoiType.mechanic:
        _poiMarkers = _placesPoiService.fetchNearbyMechanics(
          userLatLng,
          _currentLocationName,
        );
        break;
      case PoiType.fuel:
        _poiMarkers = await _placesPoiService.fetchFuelStations(userLatLng);
        break;
      case PoiType.restStop:
        _poiMarkers = await _placesPoiService.fetchRestStops(userLatLng);
        break;
    }
    notifyListeners();
  }

  void selectPoiMarker(PoiMarker marker) {
    _selectedPoiMarker = marker;
    notifyListeners();
  }

  void clearSelectedPoiMarker() {
    _selectedPoiMarker = null;
    notifyListeners();
  }

  // ── Geocoding ──────────────────────────────────────────────────────────────

  Future<List<PlaceSearchResult>> searchPlaces(String query) async {
    return _geocodingService.search(query);
  }

  Future<void> _reverseGeocodeCurrentLocation() async {
    final now = DateTime.now();
    if (_lastReverseGeocodeTime != null &&
        now.difference(_lastReverseGeocodeTime!).inSeconds < 5) {
      return;
    }
    _lastReverseGeocodeTime = now;

    final place = await _geocodingService.reverseGeocode(userLatLng);
    if (place != null) {
      _currentLocationName = place.name;
      _currentLocationSubtitle = place.displayName;
      notifyListeners();
    }
  }

  // ── Wakelock Management ────────────────────────────────────────────────────

  void _enableWakelock() {
    try {
      WakelockPlus.enable().catchError((_) {});
    } catch (_) {}
  }

  void _disableWakelock() {
    try {
      WakelockPlus.disable().catchError((_) {});
    } catch (_) {}
  }

  void _addRecentPlace(PlaceSearchResult place) {
    _recentPlaces.removeWhere((p) => p.name == place.name);
    _recentPlaces.insert(0, place);
    if (_recentPlaces.length > 5) {
      _recentPlaces.removeLast();
    }
  }

  void _initDefaultPlaces() {
    _savedPlaces.addAll([
      const PlaceSearchResult(
        name: 'Timber Ridge Moto Outpost',
        displayName: 'Timber Ridge Moto Outpost • North Cascades, WA',
        location: LatLng(48.520, -120.650),
        category: 'Outpost',
      ),
      const PlaceSearchResult(
        name: 'Cascade Alpine Loop Summit',
        displayName: 'Cascade Alpine Loop Summit • High Pass',
        location: LatLng(48.540, -120.620),
        category: 'Pass',
      ),
    ]);

    _recentPlaces.addAll([
      const PlaceSearchResult(
        name: 'Bear Creek Pass Rd',
        displayName: 'Bear Creek Pass Rd, Winthrop, WA',
        location: LatLng(48.510, -120.670),
      ),
      const PlaceSearchResult(
        name: 'Silver Creek Rest Area',
        displayName: 'Silver Creek Rest Area, North Cascades Highway',
        location: LatLng(48.500, -120.700),
      ),
    ]);
  }

  @override
  void dispose() {
    stopPositionStream();
    _disableWakelock();
    super.dispose();
  }
}
