import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/auth_colors.dart';

/// Password Strength Indicator matching the screenshot: "Strength 🟧🟧🟧⬛"
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    this.strength = 3,
  });

  /// 0 = None, 1 = Weak, 2 = Fair, 3 = Good (default in mockup), 4 = Strong
  final int strength;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Strength',
          style: GoogleFonts.manrope(
            color: AuthColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(width: 6),
        ...List.generate(4, (index) {
          final isActive = index < strength;
          return Container(
            width: 13,
            height: 4.5,
            margin: const EdgeInsets.only(left: 3),
            decoration: BoxDecoration(
              color: isActive ? AuthColors.barActiveOrange : AuthColors.barInactive,
              borderRadius: BorderRadius.circular(2.5),
            ),
          );
        }),
      ],
    );
  }
}
