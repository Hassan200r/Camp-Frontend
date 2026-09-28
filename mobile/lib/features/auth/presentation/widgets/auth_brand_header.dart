import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/auth_colors.dart';

/// Top branding header for CAMP Auth screens
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader.signIn({
    super.key,
    this.onCompassTap,
  })  : isSignUp = false,
        onBack = null,
        onSyncTap = null;

  const AuthBrandHeader.signUp({
    super.key,
    this.onBack,
    this.onSyncTap,
  })  : isSignUp = true,
        onCompassTap = null;

  final bool isSignUp;
  final VoidCallback? onCompassTap;
  final VoidCallback? onBack;
  final VoidCallback? onSyncTap;

  @override
  Widget build(BuildContext context) {
    if (isSignUp) {
      return _buildSignUpHeader(context);
    }
    return _buildSignInHeader(context);
  }

  /// Sign In Header: Compass Button (left), White CAMP badge + CAMP text (center), Pill below
  Widget _buildSignInHeader(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        // Row with Reticle button and Center Logo
        Stack(
          alignment: Alignment.center,
          children: [
            // Left Reticle / Compass button
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: GestureDetector(
                  onTap: onCompassTap,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AuthColors.pillDarkBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AuthColors.pillBorder,
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.explore_outlined,
                            color: Color(0xFFD4CDC6),
                            size: 21,
                          ),
                        ),
                      ),
                      // Little orange indicator dot
                      Positioned(
                        top: -1,
                        right: -1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AuthColors.orangePrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Center: White Logo Badge + "CAMP" text
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // White rounded square badge with animal emblem and CAMP
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.pets_rounded,
                        color: Color(0xFFD95200),
                        size: 16,
                      ),
                      Text(
                        'CAMP',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF14171A),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'CAMP',
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(left: 3, top: 12),
                  decoration: const BoxDecoration(
                    color: AuthColors.orangePrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Underneath Pill: ((•)) TELEMETRY • ADVENTURE
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6.5),
          decoration: BoxDecoration(
            color: AuthColors.pillDarkBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AuthColors.pillBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sensors_rounded,
                color: Color(0xFFD4CDC6),
                size: 15,
              ),
              const SizedBox(width: 7),
              Text(
                'TELEMETRY • ADVENTURE',
                style: GoogleFonts.manrope(
                  color: const Color(0xFFE2DDD7),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Sign Up Header: Back Button (left), CAMP • (center), 🛜 SYNC pill (right)
  Widget _buildSignUpHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Back button
          GestureDetector(
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AuthColors.pillDarkBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AuthColors.pillBorder,
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // Center: CAMP •
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CAMP',
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(left: 4, top: 4),
                decoration: const BoxDecoration(
                  color: AuthColors.orangePrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          // Right: 🛜 SYNC pill
          GestureDetector(
            onTap: onSyncTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AuthColors.pillDarkBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AuthColors.pillBorder,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wifi_tethering_rounded,
                    color: AuthColors.orangeLight,
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'SYNC',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFFE2DDD7),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
