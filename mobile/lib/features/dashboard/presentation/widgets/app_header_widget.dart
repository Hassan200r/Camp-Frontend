import 'package:flutter/material.dart';

import '../../../../core/widgets/camp_app_bar.dart';

/// Top Navigation Bar — thin wrapper delegating to [CampAppBar].
/// Maintained to preserve existing import paths.
class AppHeaderWidget extends StatelessWidget {
  const AppHeaderWidget({
    super.key,
    this.onMenuPressed,
    this.onBadgePressed,
  });

  final VoidCallback? onMenuPressed;
  final VoidCallback? onBadgePressed;

  @override
  Widget build(BuildContext context) {
    return CampAppBar(
      leading: CampAppBarLeading.menu,
      onLeadingPressed: onMenuPressed,
      actionText: 'EXPLORE HOME',
      onActionPressed: onBadgePressed,
    );
  }
}
