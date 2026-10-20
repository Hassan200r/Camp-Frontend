import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../garage/controllers/active_bike_controller.dart';
import '../../../maintenance/controllers/maintenance_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../domain/weather_service.dart';

/// Dark Rider Banner wrapped in a soft tactile bezel ring — Cockpit Hero Card.
/// Single source of truth: reads from [ProfileController] and [ActiveBikeController].
/// Displays live clock (minute timer), area location via geolocator/Nominatim (zoom=14),
/// and weather data from [WeatherProvider].
class CockpitStatusCardWidget extends StatefulWidget {
  const CockpitStatusCardWidget({
    super.key,
    this.avatarUrl,
    this.onCtaPressed,
    this.onProfilePressed,
  });

  final String? avatarUrl;
  final VoidCallback? onCtaPressed;
  final VoidCallback? onProfilePressed;

  @override
  State<CockpitStatusCardWidget> createState() => _CockpitStatusCardWidgetState();
}

class _CockpitStatusCardWidgetState extends State<CockpitStatusCardWidget> {
  Timer? _minuteTimer;
  String _timeString = '';
  String _locationLabel = 'Locating...';
  WeatherData? _weatherData;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _minuteTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateTime();
    });
    _fetchLocationAndWeather();
  }

  @override
  void dispose() {
    _minuteTimer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final formatted = '$hour:$minute $ampm';
    if (!mounted) {
      _timeString = formatted;
      return;
    }
    if (_timeString != formatted) {
      setState(() {
        _timeString = formatted;
      });
    }
  }

  Future<void> _fetchLocationAndWeather() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _locationLabel = 'Location off');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          if (mounted) setState(() => _locationLabel = 'Location off');
          return;
        }
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        if (mounted) setState(() => _locationLabel = 'Location off');
        return;
      }

      // Nominatim reverse geocode with zoom=14 and accept-language=en (never POI-level)
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json&zoom=14&addressdetails=1&accept-language=en',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'CAMP-App/1.0 (contact: support@camp-moto.app)',
          'Accept-Language': 'en',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        String? shortArea;
        if (address != null) {
          shortArea = (address['suburb'] ??
                  address['city_district'] ??
                  address['city'] ??
                  address['town'] ??
                  address['village'] ??
                  address['county'] ??
                  address['state'])
              ?.toString();
        }
        if (shortArea == null || shortArea.trim().isEmpty) {
          final displayName = (data['display_name'] as String?) ?? '';
          final parts = displayName.split(',');
          shortArea = parts.isNotEmpty ? parts.first.trim() : 'Location off';
        }

        if (mounted) {
          setState(() {
            _locationLabel = shortArea!.trim();
            WeatherProvider.currentLocationLabel = _locationLabel;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _locationLabel = 'Location off';
            WeatherProvider.currentLocationLabel = _locationLabel;
          });
        }
      }

      // Weather data from WeatherProvider
      final weather = await WeatherProvider.service.getWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (mounted) {
        setState(() {
          _weatherData = weather;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _locationLabel = 'Location off';
          WeatherProvider.currentLocationLabel = _locationLabel;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ProfileController.instance,
        ActiveBikeController.instance,
        MaintenanceController.instance,
      ]),
      builder: (context, _) {
        final profile = ProfileController.instance;
        final riderName = profile.fullName;
        final riderFirstName = profile.firstName;
        final activeBike = ActiveBikeController.instance.activeBike;

        Widget avatarWidget;
        if (profile.avatarPath != null && profile.avatarPath!.isNotEmpty) {
          final file = File(profile.avatarPath!);
          if (file.existsSync()) {
            avatarWidget = ClipOval(
              child: Image.file(file, width: 52, height: 52, fit: BoxFit.cover),
            );
          } else {
            avatarWidget = Center(
              child: Text(
                riderFirstName.isNotEmpty ? riderFirstName[0] : 'R',
                style: GoogleFonts.manrope(
                  color: const Color(0xFFFDE68A),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }
        } else if (widget.avatarUrl != null) {
          avatarWidget = CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(widget.avatarUrl!),
          );
        } else {
          avatarWidget = Center(
            child: Text(
              riderFirstName.isNotEmpty ? riderFirstName : 'Rider',
              style: GoogleFonts.manrope(
                color: const Color(0xFFFDE68A),
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }

        final weatherText = _weatherData != null
            ? '${_weatherData!.tempInt}° • ${_weatherData!.condition}'
            : 'Weather unavailable';

        return CockpitHeroCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Section: Avatar + Rider Info ─────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: widget.onProfilePressed,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.statusYellow,
                                width: 2.5,
                              ),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4A3223), Color(0xFF2B1A10)],
                              ),
                            ),
                            child: avatarWidget,
                          ),
                          Positioned(
                            bottom: -1,
                            right: -1,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF0F172A),
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                size: 13,
                                color: AppColors.statusYellow,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Rider info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            riderName,
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Builder(
                            builder: (context) {
                              if (activeBike == null) {
                                return Text(
                                  'No Active Motorcycle',
                                  style: GoogleFonts.manrope(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }
                              final hasData = MaintenanceController.instance.hasMaintenanceData(activeBike);
                              String bikeLine = 'Active Rig • ${activeBike.name}';
                              if (hasData) {
                                final dueCount = MaintenanceController.instance.countDueItems(activeBike.id);
                                final status = dueCount > 0
                                    ? '$dueCount ${dueCount == 1 ? 'item' : 'items'} due'
                                    : 'All up to date';
                                bikeLine = 'Active Rig • ${activeBike.name} • $status';
                              }
                              return Text(
                                bikeLine,
                                style: GoogleFonts.manrope(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Status Tag Pills: Time, Location, Weather, Distance ───────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _darkPill(Icons.access_time_rounded, _timeString),
                    _darkPill(Icons.location_on_rounded, _locationLabel),
                    _darkPill(
                      Icons.wb_sunny_rounded,
                      weatherText,
                      onTap: () => Navigator.of(context)
                          .pushNamed(CampRoutes.weatherDetail),
                    ),
                    if (activeBike != null)
                      _darkPill(
                        Icons.two_wheeler_rounded,
                        '${activeBike.odometerKm} km logged',
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── CTA Banner ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                  decoration: BoxDecoration(
                    color: AppColors.cockpitBannerBg,
                    borderRadius: BorderRadius.circular(AppColors.radiusTile),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Plan Expedition Route',
                              style: GoogleFonts.manrope(
                                color: Colors.white,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Explore offline navigation & mountain passes',
                              style: GoogleFonts.manrope(
                                color: const Color(0xFFD1D5DB),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: widget.onCtaPressed,
                        icon: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.tacticalOrangeLight,
                                AppColors.tacticalOrange,
                                AppColors.tacticalOrangeDark,
                              ],
                            ),
                            boxShadow: AppColors.orangeGlow,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 44, minHeight: 44),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _darkPill(IconData icon, String label, {VoidCallback? onTap}) {
    final pillContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.statusYellow),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: const Color(0xFFE5E7EB),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: pillContent,
      );
    }
    return pillContent;
  }
}
