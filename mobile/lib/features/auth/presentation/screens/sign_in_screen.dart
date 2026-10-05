import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/auth_controller.dart';
import '../theme/auth_colors.dart';
import '../widgets/auth_background_scaffold.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_express_button.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

/// CAMP Sign In / Welcome Back Screen
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController(text: 'moto.rider@camp.io');
  final _passwordController = TextEditingController(text: 'Adventure#2026');
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isBiometricLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showNotification(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: isError ? Colors.redAccent : AuthColors.orangeLight,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF26201D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isError ? Colors.redAccent.withValues(alpha: 0.5) : AuthColors.orangeBadgeBorder,
            width: 1,
          ),
        ),
        duration: const Duration(milliseconds: 2200),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await AuthController.instance.signIn(
      riderIdOrEmail: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _showNotification('Telemetry verified. Welcome back, Rider!');
      Navigator.of(context).pushReplacementNamed('/');
    } else {
      setState(() {
        _errorMessage = AuthController.instance.state.errorMessage ?? 'Sign in failed';
      });
      _showNotification(_errorMessage!, isError: true);
    }
  }

  Future<void> _handleBiometricTap() async {
    setState(() => _isBiometricLoading = true);

    _showNotification('Scanning Bluetooth Helmet Token & Biometrics...');

    final success = await AuthController.instance.signInWithBiometric();

    if (!mounted) return;
    setState(() => _isBiometricLoading = false);

    if (success) {
      _showNotification('Helmet Token Linked: SCHUBERTH C5 (Active)');
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackgroundScaffold(
      topBar: AuthBrandHeader.signIn(
        onCompassTap: () => _showNotification('GPS Telemetry Beacon: Calibrated'),
      ),
      bottomBar: _buildFooter(context),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Card Header: Title & Subtitle ────────────────────────
                    Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: AuthColors.textWhite,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to access your telemetry & routes',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: AuthColors.textSubtitle,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Field 1: Rider ID or Email ───────────────────────────
                    AuthTextField(
                      label: 'Rider ID or Email',
                      controller: _emailController,
                      hintText: 'moto.rider@camp.io',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      errorText: _errorMessage,
                    ),

                    const SizedBox(height: 16),

                    // ── Field 2: Password ────────────────────────────────────
                    AuthTextField(
                      label: 'Password',
                      controller: _passwordController,
                      hintText: '••••••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleSignIn(),
                      trailingWidget: GestureDetector(
                        onTap: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        child: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AuthColors.inputIcon,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Forgot Password Link ─────────────────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/forgot-password'),
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.manrope(
                            color: AuthColors.textLabel,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Sign In CTA Button ───────────────────────────────────
                    AuthPrimaryButton(
                      label: 'Sign In',
                      isLoading: _isLoading,
                      onTap: _handleSignIn,
                    ),

                    const SizedBox(height: 20),

                    // ── Express Tap Divider ──────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'OR EXPRESS TAP',
                            style: GoogleFonts.manrope(
                              color: AuthColors.textMuted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ── Biometric / Helmet Token Button ──────────────────────
                    AuthExpressButton(
                      isLoading: _isBiometricLoading,
                      onTap: _handleBiometricTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom Footer: "Don't have an account? Sign Up" + Status Bar
  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row: Don't have an account? Sign Up
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: GoogleFonts.manrope(
                  color: AuthColors.textFooter,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/sign-up'),
                child: Text(
                  'Sign Up',
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                    decorationColor: AuthColors.orangeLight,
                    decorationThickness: 2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
