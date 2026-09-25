import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';
import 'inset_tile.dart';

/// Segmented control with orange-filled selected segment and muted unselected segments.
class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return InsetTile(
      padding: const EdgeInsets.all(4),
      borderRadius: AppColors.radiusTile,
      child: Row(
        children: List.generate(options.length, (i) {
          final isSelected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.tacticalOrangeLight,
                            AppColors.tacticalOrange,
                            AppColors.tacticalOrangeDark,
                          ],
                        )
                      : null,
                  borderRadius:
                      BorderRadius.circular(AppColors.radiusTile - 4),
                  boxShadow: isSelected ? AppColors.orangeGlow : null,
                ),
                child: Center(
                  child: Text(
                    options[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : AppColors.mutedText,
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
