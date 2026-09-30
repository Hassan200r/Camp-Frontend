import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                    children: [
                      // 1. Header row
                      RideHistoryHeaderRowWidget(
                        count: 24,
                        onDownload: () {},
                      ),

                      const SizedBox(height: 14),

                      // 2. Filter chips (no horizontal padding — widget handles
                      //    its own scrollable Row internally)
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
                        actionLabel: 'See All',
                        onAction: () {},
                        padding: const EdgeInsets.only(bottom: 10),
                      ),

                      // 6. Three expedition cards
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

                      // 7. Load more CTA
                      LoadMoreButtonWidget(onTap: () {}),
                    ],
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
