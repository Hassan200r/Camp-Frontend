import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../maintenance/controllers/post_ride_report_controller.dart';
import '../../domain/expedition_log_model.dart';
import '../widgets/expedition_card_widget.dart';
import '../widgets/latest_expedition_card_widget.dart';
import '../widgets/load_more_button_widget.dart';
import '../widgets/ride_filter_chips_widget.dart';
import '../widgets/ride_history_header_row_widget.dart';
import '../widgets/season_summary_card_widget.dart';

/// Ride History screen — Widget #0 (root screen).
///
/// Layout (top → bottom inside a single [ListView]):
///   1. [RideHistoryHeaderRowWidget]  — eyebrow + title + badge + download btn
///   2. [RideFilterChipsWidget]       — horizontally scrollable filter chips
///   3. [SeasonSummaryCardWidget]     — Season 2024 summary stats
///   4. [LatestExpeditionCardWidget]  — dark cockpit hero card
///   5. Three [ExpeditionCardWidget]s — sample expedition log cards
///   6. [LoadMoreButtonWidget]        — "Load 20 Earlier Expedition Logs" CTA
///
/// Uses [CampAppBar] (leading: back, action: LOGS) and [CampBottomNav]
/// (selectedIndex: 4) per the CAMP design system mandate.
class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  int _activeFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.clay,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── App bar ─────────────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: CampAppBar(
                    leading: CampAppBarLeading.back,
                    actionText: 'LOGS',
                  ),
                ),

                // ── Scrollable body ─────────────────────────────────────────
                Expanded(
                  child: ListenableBuilder(
                    listenable: PostRideReportController.instance,
                    builder: (context, _) {
                      final reports =
                          PostRideReportController.instance.reports;
                      final bool showSamples =
                          reports.isEmpty && kDebugMode;
                      final int totalCount = reports.isNotEmpty
                          ? reports.length
                          : (showSamples ? ExpeditionLog.samples.length : 0);

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                        children: [
                          // 1. Header row
                          RideHistoryHeaderRowWidget(
                            count: totalCount,
                            onDownload: () {},
                          ),

                          const SizedBox(height: 14),

                          // 2. Filter chips
                          Padding(
                            padding: EdgeInsets.zero,
                            child: RideFilterChipsWidget(
                              initialSelected: _activeFilter,
                              onFilterChanged: (i) =>
                                  setState(() => _activeFilter = i),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 3. Season summary
                          const SeasonSummaryCardWidget(),

                          const SizedBox(height: 16),

                          // 4. Latest expedition hero card
                          LatestExpeditionCardWidget(
                            onMenuActionSelected: (_) {},
                          ),

                          const SizedBox(height: 20),

                          // 5. Section label for past expeditions
                          SectionHeader(
                            title: 'Past Expeditions',
                            actionLabel: totalCount > 0 ? 'See All' : null,
                            onAction: totalCount > 0 ? () {} : null,
                            padding: const EdgeInsets.only(bottom: 10),
                          ),

                          // 6. Expedition cards or empty state
                          if (totalCount == 0) ...[
                            CampEmptyState(
                              icon: Icons.history_rounded,
                              message: 'No expedition logs recorded yet',
                              ctaLabel: 'Plan a ride',
                              onCta: () => Navigator.of(context)
                                  .pushNamed(CampRoutes.navigationMap),
                            ),
                          ] else if (showSamples) ...[
                            ...ExpeditionLog.samples.map(
                              (log) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ExpeditionCardWidget(
                                  log: log,
                                  onMoreTap: () {},
                                  onLinkTap: () {},
                                ),
                              ),
                            ),
                            LoadMoreButtonWidget(onTap: () {}),
                          ] else ...[
                            ...reports.map(
                              (report) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ExpeditionCardWidget(
                                  log: ExpeditionLog(
                                    date:
                                        '${report.date.month}/${report.date.day}/${report.date.year}',
                                    tag: report.terrainTags.isNotEmpty
                                        ? report.terrainTags.first
                                        : 'Ride',
                                    tagVariant: StatusChipVariant.success,
                                    icon: Icons.terrain_rounded,
                                    title: report.notes?.isNotEmpty == true
                                        ? report.notes!
                                        : 'Ride on ${report.date.month}/${report.date.day}',
                                    route:
                                        '${report.distanceKm.round()} km',
                                    bike: 'Logged Ride',
                                    stats: const [],
                                    footer: ExpeditionFooterChips(
                                        report.terrainTags.isNotEmpty
                                            ? report.terrainTags
                                            : const ['Ride']),
                                    footerLink: 'View Log',
                                  ),
                                  onMoreTap: () {},
                                  onLinkTap: () {},
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Floating bottom nav ────────────────────────────────────────────
          const Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(child: CampBottomNav(selectedIndex: 4)),
          ),
        ],
      ),
    );
  }
}
