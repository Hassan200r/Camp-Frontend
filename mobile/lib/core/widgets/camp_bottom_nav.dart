import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../utils/keyboard_visibility.dart';
import 'camp_tab.dart';

export 'camp_tab.dart';

/// Navigation item definition for [CampBottomNav]
class CampNavItem {
  const CampNavItem({
    required this.tab,
    required this.icon,
    required this.label,
  });

  final CampTab tab;
  final IconData icon;
  final String label;
}

/// CAMP Bottom Navigation Dock
/// Floating dark pill container with 6 distinct icons and active indicator rendered
/// as a tactical orange skeuomorphic gradient circle.
/// Automatically hides when keyboard is visible (via [KeyboardVisibilityBuilder]).
class CampBottomNav extends StatelessWidget {
  const CampBottomNav({
    this.selected,
    this.onTabChanged,
    super.key,
    this.items = defaultItems,
  });

  final CampTab? selected;
  final ValueChanged<CampTab>? onTabChanged;
  final List<CampNavItem> items;

  static const List<CampNavItem> defaultItems = [
    CampNavItem(tab: CampTab.home, icon: Icons.explore_rounded, label: 'Explore Home'),
    CampNavItem(tab: CampTab.garage, icon: Icons.two_wheeler_rounded, label: 'Garage & Bikes'),
    CampNavItem(tab: CampTab.navigation, icon: Icons.navigation_rounded, label: 'Navigation'),
    CampNavItem(tab: CampTab.mechanics, icon: Icons.handyman_rounded, label: 'Mechanic'),
    CampNavItem(tab: CampTab.finances, icon: Icons.account_balance_wallet_rounded, label: 'Finances & Rig Health'),
    CampNavItem(tab: CampTab.profile, icon: Icons.person_rounded, label: 'Profile'),
  ];

  /// Standard tab navigation helper across all screens
  static void navigateToTab(
    BuildContext context,
    CampTab targetTab, {
    CampTab? currentTab,
  }) {
    final currentRouteName = ModalRoute.of(context)?.settings.name;

    // Tapping the highlighted tab while on its root screen does nothing
    if (currentRouteName == targetTab.rootRoute) {
      return;
    }

    // Tapping a tab from a sub-screen or another tab navigates to that tab's root
    // without stacking duplicates, keeping Home as the base.
    if (targetTab == CampTab.home) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        CampRoutes.home,
        (route) => false,
      );
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      targetTab.rootRoute,
      (route) => route.isFirst || route.settings.name == CampRoutes.home,
    );
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
          final isActive = item.tab == selected;

          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
            child: Tooltip(
              message: item.label,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (onTabChanged != null) {
                    onTabChanged!(item.tab);
                  } else {
                    navigateToTab(context, item.tab, currentTab: selected);
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
