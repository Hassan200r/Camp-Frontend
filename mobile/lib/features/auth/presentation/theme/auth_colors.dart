import 'package:flutter/material.dart';

/// Design tokens specifically matched to the CAMP Auth screens
class AuthColors {
  AuthColors._();

  // ── Primary Accents ────────────────────────────────────────────────────────
  static const Color orangePrimary = Color(0xFFFF5A00);
  static const Color orangeLight = Color(0xFFFF6D00);
  static const Color orangeDark = Color(0xFFE54A00);
  static const Color orangeBadgeBg = Color(0xFF381F0E);
  static const Color orangeBadgeBorder = Color(0x99FF5A00);

  // ── Card & Glass Surfaces ──────────────────────────────────────────────────
  static const Color cardBackground = Color(0xE8262220);
  static const Color cardBorder = Color(0x2EFFFFFF);
  static const Color cardBorderHighlight = Color(0x3DFFFFFF);

  // ── Input Fields ───────────────────────────────────────────────────────────
  static const Color inputBackground = Color(0xFF38332F);
  static const Color inputBorder = Color(0x38857C75);
  static const Color inputBorderFocused = Color(0xFFFF5A00);
  static const Color inputIcon = Color(0xFFAAA199);
  static const Color inputText = Color(0xFFFFFFFF);
  static const Color inputHint = Color(0xFF88817B);

  // ── Secondary & Express Button ─────────────────────────────────────────────
  static const Color expressButtonBg = Color(0xFF36312E);
  static const Color expressButtonBorder = Color(0x338A827B);

  // ── Typography Colors ──────────────────────────────────────────────────────
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textLabel = Color(0xFFD4CDC6);
  static const Color textSubtitle = Color(0xFFBBB3AC);
  static const Color textMuted = Color(0xFF8E8883);
  static const Color textFooter = Color(0xFFD0C8C1);

  // ── Indicator Colors ───────────────────────────────────────────────────────
  static const Color statusGreen = Color(0xFF00E676);
  static const Color barActiveOrange = Color(0xFFFF6200);
  static const Color barInactive = Color(0xFF4A4541);
  static const Color pillDarkBg = Color(0x992B2623);
  static const Color pillBorder = Color(0x338A827B);

  // ── Glow & Box Shadows ─────────────────────────────────────────────────────
  static List<BoxShadow> get buttonGlow => const [
        BoxShadow(
          color: Color(0x88FF5A00),
          offset: Offset(0, 6),
          blurRadius: 18,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: Color(0x99000000),
          offset: Offset(0, 16),
          blurRadius: 36,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> get badgeGlow => const [
        BoxShadow(
          color: Color(0x55FF5A00),
          offset: Offset(0, 2),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ];
}
