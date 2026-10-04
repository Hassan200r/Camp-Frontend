import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/camp_bottom_nav.dart';
import '../../../dashboard/presentation/widgets/tactical_bottom_dock_widget.dart';
import '../../domain/roadside_map_models.dart';
import '../widgets/route_detail_sheet.dart';
import '../widgets/topographic_map_canvas.dart';

class LocationPreset {
  const LocationPreset({
    required this.name,
    required this.subtitle,
    required this.coordinates,
    required this.emoji,
  });

  final String name;
  final String subtitle;
  final LatLng coordinates;
  final String emoji;
}

const List<LocationPreset> kLocationPresets = [
  LocationPreset(
    name: 'Cascade Alpine Loop',
    subtitle: 'North Cascades, WA • High Mountain Pass',
    coordinates: LatLng(48.515, -120.690),
    emoji: '🏔️',
  ),
  LocationPreset(
    name: 'Karakoram Highway Pass',
    subtitle: 'Khunjerab Border • 15,397 ft Peak',
    coordinates: LatLng(36.850, 75.430),
    emoji: '⛰️',
  ),
  LocationPreset(
    name: 'Stelvio Pass (Alps)',
    subtitle: 'Eastern Alps, Italy • 48 Hairpin Turns',
    coordinates: LatLng(46.529, 10.453),
    emoji: '❄️',
  ),
  LocationPreset(
    name: 'Moab Slickrock Trail',
    subtitle: 'Utah, USA • Red Rock Desert Adventure',
    coordinates: LatLng(38.573, -109.549),
    emoji: '🏜️',
  ),
  LocationPreset(
    name: 'Manali-Leh Highway',
    subtitle: 'Himalayas, India • High Altitude Pass',
    coordinates: LatLng(32.243, 77.189),
    emoji: '🏔️',
  ),
  LocationPreset(
    name: 'Pacific Coast Highway',
    subtitle: 'Big Sur, CA • Coastal Ridge & Cliffs',
    coordinates: LatLng(36.270, -121.808),
    emoji: '🌊',
  ),
  LocationPreset(
    name: 'Tail of the Dragon',
    subtitle: 'Deals Gap, NC/TN • 318 Curves in 11 mi',
    coordinates: LatLng(35.518, -83.921),
    emoji: '🏍️',
  ),
  LocationPreset(
    name: 'Mount Fuji Touge',
    subtitle: 'Shizuoka, Japan • Volcano Ridge',
    coordinates: LatLng(35.3606, 138.7274),
    emoji: '🗻',
  ),
];

class NavigationMapScreen extends StatefulWidget {
  const NavigationMapScreen({
    super.key,
    this.onNavigateToHome,
  });

  final VoidCallback? onNavigateToHome;

  @override
  State<NavigationMapScreen> createState() => _NavigationMapScreenState();
}

class _NavigationMapScreenState extends State<NavigationMapScreen> {
  static const Color _mapDarkBg = Color(0xFF141210);

  String _selectedFilter = 'all';
  String _userRole = 'driver'; // 'driver' or 'mechanic'
  bool _isSheetExpanded = false;
  bool _isSearching = false;

  LatLng _currentLocation = const LatLng(48.515, -120.690);
  String _currentLocationName = 'Cascade Alpine Loop';
  final TextEditingController _searchController =
      TextEditingController(text: 'Cascade Alpine Loop');

  late RoadsideSectorDataset _sectorData;
  RoadsideMechanic? _selectedMechanic;
  StrandedIncident? _selectedIncident;
  RoadsideSupplyCache? _selectedSupplyCache;
  List<LatLng> _activeRescueRoute = [];

  @override
  void initState() {
    super.initState();
    _refreshSectorDataset();
  }

  Future<void> _refreshSectorDataset() async {
    _sectorData =
        RoadsideSectorDataset.generate(_currentLocation, _currentLocationName);
    _activeRescueRoute = _sectorData.primaryRescueRoute;

    if (_sectorData.mechanics.isNotEmpty &&
        _sectorData.strandedIncidents.isNotEmpty) {
      final m = _sectorData.mechanics.first.location;
      final s = _sectorData.strandedIncidents.first.location;
      final osmRoute = await _fetchOsmRoadRoute(m, s);
      if (mounted && _selectedMechanic == null && _selectedIncident == null) {
        setState(() {
          _activeRescueRoute = osmRoute;
        });
      }
    }
  }

  /// Real OpenStreetMap OSRM road routing engine
  Future<List<LatLng>> _fetchOsmRoadRoute(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
      );
      final response = await http.get(
        url,
        headers: {
          'User-Agent':
              'MotoMechanicsApp/1.0 (OpenStreetMap Road Routing Assistance)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          if (geometry != null && geometry['coordinates'] != null) {
            final List<dynamic> coords = geometry['coordinates'] as List<dynamic>;
            return coords
                .map<LatLng>((c) => LatLng(
                      (c[1] as num).toDouble(),
                      (c[0] as num).toDouble(),
                    ))
                .toList();
          }
        }
      }
    } catch (_) {}

    return [
      start,
      LatLng(
        start.latitude + (end.latitude - start.latitude) * 0.33,
        start.longitude + (end.longitude - start.longitude) * 0.25,
      ),
      LatLng(
        start.latitude + (end.latitude - start.latitude) * 0.66,
        start.longitude + (end.longitude - start.longitude) * 0.75,
      ),
      end,
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyNewLocation(LatLng coord, String title) {
    setState(() {
      _currentLocation = coord;
      _currentLocationName = title;
      _searchController.text = title;
      _selectedMechanic = null;
      _selectedIncident = null;
      _selectedSupplyCache = null;
      _refreshSectorDataset();
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.tacticalOrange.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.tacticalOrange,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sector Updated: $title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${_sectorData.mechanics.length} Rescuers • ${_sectorData.strandedIncidents.length} SOS Beacons loaded',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.darkCharcoal,
        duration: const Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Future<void> _searchLocation(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a location name, pass, or coordinates.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // 1. Check if user typed coordinates e.g. "48.515, -120.690"
    final coordRegEx =
        RegExp(r'^([+-]?\d+(?:\.\d+)?)[,\s]+([+-]?\d+(?:\.\d+)?)$');
    final coordMatch = coordRegEx.firstMatch(trimmed);
    if (coordMatch != null) {
      final lat = double.tryParse(coordMatch.group(1)!);
      final lng = double.tryParse(coordMatch.group(2)!);
      if (lat != null &&
          lng != null &&
          lat >= -90 &&
          lat <= 90 &&
          lng >= -180 &&
          lng <= 180) {
        final newCoord = LatLng(lat, lng);
        final newTitle =
            'Sector (${lat.toStringAsFixed(3)}°, ${lng.toStringAsFixed(3)}°)';
        _applyNewLocation(newCoord, newTitle);
        setState(() {
          _isSearching = false;
        });
        return;
      }
    }

    // 2. Check offline presets
    final lower = trimmed.toLowerCase();
    for (final preset in kLocationPresets) {
      if (preset.name.toLowerCase().contains(lower) ||
          lower.contains(preset.name.toLowerCase()) ||
          preset.subtitle.toLowerCase().contains(lower)) {
        _applyNewLocation(preset.coordinates, preset.name);
        setState(() {
          _isSearching = false;
        });
        return;
      }
    }

    // Extra keywords
    if (lower.contains('karakoram') ||
        lower.contains('khunjerab') ||
        lower.contains('k2')) {
      _applyNewLocation(
          const LatLng(36.850, 75.430), 'Karakoram Highway Pass');
      setState(() => _isSearching = false);
      return;
    } else if (lower.contains('cascade') || lower.contains('washington')) {
      _applyNewLocation(
          const LatLng(48.515, -120.690), 'Cascade Alpine Loop');
      setState(() => _isSearching = false);
      return;
    } else if (lower.contains('stelvio') ||
        lower.contains('alps') ||
        lower.contains('italy')) {
      _applyNewLocation(
          const LatLng(46.529, 10.453), 'Stelvio Alpine Pass');
      setState(() => _isSearching = false);
      return;
    } else if (lower.contains('moab') || lower.contains('utah')) {
      _applyNewLocation(
          const LatLng(38.573, -109.549), 'Moab Slickrock Trail');
      setState(() => _isSearching = false);
      return;
    }

    // 3. Online Geocoding via OpenStreetMap Nominatim
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(trimmed)}&format=json&limit=1',
      );
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'CampApp/1.0 (flutter_map_geosearch)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        if (data.isNotEmpty) {
          final item = data.first as Map<String, dynamic>;
          final double? lat = double.tryParse(item['lat']?.toString() ?? '');
          final double? lon = double.tryParse(item['lon']?.toString() ?? '');

          if (lat != null && lon != null) {
            final String displayName = (item['display_name'] as String?) ?? trimmed;
            final parts = displayName.split(',');
            String shortName = parts.take(2).join(',').trim();
            if (shortName.isEmpty) shortName = trimmed;

            _applyNewLocation(LatLng(lat, lon), shortName);
            setState(() => _isSearching = false);
            return;
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Could not find "$trimmed". Try a preset or coordinates.'),
          backgroundColor: AppColors.alertRed,
          action: SnackBarAction(
            label: 'Presets',
            textColor: Colors.white,
            onPressed: _showEditLocationModal,
          ),
        ),
      );
    }
  }

  void _showEditLocationModal() {
    final latController = TextEditingController(
      text: _currentLocation.latitude.toStringAsFixed(4),
    );
    final lngController = TextEditingController(
      text: _currentLocation.longitude.toStringAsFixed(4),
    );
    final nameController = TextEditingController(text: _currentLocationName);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalContext).viewInsets.bottom,
            ),
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(modalContext).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF181513),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.tacticalOrange.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                AppColors.tacticalOrange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.tacticalOrange
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Icon(
                            Icons.edit_location_alt_rounded,
                            color: AppColors.tacticalOrange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EDIT MAP SECTOR',
                                style: TextStyle(
                                  color: AppColors.tacticalOrangeLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Relocate Roadside Sector',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'SECTOR OR CITY NAME',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          const Icon(Icons.pin_drop_rounded,
                              color: AppColors.tacticalOrange, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: nameController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                hintText:
                                    'e.g. Karakoram Highway, Moab, Alps...',
                                hintStyle: TextStyle(
                                    color: Colors.white38, fontSize: 13),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (val) {
                                Navigator.pop(ctx);
                                _searchLocation(val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'PRECISE GPS COORDINATES',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white12),
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              controller: latController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Latitude',
                                labelStyle: TextStyle(
                                    color: Colors.white54, fontSize: 12),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white12),
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              controller: lngController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Longitude',
                                labelStyle: TextStyle(
                                    color: Colors.white54, fontSize: 12),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'QUICK RESCUE SECTOR PRESETS',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kLocationPresets.map((preset) {
                        final isSelected = (_currentLocation.latitude -
                                        preset.coordinates.latitude)
                                    .abs() <
                                0.01 &&
                            (_currentLocation.longitude -
                                        preset.coordinates.longitude)
                                    .abs() <
                                0.01;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              nameController.text = preset.name;
                              latController.text = preset
                                  .coordinates.latitude
                                  .toStringAsFixed(4);
                              lngController.text = preset
                                  .coordinates.longitude
                                  .toStringAsFixed(4);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.tacticalOrange
                                      .withValues(alpha: 0.25)
                                  : Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.tacticalOrange
                                    : Colors.white12,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(preset.emoji,
                                    style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 6),
                                Text(
                                  preset.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final inputName = nameController.text.trim();
                          final lat =
                              double.tryParse(latController.text.trim());
                          final lng =
                              double.tryParse(lngController.text.trim());

                          Navigator.pop(ctx);

                          if (lat != null &&
                              lng != null &&
                              lat >= -90 &&
                              lat <= 90 &&
                              lng >= -180 &&
                              lng <= 180) {
                            final title = inputName.isNotEmpty
                                ? inputName
                                : 'Sector (${lat.toStringAsFixed(3)}°, ${lng.toStringAsFixed(3)}°)';
                            _applyNewLocation(LatLng(lat, lng), title);
                          } else if (inputName.isNotEmpty) {
                            _searchLocation(inputName);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tacticalOrange,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.near_me_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Apply & Relocate Map',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Emergency Breakdown Broadcast Modal for Stranded Drivers
  void _showReportBreakdownModal() {
    String selectedVehicle = 'KTM 890 Adventure R';
    BreakdownCategory selectedCategory = BreakdownCategory.flatTire;
    const BreakdownSeverity selectedSeverity = BreakdownSeverity.high;
    final notesController = TextEditingController(
        text: 'Front tire valve torn on rocky ascent. Has spare tube.');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
            ),
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(modalCtx).size.height * 0.88,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF181513),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.alertRed.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.7),
                    blurRadius: 28,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notch
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.alertRed
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.alertRed
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Icon(
                            Icons.emergency_rounded,
                            color: AppColors.alertRed,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BROADCAST BREAKDOWN SOS',
                                style: TextStyle(
                                  color: AppColors.alertRed,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Alert Rescuers & Mobile Units',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Breakdown Type Selector
                    const Text(
                      'BREAKDOWN CATEGORY',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: BreakdownCategory.values.map((cat) {
                        final isSel = selectedCategory == cat;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedCategory = cat;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? AppColors.alertRed
                                      .withValues(alpha: 0.25)
                                  : Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel
                                    ? AppColors.alertRed
                                    : Colors.white12,
                                width: isSel ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cat == BreakdownCategory.flatTire
                                      ? Icons.tire_repair_rounded
                                      : (cat == BreakdownCategory.deadBattery
                                          ? Icons.battery_alert_rounded
                                          : (cat == BreakdownCategory.engineFailure
                                              ? Icons.warning_rounded
                                              : (cat ==
                                                      BreakdownCategory
                                                          .brokenChain
                                                  ? Icons.link_off_rounded
                                                  : (cat ==
                                                          BreakdownCategory
                                                              .outOfFuel
                                                      ? Icons
                                                          .local_gas_station_rounded
                                                      : Icons
                                                          .car_crash_rounded)))),
                                  size: 15,
                                  color: isSel
                                      ? Colors.white
                                      : AppColors.alertRed,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cat == BreakdownCategory.flatTire
                                      ? 'Flat Tire'
                                      : (cat == BreakdownCategory.deadBattery
                                          ? 'Dead Battery'
                                          : (cat ==
                                                  BreakdownCategory.engineFailure
                                              ? 'Engine Stall'
                                              : (cat ==
                                                      BreakdownCategory
                                                          .brokenChain
                                                  ? 'Chain Break'
                                                  : (cat ==
                                                          BreakdownCategory
                                                              .outOfFuel
                                                      ? 'Out of Fuel'
                                                      : 'Tow Needed')))),
                                  style: TextStyle(
                                    color: isSel ? Colors.white : Colors.white70,
                                    fontSize: 12,
                                    fontWeight: isSel
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Vehicle Rig Selection
                    const Text(
                      'YOUR MOTORCYCLE / RIG',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedVehicle,
                          dropdownColor: const Color(0xFF1E1B18),
                          isExpanded: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'KTM 890 Adventure R',
                              child: Text('KTM 890 Adventure R'),
                            ),
                            DropdownMenuItem(
                              value: 'BMW R1250GS Trophy',
                              child: Text('BMW R1250GS Trophy'),
                            ),
                            DropdownMenuItem(
                              value: 'Honda Africa Twin 1100',
                              child: Text('Honda Africa Twin 1100'),
                            ),
                            DropdownMenuItem(
                              value: 'Yamaha Ténéré 700',
                              child: Text('Yamaha Ténéré 700'),
                            ),
                            DropdownMenuItem(
                              value: 'Royal Enfield Himalayan 450',
                              child: Text('Royal Enfield Himalayan 450'),
                            ),
                            DropdownMenuItem(
                              value: 'Custom Adventure Rig',
                              child: Text('Custom Adventure Rig'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedVehicle = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Details / Landmark Notes
                    const Text(
                      'DESCRIBE ISSUE & LOCATION LANDMARKS',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: TextField(
                        controller: notesController,
                        maxLines: 3,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                        ),
                        decoration: const InputDecoration(
                          hintText:
                              'e.g. Near mile marker 44, trail crossing...',
                          hintStyle:
                              TextStyle(color: Colors.white38, fontSize: 13),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Broadcast Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          final newIncident = StrandedIncident(
                            id: 'user-sos-${DateTime.now().millisecondsSinceEpoch}',
                            driverName: 'You (Broadcast Active)',
                            vehicleModel: selectedVehicle,
                            category: selectedCategory,
                            severity: selectedSeverity,
                            issueDescription: notesController.text.trim(),
                            location: _currentLocation,
                            distance: '0.0 km (Your Spot)',
                            eta: 'Immediate Broadcast',
                            phone: '+1 (555) 992-0012',
                            timeReported: 'Just now',
                            isUserReported: true,
                          );

                          setState(() {
                            _sectorData.strandedIncidents.insert(0, newIncident);
                            _selectedIncident = newIncident;
                            _selectedMechanic = null;
                            _isSheetExpanded = true;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: AppColors.alertRed, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'SOS EMERGENCY SIGNAL BROADCAST!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          '${_sectorData.mechanics.length} nearby mobile rescue units alerted',
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.darkCharcoal,
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.alertRed,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cell_tower_rounded,
                                color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Transmit Emergency SOS Beacon',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleCall(String name, String phone) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCharcoal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.statusGreen.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_in_talk_rounded,
                  color: AppColors.statusGreen, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Initiate Call',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connecting to $name',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              phone,
              style: const TextStyle(
                color: AppColors.tacticalOrange,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Emergency frequency backed up via VHF Channel 4 (151.625 MHz)',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Dialing $phone...'),
                  backgroundColor: AppColors.statusGreen,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Dial Now',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _handleStartTurnByTurn() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.dockBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.tacticalOrange.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: AppColors.dockShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.tacticalOrange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.navigation_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LIVE RESCUE DISPATCH GUIDANCE',
                        style: TextStyle(
                          color: AppColors.tacticalOrangeLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        _selectedIncident != null
                            ? 'En route to ${_selectedIncident!.driverName} • Bear right in 0.8 mi'
                            : 'In 1.2 mi • Bear right onto Alpine Pass Trail',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Dispatch ETA',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '8 mins',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Target Distance',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '3.4 km',
                        style: TextStyle(
                          color: AppColors.statusYellow,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Radio Channel',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Ch 4 VHF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tacticalOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'End Navigation Guidance',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.clay,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Top Section (Top Bar, Role Switcher, Search Bar, Filter Chips) + Map
            Column(
              children: [
                // 1. Top Bar
                _buildTopBar(),

                // 2. Role Selector (Stranded Driver vs Field Mechanic)
                _buildRoleSelector(),

                // 3. Search Bar with Edit button and Voice mic
                _buildSearchBar(),

                // 4. Category Filter Chips (All, SOS Breakdown, Mechanics, etc.)
                _buildFilterChips(),

                const SizedBox(height: 8),

                // 5. Interactive Real Map Area
                Expanded(
                  child: Container(
                    color: _mapDarkBg,
                    child: TopographicMapCanvas(
                      initialCenter: _currentLocation,
                      locationName: _currentLocationName,
                      selectedFilter: _selectedFilter,
                      userRole: _userRole,
                      mechanics: _sectorData.mechanics,
                      strandedIncidents: _sectorData.strandedIncidents,
                      supplyCaches: _sectorData.supplyCaches,
                      activeRescueRoute: _activeRescueRoute,
                      selectedMechanic: _selectedMechanic,
                      selectedIncident: _selectedIncident,
                      onMechanicTapped: (mech) async {
                        setState(() {
                          _selectedMechanic = mech;
                          _selectedIncident = null;
                          _selectedSupplyCache = null;
                          _isSheetExpanded = true;
                        });
                        final route =
                            await _fetchOsmRoadRoute(mech.location, _currentLocation);
                        if (mounted && _selectedMechanic?.id == mech.id) {
                          setState(() {
                            _activeRescueRoute = route;
                          });
                        }
                      },
                      onIncidentTapped: (incident) async {
                        setState(() {
                          _selectedIncident = incident;
                          _selectedMechanic = null;
                          _selectedSupplyCache = null;
                          _isSheetExpanded = true;
                        });
                        if (_sectorData.mechanics.isNotEmpty) {
                          final m = _sectorData.mechanics.first.location;
                          final route =
                              await _fetchOsmRoadRoute(m, incident.location);
                          if (mounted && _selectedIncident?.id == incident.id) {
                            setState(() {
                              _activeRescueRoute = route;
                            });
                          }
                        }
                      },
                      onSupplyCacheTapped: (cache) {
                        setState(() {
                          _selectedSupplyCache = cache;
                          _selectedMechanic = null;
                          _selectedIncident = null;
                          _isSheetExpanded = true;
                        });
                      },
                      onLocationChanged: (newLoc) {
                        setState(() {
                          _currentLocation = newLoc;
                          _refreshSectorDataset();
                        });
                      },
                      onLocationNameChanged: (newName) {
                        setState(() {
                          _currentLocationName = newName;
                          _searchController.text = newName;
                        });
                      },
                      onOpenGoogleMaps: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Exporting rescue coordinates to Google Maps for $_currentLocationName...'),
                            backgroundColor: AppColors.tacticalOrange,
                            duration: const Duration(milliseconds: 1400),
                          ),
                        );
                      },
                      onToggle3D: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Toggled 3D Topographic Terrain View'),
                            duration: Duration(milliseconds: 1000),
                          ),
                        );
                      },
                      onToggleLayers: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Switched Map Style Tileset'),
                            duration: Duration(milliseconds: 1000),
                          ),
                        );
                      },
                      onRecenter: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Recalibrated GPS to $_currentLocationName (${_currentLocation.latitude.toStringAsFixed(3)}°, ${_currentLocation.longitude.toStringAsFixed(3)}°)'),
                            duration: const Duration(milliseconds: 1200),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            // 6. Floating SOS / Assistance Action Button
            Positioned(
              right: 16,
              bottom: _isSheetExpanded ? 340 : 226,
              child: GestureDetector(
                onTap: _showReportBreakdownModal,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emergency_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _userRole == 'driver'
                            ? '🚨 REPORT SOS / BREAKDOWN'
                            : '📡 BROADCAST PIT DISPATCH',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 7. Expandable Contextual Detail Sheet (Mechanic / Incident / Sector)
            Positioned(
              left: 0,
              right: 0,
              bottom: 96,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                height: _isSheetExpanded
                    ? math.min(
                        MediaQuery.of(context).size.height * 0.68, 520.0)
                    : 118.0,
                child: RouteDetailSheet(
                  title: _currentLocationName,
                  userRole: _userRole,
                  isExpanded: _isSheetExpanded,
                  selectedMechanic: _selectedMechanic,
                  selectedIncident: _selectedIncident,
                  selectedSupplyCache: _selectedSupplyCache,
                  onToggleExpand: () {
                    setState(() {
                      _isSheetExpanded = !_isSheetExpanded;
                    });
                  },
                  onExpand: () {
                    if (!_isSheetExpanded) {
                      setState(() {
                        _isSheetExpanded = true;
                      });
                    }
                  },
                  onCollapse: () {
                    if (_isSheetExpanded) {
                      setState(() {
                        _isSheetExpanded = false;
                      });
                    }
                  },
                  onCompassTap: () {
                    setState(() {
                      _isSheetExpanded = !_isSheetExpanded;
                    });
                  },
                  onClearSelection: () {
                    setState(() {
                      _selectedMechanic = null;
                      _selectedIncident = null;
                      _selectedSupplyCache = null;
                      _activeRescueRoute = _sectorData.primaryRescueRoute;
                    });
                  },
                  onCall: () {
                    if (_selectedIncident != null) {
                      _handleCall(_selectedIncident!.driverName,
                          _selectedIncident!.phone);
                    } else if (_selectedMechanic != null) {
                      _handleCall(_selectedMechanic!.name,
                          _selectedMechanic!.phone);
                    }
                  },
                  onAcceptRescue: () {
                    _handleStartTurnByTurn();
                  },
                  onRequestDispatch: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Dispatch request sent to ${_selectedMechanic?.name}! ETA: ${_selectedMechanic?.eta}'),
                        backgroundColor: AppColors.statusGreen,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  onStartTurnByTurn: _handleStartTurnByTurn,
                  onBrowseOfflinePacks: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Downloaded emergency radio & offline distress pack for $_currentLocationName!'),
                        backgroundColor: AppColors.tacticalOrange,
                        duration: const Duration(milliseconds: 1400),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 8. Floating Bottom Navigation Dock (Centered, bottom: 24)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: TacticalBottomDockWidget(
                  selectedIndex: 2,
                  onIndexChanged: (index) {
                    CampBottomNav.navigateToTab(context, index, currentIndex: 2);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Bar with Back Button, CAMP Logo Badge, and "ROADSIDE RESCUE" Badge
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Back Button
          GestureDetector(
            onTap: () {
              if (widget.onNavigateToHome != null) {
                widget.onNavigateToHome!();
              } else if (Navigator.of(context).canPop()) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.clay,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.clayDark, width: 1.2),
                boxShadow: AppColors.skeuRaisedSmall,
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ),
          ),

          const SizedBox.shrink(),

          // Right "ROADSIDE RESCUE" Pill Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.clay,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.clayDark, width: 1.2),
              boxShadow: AppColors.skeuRaisedSmall,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.alertRed,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'ROADSIDE RESCUE',
                  style: AppTextStyles.overline.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Segmented Role Switcher: Stranded Driver vs Field Mechanic
  Widget _buildRoleSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      child: Container(
        height: 38,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.clayDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Driver Mode
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _userRole = 'driver';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _userRole == 'driver'
                        ? AppColors.clay
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: _userRole == 'driver'
                        ? AppColors.skeuRaisedSmall
                        : [],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sports_motorsports_rounded,
                          size: 15,
                          color: _userRole == 'driver'
                              ? AppColors.tacticalOrange
                              : AppColors.mutedText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Stranded Driver',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            fontWeight: _userRole == 'driver'
                                ? FontWeight.w900
                                : FontWeight.w700,
                            color: _userRole == 'driver'
                                ? AppColors.darkCharcoal
                                : AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Mechanic Mode
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _userRole = 'mechanic';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _userRole == 'mechanic'
                        ? AppColors.clay
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: _userRole == 'mechanic'
                        ? AppColors.skeuRaisedSmall
                        : [],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.handyman_rounded,
                          size: 15,
                          color: _userRole == 'mechanic'
                              ? AppColors.tacticalOrange
                              : AppColors.mutedText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Field Mechanic',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            fontWeight: _userRole == 'mechanic'
                                ? FontWeight.w900
                                : FontWeight.w700,
                            color: _userRole == 'mechanic'
                                ? AppColors.darkCharcoal
                                : AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Search Bar with magnifying glass, dynamic input, Edit location button, and Mic
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.clay,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.clayDark, width: 1.2),
          boxShadow: AppColors.skeuRaised,
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            // Search icon or loading spinner
            GestureDetector(
              onTap: () => _searchLocation(_searchController.text),
              child: _isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.tacticalOrange,
                      ),
                    )
                  : const Icon(
                      Icons.search_rounded,
                      color: AppColors.mutedLight,
                      size: 22,
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (val) => _searchLocation(val),
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkCharcoal,
                ),
                decoration: InputDecoration(
                  hintText: 'Search sector or coordinates (e.g. 48.5, -120.6)...',
                  hintStyle: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 12.5,
                    color: AppColors.mutedText,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            // Edit Location Action Badge
            GestureDetector(
              onTap: _showEditLocationModal,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: AppColors.tacticalOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.tacticalOrange.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.edit_location_alt_rounded,
                      color: AppColors.tacticalOrange,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Edit',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.tacticalOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Mic voice search button
            GestureDetector(
              key: const Key('map_search_bar_mic_btn'),
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pushNamed(context, '/mechanics/voice-assistant');
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                child: Icon(
                  Icons.mic_rounded,
                  color: AppColors.tacticalOrangeDark,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Horizontal Category Chips: All, SOS Breakdowns, Mobile Mechanics, Garages, Fuel & Parts
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0, bottom: 2.0),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            _buildChipItem(
              id: 'all',
              label: 'All Assets (${_sectorData.mechanics.length + _sectorData.strandedIncidents.length + _sectorData.supplyCaches.length})',
              icon: Icons.grid_view_rounded,
              isSelected: _selectedFilter == 'all',
            ),
            const SizedBox(width: 8),
            _buildChipItem(
              id: 'stranded',
              label: '🚨 SOS Distress (${_sectorData.strandedIncidents.length})',
              icon: Icons.emergency_rounded,
              isSelected: _selectedFilter == 'stranded',
              highlightColor: AppColors.alertRed,
            ),
            const SizedBox(width: 8),
            _buildChipItem(
              id: 'mechanics',
              label: '🛠️ Rescuers (${_sectorData.mechanics.length})',
              icon: Icons.handyman_rounded,
              isSelected: _selectedFilter == 'mechanics',
            ),
            const SizedBox(width: 8),
            _buildChipItem(
              id: 'fuel',
              label: '⛽ Fuel & Caches (${_sectorData.supplyCaches.length})',
              icon: Icons.local_gas_station_rounded,
              isSelected: _selectedFilter == 'fuel',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipItem({
    required String id,
    required String label,
    required IconData icon,
    required bool isSelected,
    Color? highlightColor,
  }) {
    final activeColor = highlightColor ?? AppColors.tacticalOrange;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.clayDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.clayDark,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? AppColors.orangeGlow
              : AppColors.skeuRaisedSmall,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.mutedText,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.darkCharcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
