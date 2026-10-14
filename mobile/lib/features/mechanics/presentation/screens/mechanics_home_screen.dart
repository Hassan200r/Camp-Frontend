import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../navigation/presentation/widgets/topographic_map_canvas.dart';
import '../../controllers/mechanic_controller.dart';
import '../../domain/mechanic_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/filter_chips_widget.dart';
import '../widgets/mechanic_card.dart';
import '../widgets/search_bar_widget.dart';
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

  List<Mechanic> get _filteredMechanics {
    final allMechanics = MechanicController.instance.mechanics;
    return allMechanics.where((mechanic) {
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

  void _showAddMechanicBottomSheet() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.clay,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: AppColors.dockShadow,
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.mutedLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('+ Add Mechanic', style: AppTextStyles.cardTitle),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.mutedText),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LabeledTextField(
                    label: 'Mechanic / Workshop Name',
                    controller: nameCtrl,
                    placeholder: 'e.g. Peak Moto Prep',
                  ),
                  const SizedBox(height: 12),
                  LabeledTextField(
                    label: 'Phone Number',
                    controller: phoneCtrl,
                    placeholder: '+1 (555) 482-9921',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  LabeledTextField(
                    label: 'Address / Location',
                    controller: addressCtrl,
                    placeholder: 'e.g. 42 Timberline Rd, High Pass',
                  ),
                  const SizedBox(height: 12),
                  LabeledTextField(
                    label: 'Notes / Specialties',
                    controller: notesCtrl,
                    placeholder: 'e.g. Carburetor tuning, valve adjust, tires',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Save Mechanic',
                    icon: Icons.check_rounded,
                    isFullWidth: true,
                    onTap: () {
                      if (nameCtrl.text.trim().isEmpty ||
                          phoneCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Name and phone are required'),
                            backgroundColor: AppColors.alertRed,
                          ),
                        );
                        return;
                      }
                      final newMech = Mechanic(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          distance: 'Local Workshop',
                          durationOrLocation: addressCtrl.text.trim().isNotEmpty
                              ? addressCtrl.text.trim()
                              : 'Added by Rider',
                          badgeType: BadgeType.verified,
                          badgeLabel: 'Verified Shop',
                          beaconStatus: 'Active',
                          beaconColor: AppColors.statusGreen,
                          categoryTitle1: 'SERVICES',
                          tags1: notesCtrl.text.trim().isNotEmpty
                              ? [notesCtrl.text.trim()]
                              : const ['General Moto Repair'],
                          categoryTitle2: 'LOCATION',
                          tags2: addressCtrl.text.trim().isNotEmpty
                              ? [addressCtrl.text.trim()]
                              : const ['Local Area'],
                          rating: 5.0,
                          reviewCount: 1,
                          openStatus: 'OPEN NOW',
                          address: addressCtrl.text.trim(),
                          notes: notesCtrl.text.trim(),
                        );
                        MechanicController.instance.addMechanic(newMech);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Saved ${newMech.name}'),
                            backgroundColor: AppColors.darkCharcoal,
                          ),
                        );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteMechanic(Mechanic mechanic) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.clay,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Mechanic?', style: AppTextStyles.cardTitle),
        content: Text(
          'Are you sure you want to remove ${mechanic.name} from your saved mechanics?',
          style: AppTextStyles.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              MechanicController.instance.deleteMechanic(mechanic.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed ${mechanic.name}'),
                  backgroundColor: AppColors.darkCharcoal,
                ),
              );
            },
            child: Text(
              'Delete',
              style: AppTextStyles.body.copyWith(
                color: AppColors.alertRed,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToMapScreen() async {
    setState(() {
      _currentNavIndex = 2;
    });
    await Navigator.pushNamed(
      context,
      CampRoutes.navigationMap,
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
                        'Location: ${mechanic.durationOrLocation}',
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
              Navigator.pushNamed(context, CampRoutes.navigationMap);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tacticalOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Start Guidance',
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
    return ListenableBuilder(
      listenable: MechanicController.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.clay,
          body: Stack(
            children: [
              Column(
                children: [
                  // Custom AppBar with Recessed Search & Filter
                  CustomAppBar(
                    onBackTap: () => Navigator.pop(context),
                  ),

                  // Tactile Skeuomorphic Search Bar
                  SearchBarWidget(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
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

              // Floating "+ Add Mechanic" Button (FAB bottom: 96, does not overlap bottom dock at bottom: 24)
              if (_currentNavIndex == 3 || _isListView)
                Positioned(
                  right: 16,
                  bottom: 96,
                  child: GestureDetector(
                    onTap: _showAddMechanicBottomSheet,
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
                  child: CampBottomNav(
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
        );
      },
    );
  }

  Widget _buildListView() {
    final mechanics = _filteredMechanics;

    if (mechanics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: CampEmptyState(
            icon: Icons.handyman_rounded,
            message: 'No mechanics found',
            subMessage: _searchQuery.isNotEmpty
                ? 'Try a different search query or clear filters'
                : 'Add trusted mechanics to your offline directory',
            ctaLabel: 'Add Mechanic',
            onCta: _showAddMechanicBottomSheet,
          ),
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
          onDelete: () => _confirmDeleteMechanic(mechanic),
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
