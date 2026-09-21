import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/skeuomorphic_container.dart';
import 'app_header_widget.dart';

/// Floating tactical bottom dock — dark raised pill with dashed inactive buttons
class TacticalBottomDockWidget extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int>? onIndexChanged;

  const TacticalBottomDockWidget({
    super.key,
    this.selectedIndex = 0,
    this.onIndexChanged,
  });

  @override
  State<TacticalBottomDockWidget> createState() =>
      _TacticalBottomDockWidgetState();
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.dockBackground,
        borderRadius: BorderRadius.circular(40),
        boxShadow: AppColors.dockShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(0, Icons.explore_rounded, 'Explore Home'),
          const SizedBox(width: 8),
          _button(1, Icons.qr_code_scanner_rounded, 'Bike Scan'),
          const SizedBox(width: 8),
          _button(2, Icons.navigation_rounded, 'Navigation'),
          const SizedBox(width: 8),
          _button(3, Icons.build_rounded, 'Maintenance'),
          const SizedBox(width: 8),
          _button(4, Icons.tune_rounded, 'Settings'),
        ],
      ),
    );
  }

  Widget _button(int index, IconData icon, String tooltip) {
    final bool active = _currentIndex == index;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          setState(() => _currentIndex = index);
          widget.onIndexChanged?.call(index);
        },
        behavior: HitTestBehavior.opaque,
        child: active
            ? SkeuomorphicOrangeIconButton(icon: icon, size: 48)
            : SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Icon(
                    icon,
                    color: const Color(0xFF9CA3AF), // Muted grey icon
                    size: 21,
                  ),
                ),
              ),
      ),
    );
}
}