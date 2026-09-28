import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/camp_bottom_nav.dart';
import '../../../dashboard/presentation/widgets/tactical_bottom_dock_widget.dart';
import '../../domain/mechanic_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/filter_chips_widget.dart';
import '../widgets/mechanic_card.dart';
import '../widgets/search_bar_widget.dart';
import '../../../navigation/presentation/widgets/topographic_map_canvas.dart';
import '../widgets/view_toggle_widget.dart';

class MechanicsHomeScreen extends StatefulWidget {
  const MechanicsHomeScreen({super.key});

  @override
  State<MechanicsHomeScreen> createState() => _MechanicsHomeScreenState();
}

class _MechanicsHomeScreenState extends State<MechanicsHomeScreen> {
  static const Color _mapDarkBg = Color(0xFF141210);

  static const LinearGradient _orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.tacticalOrangeLight, AppColors.tacticalOrange],
  );

  bool _isListView = true;
  String _selectedFilter = 'all';
  String _searchQuery = '';
  int _currentNavIndex = 3; // 3 is the active Mechanic (Wrench) hub
  final TextEditingController _searchController = TextEditingController();
  late List<Mechanic> _mechanicsList;

  @override
  void initState() {
    super.initState();
    _mechanicsList = List.from(Mechanic.sampleMechanics);
  }

  List<Mechanic> get _filteredMechanics {
    return _mechanicsList.where((mechanic) {
      // Filter logic
      if (_selectedFilter == 'verified' &&
          mechanic.badgeType != BadgeType.verified) {
        return false;
      }
      if (_selectedFilter == 'emergency' &&
          mechanic.badgeType != BadgeType.emergency) {
        return false;
      }
      if (_selectedFilter == 'bmw' &&
          !mechanic.tags1.any((t) => t.toLowerCase().contains('bmw'))) {
        return false;
      }
      if (_selectedFilter == 'ktm' &&
          !mechanic.tags1.any((t) => t.toLowerCase().contains('ktm'))) {
        return false;
      }
      if (_selectedFilter == 'yamaha' &&
          !mechanic.tags1.any((t) => t.toLowerCase().contains('yamaha'))) {
        return false;
      }

      // Search query logic
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = mechanic.name.toLowerCase().contains(query);
        final matchesTags1 =
            mechanic.tags1.any((t) => t.toLowerCase().contains(query));
        final matchesTags2 =
            mechanic.tags2.any((t) => t.toLowerCase().contains(query));
        return matchesName || matchesTags1 || matchesTags2;
      }

      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _navigateToAddMechanic() async {
    final newMechanic = await Navigator.pushNamed<Mechanic>(
      context,
      '/mechanics/add',
    );

    if (mounted) {
      setState(() {
        _currentNavIndex = 3;
        _isListView = true;
      });
      if (newMechanic != null) {
        setState(() {
          _mechanicsList.insert(0, newMechanic);
        });
      }
    }
  }

  Future<void> _navigateToMapScreen() async {
    setState(() {
      _currentNavIndex = 2;
    });
    await Navigator.pushNamed(
      context,
      '/mechanics/map',
    );
    if (mounted) {
      // Strictly open Mechanic Screen (Index 3)
      setState(() {
        _currentNavIndex = 3;
        _isListView = true;
      });
    }
  }

  void _showCallModal(Mechanic mechanic) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.clay,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.tacticalOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_in_talk_rounded,
                color: AppColors.tacticalOrange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Call Workshop',
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.darkCharcoal,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mechanic.name,
              style: AppTextStyles.itemTitle.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mechanic.phone,
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.tacticalOrange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Operating: ${mechanic.openStatus}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.mutedLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Dialing ${mechanic.phone}...'),
                  backgroundColor: AppColors.statusGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tacticalOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Call Now',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRouteModal(Mechanic mechanic) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.clay,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.tacticalOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.navigation_rounded,
                color: AppColors.tacticalOrange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Navigation Route',
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.darkCharcoal,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Routing to: ${mechanic.name}',
              style: AppTextStyles.itemTitle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.clayDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_bike_rounded,
                    color: AppColors.tacticalOrange,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mechanic.distance,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      Text(
                        'Estimated time: ${mechanic.durationOrLocation}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Dismiss',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.mutedLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _navigateToMapScreen();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tacticalOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Start GPS',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
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
            // Main Content Area
            Column(
              children: [
                // Top Custom App Bar
                CustomAppBar(
                  onBackTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                  onGpsTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('GPS Status: Calibrated (Accuracy: ±2m)'),
                        duration: Duration(milliseconds: 1400),
                      ),
                    );
                  },
                ),

                // Search Bar
                SearchBarWidget(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  onMicTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Listening for voice command...'),
                        duration: Duration(milliseconds: 1200),
                      ),
                    );
                  },
                ),

                // View Toggle (List View vs Map View)
                ViewToggleWidget(
                  isListView: _isListView,
                  onToggle: (isList) {
                    setState(() {
                      _isListView = isList;
                      _currentNavIndex = 3;
                    });
                  },
                ),

                // Filter Chips
                FilterChipsWidget(
                  selectedFilter: _selectedFilter,
                  onFilterSelected: (filterId) {
                    setState(() {
                      _selectedFilter = filterId;
                    });
                  },
                ),

                const SizedBox(height: 8),

                // Content View (List vs Map)
                Expanded(
                  child: _isListView ? _buildListView() : _buildMapView(),
                ),
              ],
            ),

            // Floating "+ Add Mechanic" Button
            if (_currentNavIndex == 3 || _isListView)
              Positioned(
                right: 16,
                bottom: 96,
                child: GestureDetector(
                  onTap: _navigateToAddMechanic,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      gradient: _orangeGradient,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: AppColors.orangeGlow,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Add Mechanic',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Floating Bottom Navigation Dock (Centered, bottom: 24)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: TacticalBottomDockWidget(
                  selectedIndex: 3,
                  onIndexChanged: (index) {
                    if (index == 3) {
                      setState(() {
                        _currentNavIndex = 3;
                        _isListView = true;
                      });
                    } else {
                      CampBottomNav.navigateToTab(context, index, currentIndex: 3);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    final mechanics = _filteredMechanics;

    if (mechanics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 54,
              color: AppColors.mutedLight.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'No mechanics found',
              style: AppTextStyles.cardTitle.copyWith(
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 160),
      itemCount: mechanics.length,
      itemBuilder: (context, index) {
        final mechanic = mechanics[index];
        return MechanicCard(
          mechanic: mechanic,
          onCallShop: () => _showCallModal(mechanic),
          onRouteGps: () => _showRouteModal(mechanic),
        );
      },
    );
  }

  Widget _buildMapView() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      decoration: BoxDecoration(
        color: _mapDarkBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: AppColors.dockShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(
            child: TopographicMapCanvas(),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: _navigateToMapScreen,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: _orangeGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.orangeGlow,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.navigation_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Open Full Expedition Route',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
