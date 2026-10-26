import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/data/app_repositories.dart';
import '../../../../core/data/settings_repository.dart';
import '../../../../core/widgets/camp_app_bar.dart';
import '../../../../core/widgets/camp_bottom_nav.dart';
import '../../../dashboard/presentation/widgets/app_drawer_widget.dart';
import '../../domain/route_pack_model.dart';
import '../widgets/route_pack_card_widget.dart';
import '../widgets/route_packs_section_header_widget.dart';
import '../widgets/route_packs_title_widget.dart';
import '../widgets/storage_allocation_card_widget.dart';

/// Screen displaying route packs.
/// Conforms to the official CAMP design system and honesty rules:
/// - Every pack shows "Coming soon" with no sizes or fake download states.
/// - Wi-Fi auto-update toggle persists via [SettingsRepository].
class RoutePacksScreen extends StatefulWidget {
  const RoutePacksScreen({
    super.key,
    this.settingsRepository,
  });

  final SettingsRepository? settingsRepository;

  @override
  State<RoutePacksScreen> createState() => _RoutePacksScreenState();
}

class _RoutePacksScreenState extends State<RoutePacksScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final SettingsRepository _settingsRepository;
  bool _isWifiAutoUpdate = true;
  late List<RoutePack> _packs;

  @override
  void initState() {
    super.initState();
    _settingsRepository =
        widget.settingsRepository ?? AppRepositories.instance.settingsRepository;
    _packs = List.from(RoutePack.defaultPacks);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsRepository.loadSettings();
    if (mounted) {
      setState(() {
        _isWifiAutoUpdate = settings.wifiAutoUpdateRoutePacks;
      });
    }
  }

  Future<void> _handleWifiToggle(bool val) async {
    setState(() {
      _isWifiAutoUpdate = val;
    });
    final current = await _settingsRepository.loadSettings();
    await _settingsRepository.saveSettings(
      current.copyWith(wifiAutoUpdateRoutePacks: val),
    );
    await _settingsRepository.flush();

    _showNotification(
      val
          ? 'Auto-update via Wi-Fi enabled'
          : 'Auto-update via Wi-Fi disabled',
    );
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
                  RoutePacksTitleWidget(
                    version: 'Topo V4.8',
                    onVersionTap: () =>
                        _showNotification('Topographic Mesh V4.8'),
                  ),

                  const SizedBox(height: AppColors.cardGap),

                  // ── 3. Wi-Fi Auto Update Preference Card ───────────────────
                  StorageAllocationCardWidget(
                    isWifiAutoUpdate: _isWifiAutoUpdate,
                    onWifiAutoUpdateChanged: _handleWifiToggle,
                  ),

                  const SizedBox(height: AppColors.cardGap + 2),

                  // ── 4. Section Header ──────────────────────────────────────
                  const RoutePacksSectionHeaderWidget(
                    eyebrow: 'ROUTE PACKS',
                    trailingLabel: 'Coming soon',
                  ),

                  const SizedBox(height: 12),

                  // ── 5. Five Route Pack Cards ───────────────────────────────
                  for (int i = 0; i < _packs.length; i++) ...[
                    RoutePackCardWidget(
                      pack: _packs[i],
                    ),
                    if (i < _packs.length - 1)
                      const SizedBox(height: AppColors.cardGap),
                  ],
                ],
              ),
            ),
          ),

          // ── 6. Floating Tactical Bottom Dock (Index 2: Navigation) ─────────
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
    );
  }
}
