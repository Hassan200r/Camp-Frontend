import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/weather_service.dart';

/// Hourly forecast slot model.
class HourlyForecastItem {
  const HourlyForecastItem({
    required this.time,
    required this.tempC,
    required this.icon,
    required this.condition,
  });

  final String time;
  final int tempC;
  final IconData icon;
  final String condition;
}

/// Daily forecast slot model for 7-day outlook.
class DailyForecastItem {
  const DailyForecastItem({
    required this.day,
    required this.date,
    required this.condition,
    required this.icon,
    required this.minTempC,
    required this.maxTempC,
    required this.precipitationChance,
  });

  final String day;
  final String date;
  final String condition;
  final IconData icon;
  final int minTempC;
  final int maxTempC;
  final int precipitationChance;
}

/// Weather Detail Screen
/// Displays current conditions, hourly outlook, and 7-day forecast with
/// tactical skeuomorphic layout ready for live API integration.
class WeatherDetailScreen extends StatelessWidget {
  const WeatherDetailScreen({super.key});

  static const List<HourlyForecastItem> placeholderHourly = [
    HourlyForecastItem(time: 'Now', tempC: 22, icon: Icons.wb_sunny_rounded, condition: 'Sunny'),
    HourlyForecastItem(time: '14:00', tempC: 24, icon: Icons.wb_sunny_rounded, condition: 'Clear'),
    HourlyForecastItem(time: '15:00', tempC: 25, icon: Icons.wb_sunny_rounded, condition: 'Sunny'),
    HourlyForecastItem(time: '16:00', tempC: 23, icon: Icons.wb_cloudy_rounded, condition: 'Partly Cloudy'),
    HourlyForecastItem(time: '17:00', tempC: 21, icon: Icons.wb_cloudy_rounded, condition: 'Overcast'),
    HourlyForecastItem(time: '18:00', tempC: 19, icon: Icons.nights_stay_rounded, condition: 'Clear Night'),
    HourlyForecastItem(time: '19:00', tempC: 18, icon: Icons.nights_stay_rounded, condition: 'Clear Night'),
    HourlyForecastItem(time: '20:00', tempC: 17, icon: Icons.nights_stay_rounded, condition: 'Clear Night'),
  ];

  static const List<DailyForecastItem> placeholder7Day = [
    DailyForecastItem(day: 'Today', date: 'Oct 14', condition: 'Sunny & Ideal', icon: Icons.wb_sunny_rounded, minTempC: 14, maxTempC: 25, precipitationChance: 0),
    DailyForecastItem(day: 'Thu', date: 'Oct 15', condition: 'High-Altitude Breeze', icon: Icons.air_rounded, minTempC: 12, maxTempC: 22, precipitationChance: 5),
    DailyForecastItem(day: 'Fri', date: 'Oct 16', condition: 'Partly Cloudy', icon: Icons.wb_cloudy_rounded, minTempC: 11, maxTempC: 20, precipitationChance: 15),
    DailyForecastItem(day: 'Sat', date: 'Oct 17', condition: 'Scattered Cloud', icon: Icons.cloud_queue_rounded, minTempC: 10, maxTempC: 19, precipitationChance: 20),
    DailyForecastItem(day: 'Sun', date: 'Oct 18', condition: 'Clear Riding Sky', icon: Icons.wb_sunny_rounded, minTempC: 13, maxTempC: 24, precipitationChance: 0),
    DailyForecastItem(day: 'Mon', date: 'Oct 19', condition: 'Overcast Ridge Pass', icon: Icons.cloud_rounded, minTempC: 9, maxTempC: 17, precipitationChance: 35),
    DailyForecastItem(day: 'Tue', date: 'Oct 20', condition: 'Light Mist / Fog', icon: Icons.water_drop_outlined, minTempC: 8, maxTempC: 15, precipitationChance: 40),
  ];

  @override
  Widget build(BuildContext context) {
    final bool hasKey = WeatherProvider.apiKey.isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.clay,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── App Bar ───────────────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: CampAppBar(
                  leading: CampAppBarLeading.back,
                  titleWidget: CampLogo(showIcon: false),
                  actionText: 'WEATHER',
                ),
              ),

              // ── Scrollable Forecast Body ──────────────────────────────────
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                  children: [
                    // 1. Current Weather Hero
                    _buildCurrentWeatherHero(context, hasKey),

                    const SizedBox(height: 16),

                    // 2. Hourly Outlook Section
                    SectionHeader(
                      title: 'Hourly Forecast',
                      badge: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppColors.clayDark,
                          borderRadius: BorderRadius.circular(AppColors.radiusPill),
                        ),
                        child: Text(
                          'Next 8 Hours',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildHourlyStrip(hasKey),

                    const SizedBox(height: 20),

                    // 3. 7-Day Forecast Section
                    SectionHeader(
                      title: '7-Day Outlook',
                      badge: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppColors.clayDark,
                          borderRadius: BorderRadius.circular(AppColors.radiusPill),
                        ),
                        child: Text(
                          'Route Planning',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _build7DayForecastCard(hasKey),

                    const SizedBox(height: 16),

                    // 4. API Notice / Configuration Card
                    _buildApiNotice(hasKey),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherHero(BuildContext context, bool hasKey) {
    return CockpitHeroCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT AREA',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.tacticalOrange,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      WeatherProvider.currentLocationLabel.isNotEmpty
                          ? WeatherProvider.currentLocationLabel
                          : 'Location off',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.wb_sunny_rounded,
                      color: AppColors.statusYellow,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  hasKey ? '22°' : '--°',
                  style: GoogleFonts.manrope(
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasKey ? 'Ideal Riding' : 'Add weather API key',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFDE68A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasKey ? 'High: 25°C • Low: 14°C' : 'Card ready for live radar feed',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(height: 1, color: Color(0x22FFFFFF)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _heroMetric(Icons.air_rounded, 'WIND', hasKey ? '12 km/h' : '--'),
                _heroMetric(Icons.water_drop_outlined, 'HUMIDITY', hasKey ? '42%' : '--'),
                _heroMetric(Icons.visibility_outlined, 'VISIBILITY', hasKey ? '10 km' : '--'),
                _heroMetric(Icons.umbrella_outlined, 'RAIN', hasKey ? '0%' : '--'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroMetric(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyStrip(bool hasKey) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: placeholderHourly.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final slot = placeholderHourly[index];
          final isNow = index == 0;

          return Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: isNow ? AppColors.clayDark : AppColors.clay,
              borderRadius: BorderRadius.circular(AppColors.radiusTile),
              border: Border.all(
                color: isNow
                    ? AppColors.tacticalOrange.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.8),
                width: 1.2,
              ),
              boxShadow: AppColors.skeuRaisedSmall,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  slot.time,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: isNow ? FontWeight.w800 : FontWeight.w600,
                    color: isNow ? AppColors.tacticalOrange : AppColors.mutedText,
                  ),
                ),
                Icon(
                  slot.icon,
                  size: 20,
                  color: isNow ? AppColors.tacticalOrange : AppColors.darkCharcoal,
                ),
                Text(
                  hasKey ? '${slot.tempC}°' : '--',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _build7DayForecastCard(bool hasKey) {
    return CampCard(
      borderRadius: AppColors.radiusCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: placeholder7Day.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    item.day,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ),
                Icon(
                  item.icon,
                  size: 20,
                  color: AppColors.tacticalOrange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasKey ? item.condition : '--',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mutedText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  hasKey ? '${item.minTempC}°' : '--',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.clayDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: hasKey
                      ? FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (item.maxTempC - item.minTempC) / 15.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.tacticalOrangeLight,
                                  AppColors.tacticalOrange,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                Text(
                  hasKey ? '${item.maxTempC}°' : '--',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildApiNotice(bool hasKey) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.clayDark,
        borderRadius: BorderRadius.circular(AppColors.radiusTile),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.tacticalOrange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasKey
                  ? 'Weather service connected via WEATHER_API_KEY environment configuration.'
                  : 'Displaying demonstration forecast layout. Provide --dart-define=WEATHER_API_KEY at build time to activate live regional radar feeds.',
              style: GoogleFonts.manrope(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.mutedText,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
