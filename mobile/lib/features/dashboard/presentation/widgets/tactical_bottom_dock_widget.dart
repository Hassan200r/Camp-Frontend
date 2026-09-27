import 'package:flutter/material.dart';

import '../../../../core/widgets/camp_bottom_nav.dart';

/// Floating tactical bottom dock — delegates to [CampBottomNav].
/// Maintained as a thin wrapper to preserve existing import paths.
class TacticalBottomDockWidget extends StatelessWidget {
  const TacticalBottomDockWidget({
    super.key,
    this.selectedIndex = 0,
    this.onIndexChanged,
  });

  final int selectedIndex;
  final ValueChanged<int>? onIndexChanged;

  @override
  Widget build(BuildContext context) {
    return CampBottomNav(
      selectedIndex: selectedIndex,
      onIndexChanged: onIndexChanged ??
          (index) => CampBottomNav.navigateToTab(
                context,
                index,
                currentIndex: selectedIndex,
              ),
    );
  }
}