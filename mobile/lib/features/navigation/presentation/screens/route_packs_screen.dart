import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/camp_app_bar.dart';
import '../../../../core/widgets/camp_bottom_nav.dart';
import '../../../dashboard/presentation/widgets/app_drawer_widget.dart';
import '../../domain/route_pack_model.dart';
import '../widgets/route_pack_card_widget.dart';
import '../widgets/route_packs_section_header_widget.dart';
import '../widgets/route_packs_title_widget.dart';
import '../widgets/storage_allocation_card_widget.dart';

/// Screen displaying offline route packs and topographic regions cached on device.
/// Conforms to the official CAMP design system and modular component structure.
class RoutePacksScreen extends StatefulWidget {
  const RoutePacksScreen({super.key});

  @override
  State<RoutePacksScreen> createState() => _RoutePacksScreenState();
}

class _RoutePacksScreenState extends State<RoutePacksScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isWifiAutoUpdate = true;
  late List<RoutePack> _packs;

  @override
  void initState() {
    super.initState();
    _packs = List.from(RoutePack.defaultPacks);
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2200),
      ),
    );
  }

  void _handlePackAction(RoutePack pack) {
    switch (pack.actionType) {
      case RoutePackActionType.syncUpdate:
        _showNotification('Syncing update for ${pack.title}...');
        break;
      case RoutePackActionType.pause:
        _showNotification('Paused download for ${pack.title}');
        break;
      case RoutePackActionType.download:
        _showNotification('Starting download for ${pack.title} (${pack.sizeMb} MB)...');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawerWidget(),
      backgroundColor: AppColors.clay,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppColors.screenPadding,
                8.0,
                AppColors.screenPadding,
                110.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 1. Top App Bar ─────────────────────────────────────────
                  // Leading hamburger menu, unified CAMP logo, and GPS LIVE action pill
                  CampAppBar(
                    leading: CampAppBarLeading.menu,
                    onLeadingPressed: () =>
                        _scaffoldKey.currentState?.openDrawer(),
                    actionWidget: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.clay,
                        borderRadius:
                            BorderRadius.circular(AppColors.radiusPill),
                        boxShadow: AppColors.skeuRaisedSmall,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.statusGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'GPS LIVE',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkCharcoal,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── 2. Title Block ─────────────────────────────────────────
                  // TELEMETRY HUB eyebrow + Route Packs title + Topo V4.8 sync pill
                  RoutePacksTitleWidget(
                    version: 'Topo V4.8',
                    onVersionTap: () =>
                        _showNotification('Topographic Mesh V4.8 up to date'),
                  ),

                  const SizedBox(height: AppColors.cardGap),

                  // ── 3. Storage Allocation Card ─────────────────────────────
                  StorageAllocationCardWidget(
                    usedGb: '3.4 GB',
                    totalFreeGb: '32 GB Free',
                    isWifiAutoUpdate: _isWifiAutoUpdate,
                    onWifiAutoUpdateChanged: (val) {
                      setState(() {
                        _isWifiAutoUpdate = val;
                      });
                      _showNotification(
                        val
                            ? 'Auto-update via Wi-Fi enabled'
                            : 'Auto-update via Wi-Fi disabled',
                      );
                    },
                  ),

                  const SizedBox(height: AppColors.cardGap + 2),

                  // ── 4. Section Header ──────────────────────────────────────
                  // OFFLINE TELEMETRY & TOPO PACKS + 5 Regions Available
                  const RoutePacksSectionHeaderWidget(
                    eyebrow: 'OFFLINE TELEMETRY & TOPO PACKS',
                    trailingLabel: '5 Regions Available',
                  ),

                  const SizedBox(height: 12),

                  // ── 5. Five Pack Cards ─────────────────────────────────────
                  for (int i = 0; i < _packs.length; i++) ...[
                    RoutePackCardWidget(
                      pack: _packs[i],
                      onActionTap: () => _handlePackAction(_packs[i]),
                    ),
                    if (i < _packs.length - 1)
                      const SizedBox(height: AppColors.cardGap),
                  ],
                ],
              ),
            ),
          ),

          // ── 6. Floating Tactical Bottom Dock (Index 2: Navigation) ─────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: CampBottomNav(
                selectedIndex: 2,
                onIndexChanged: (index) {
                  CampBottomNav.navigateToTab(
                    context,
                    index,
                    currentIndex: 2,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
