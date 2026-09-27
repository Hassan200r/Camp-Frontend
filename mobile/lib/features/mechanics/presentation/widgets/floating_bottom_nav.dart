import 'package:flutter/material.dart';

import '../../../../core/widgets/camp_bottom_nav.dart';

/// Floating bottom navigation bar for Mechanics feature screens.
/// Delegates directly to [CampBottomNav] to guarantee identical design,
/// theme, colors, size, and behavior across all screens.
class FloatingBottomNavBar extends StatelessWidget {
  const FloatingBottomNavBar({
    required this.currentIndex,
    this.onTabSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int>? onTabSelected;

  @override
  Widget build(BuildContext context) {
    return CampBottomNav(
      selectedIndex: currentIndex,
      onIndexChanged: onTabSelected ??
          (index) => CampBottomNav.navigateToTab(
                context,
                index,
                currentIndex: currentIndex,
              ),
    );
  }
}
