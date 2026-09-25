import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

/// Labeled recessed input field. Handles normal, error, and read-only states.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    required this.label,
    required this.controller,
    super.key,
    this.keyboardType,
    this.isError = false,
    this.errorText,
    this.errorLabel,
    this.trailingIcon,
    this.trailingIconColor,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool isError;
  final String? errorText;
  final String? errorLabel;
  final IconData? trailingIcon;
  final Color? trailingIconColor;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isError
        ? AppColors.alertRed
        : Colors.white.withValues(alpha: 0.45);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row: overline + optional error badge
        Row(
          children: [
            Text(label, style: AppTextStyles.overline),
            if (isError && errorLabel != null) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.alertRedBg,
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                ),
                child: Text(
                  errorLabel!,
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.alertRed,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),

        // Recessed input container
        Container(
          decoration: BoxDecoration(
            color: isError ? AppColors.alertRedBg : AppColors.clayDark,
            borderRadius: BorderRadius.circular(AppColors.radiusTile),
            border: Border.all(
              color: borderColor,
              width: isError ? 1.5 : 1,
            ),
            boxShadow: AppColors.skeuRecessed,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  readOnly: readOnly,
                  onTap: onTap,
                  style: AppTextStyles.body,
                  cursorColor: AppColors.tacticalOrange,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    trailingIcon,
                    size: 18,
                    color: isError
                        ? AppColors.alertRed
                        : (trailingIconColor ?? AppColors.mutedLight),
                  ),
                ),
            ],
          ),
        ),

        // Error helper text
        if (isError && errorText != null) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 12,
                color: AppColors.alertRed,
              ),
              const SizedBox(width: 4),
              Text(
                errorText!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.alertRed,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
