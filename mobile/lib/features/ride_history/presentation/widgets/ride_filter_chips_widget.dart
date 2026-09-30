import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

/// Widget #2 — Horizontally scrollable filter chip row.
/// One chip active at a time; selection state managed locally with setState.
/// Defaults to index 0 ("All Rides 24").
class RideFilterChipsWidget extends StatefulWidget {
  const RideFilterChipsWidget({
    super.key,
    this.initialSelected = 0,
    this.onFilterChanged,
  });

  /// Initially selected chip index. Defaults to 0 ("All Rides 24").
  final int initialSelected;
  final ValueChanged<int>? onFilterChanged;

  @override
  State<RideFilterChipsWidget> createState() => _RideFilterChipsWidgetState();
}

class _RideFilterChipsWidgetState extends State<RideFilterChipsWidget> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    // Default selection is 0 ("All Rides 24"), not "Rally Tracks" (index 2)
    _selected = widget.initialSelected;
  }

  void _select(int index) {
    if (_selected == index) return;
    HapticFeedback.selectionClick();
    setState(() => _selected = index);
    widget.onFilterChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LabelChip(
            label: 'All Rides',
            count: 24,
            isSelected: _selected == 0,
            onTap: () => _select(0),
          ),
          const SizedBox(width: 8),
          _IconChip(
            label: 'Passes',
            icon: Icons.two_wheeler_rounded,
            isSelected: _selected == 1,
            onTap: () => _select(1),
          ),
          const SizedBox(width: 8),
          _IconChip(
            label: 'Rally Tracks',
            icon: Icons.route_rounded,
            isSelected: _selected == 2,
            onTap: () => _select(2),
          ),
          const SizedBox(width: 8),
          // Trailing icon-only chip (explore/compass)
          _CircleIconChip(
            icon: Icons.near_me_rounded,
            isSelected: _selected == 3,
            onTap: () => _select(3),
          ),
        ],
      ),
    );
  }
}

// ── Private chip helpers ────────────────────────────────────────────────────

class _LabelChip extends StatelessWidget {
  const _LabelChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tacticalOrange : AppColors.clay,
          borderRadius: BorderRadius.circular(AppColors.radiusPill),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.clayDark,
            width: 1.2,
          ),
          boxShadow: isSelected ? AppColors.orangeGlow : AppColors.skeuRaisedSmall,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppColors.clayDark,
                borderRadius: BorderRadius.circular(AppColors.radiusPill),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.mutedText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tacticalOrange : AppColors.clay,
          borderRadius: BorderRadius.circular(AppColors.radiusPill),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.clayDark,
            width: 1.2,
          ),
          boxShadow: isSelected ? AppColors.orangeGlow : AppColors.skeuRaisedSmall,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.mutedText,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.darkCharcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconChip extends StatelessWidget {
  const _CircleIconChip({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tacticalOrange : AppColors.clay,
          shape: BoxShape.circle,
          boxShadow: isSelected ? AppColors.orangeGlow : AppColors.skeuRaisedSmall,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 17,
            color: isSelected ? Colors.white : AppColors.mutedText,
          ),
        ),
      ),
    );
  }
}
