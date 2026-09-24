import 'package:flutter/material.dart';

import '../../../../core/widgets/camp_bottom_nav.dart';

/// Floating tactical bottom dock — delegates to [CampBottomNav].
/// Maintained as a thin wrapper to preserve existing import paths.
class TacticalBottomDockWidget extends StatefulWidget {
  const TacticalBottomDockWidget({
    super.key,
    this.selectedIndex = 0,
    this.onIndexChanged,
  });

  final int selectedIndex;
  final ValueChanged<int>? onIndexChanged;

  @override
  State<TacticalBottomDockWidget> createState() => _TacticalBottomDockWidgetState();
}

class _TacticalBottomDockWidgetState extends State<TacticalBottomDockWidget> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant TacticalBottomDockWidget old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      _currentIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CampBottomNav(
      selectedIndex: _currentIndex,
      onIndexChanged: (index) {
        setState(() => _currentIndex = index);
        widget.onIndexChanged?.call(index);
      },
    );
  }
}