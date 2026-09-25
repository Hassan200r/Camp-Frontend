import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';

/// Wrapping chip row for multi-selection.
/// Selected chips show an orange outline, fill tint, and checkmark icon.
class MultiSelectChipRow extends StatelessWidget {
  const MultiSelectChipRow({
    required this.options,
    required this.selected,
    required this.onToggle,
    super.key,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onToggle(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.tacticalOrange.withValues(alpha: 0.12)
                  : AppColors.clayDark,
              borderRadius:
                  BorderRadius.circular(AppColors.radiusTile),
              border: Border.all(
                color: isSelected
                    ? AppColors.tacticalOrange
                    : AppColors.mutedLight.withValues(alpha: 0.5),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow:
                  isSelected ? null : AppColors.skeuRaisedSmall,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check_rounded,
                      size: 13,
                      color: AppColors.tacticalOrangeDark),
                  const SizedBox(width: 5),
                ],
                Text(
                  opt,
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.tacticalOrangeDark
                        : AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
