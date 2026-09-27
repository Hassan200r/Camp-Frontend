import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

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
/// Floating dark pill container with 5 icons and active indicator rendered
/// as a tactical orange skeuomorphic gradient circle.
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
    CampNavItem(icon: Icons.qr_code_scanner_rounded, label: 'Bike Scan'),
    CampNavItem(icon: Icons.navigation_rounded, label: 'Navigation'),
    CampNavItem(icon: Icons.handyman_rounded, label: 'Mechanic'),
    CampNavItem(icon: Icons.tune_rounded, label: 'Settings'),
  ];

  /// Standard tab navigation helper across all screens
  static void navigateToTab(BuildContext context, int targetIndex, {int? currentIndex}) {
    if (currentIndex == targetIndex) return;

    switch (targetIndex) {
      case 0:
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
        break;
      case 1:
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/add-bike',
          (route) => route.settings.name == '/',
        );
        break;
      case 2:
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/mechanics/map',
          (route) => route.settings.name == '/',
        );
        break;
      case 3:
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/mechanics',
          (route) => route.settings.name == '/',
        );
        break;
      case 4:
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/profile',
          (route) => route.settings.name == '/',
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
