import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../utils/keyboard_visibility.dart';

/// Navigation item definition for [CampBottomNav]
class CampNavItem {
  const CampNavItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

/// CAMP Bottom Navigation Dock
/// Floating dark pill container with 6 distinct icons and active indicator rendered
/// as a tactical orange skeuomorphic gradient circle.
/// Automatically hides when keyboard is visible (via [KeyboardVisibilityBuilder]).
class CampBottomNav extends StatelessWidget {
  const CampBottomNav({
    required this.selectedIndex,
    this.onIndexChanged,
    super.key,
    this.items = defaultItems,
  });

  final int selectedIndex;
  final ValueChanged<int>? onIndexChanged;
  final List<CampNavItem> items;

  static const List<CampNavItem> defaultItems = [
    CampNavItem(icon: Icons.explore_rounded, label: 'Explore Home'),
    CampNavItem(icon: Icons.two_wheeler_rounded, label: 'Bike Scan'),
    CampNavItem(icon: Icons.navigation_rounded, label: 'Navigation'),
    CampNavItem(icon: Icons.handyman_rounded, label: 'Mechanic'),
    CampNavItem(icon: Icons.account_balance_wallet_rounded, label: 'Finances & Rig Health'),
    CampNavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  /// Standard tab navigation helper across all screens
  static void navigateToTab(BuildContext context, int targetIndex, {int? currentIndex}) {
    if (currentIndex == targetIndex) return;

    switch (targetIndex) {
      case 0:
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(CampRoutes.home, (route) => false);
        }
        break;
      case 1:
        Navigator.of(context).pushNamedAndRemoveUntil(
          CampRoutes.addBike,
          (route) => route.settings.name == CampRoutes.home,
        );
        break;
      case 2:
        Navigator.of(context).pushNamedAndRemoveUntil(
          CampRoutes.navigationMap,
          (route) => route.settings.name == CampRoutes.home,
        );
        break;
      case 3:
        Navigator.of(context).pushNamedAndRemoveUntil(
          CampRoutes.mechanics,
          (route) => route.settings.name == CampRoutes.home,
        );
        break;
      case 4:
        Navigator.of(context).pushNamedAndRemoveUntil(
          CampRoutes.financeRigHealth,
          (route) => route.settings.name == CampRoutes.home,
        );
        break;
      case 5:
        Navigator.of(context).pushNamedAndRemoveUntil(
          CampRoutes.profile,
          (route) => route.settings.name == CampRoutes.home,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          reverseDuration: const Duration(milliseconds: 150),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1.2),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: isKeyboardVisible
              ? const SizedBox.shrink(key: ValueKey('camp_bottom_nav_hidden'))
              : _buildNavContent(context),
        );
      },
    );
  }

  Widget _buildNavContent(BuildContext context) {
    return Container(
      key: const ValueKey('camp_bottom_nav_visible'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.dockBackground,
        borderRadius: BorderRadius.circular(AppColors.radiusPill),
        boxShadow: AppColors.dockShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = index == selectedIndex;

          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
            child: Tooltip(
              message: item.label,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (onIndexChanged != null) {
                    onIndexChanged!(index);
                  } else {
                    navigateToTab(context, index, currentIndex: selectedIndex);
                  }
                },
                child: isActive
                    ? Container(
                        width: 48,
                        height: 48,
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
                        child: Center(
                          child: Icon(
                            item.icon,
                            color: Colors.white,
                            size: 21,
                          ),
                        ),
                      )
                    : SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: Icon(
                            item.icon,
                            color: AppColors.mutedLight,
                            size: 21,
                          ),
                        ),
                      ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
