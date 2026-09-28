import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/auth_controller.dart';
import '../theme/auth_colors.dart';
import '../widgets/auth_background_scaffold.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

/// CAMP Forgot Password Screen
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController(text: 'moto.rider@camp.io');
  bool _isLoading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showNotification(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        backgroundColor: const Color(0xFF26201D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isError ? Colors.redAccent : AuthColors.orangeBadgeBorder,
            width: 1,
          ),
        ),
        duration: const Duration(milliseconds: 2400),
      ),
    );
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showNotification('Please enter your Rider ID or email.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    await AuthController.instance.requestPasswordReset(email);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _submitted = true;
    });

    _showNotification('Telemetry recovery instructions dispatched!');
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackgroundScaffold(
      topBar: AuthBrandHeader.signUp(
        onBack: () => Navigator.of(context).maybePop(),
        onSyncTap: () => _showNotification('Recovery Server: Operational'),
      ),
      bottomBar: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Remember your credentials? ',
              style: GoogleFonts.manrope(
                color: AuthColors.textFooter,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Text(
                'Sign In',
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
      ),
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
                    // Recovery Icon
                    Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AuthColors.orangeBadgeBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AuthColors.orangeBadgeBorder,
                            width: 1.8,
                          ),
                          boxShadow: AuthColors.badgeGlow,
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: AuthColors.orangeLight,
                          size: 30,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Reset Password',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: AuthColors.textWhite,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _submitted
                          ? 'Check your inbox for the telemetry recovery link to securely reset your credentials.'
                          : 'Enter your Rider ID or email to receive telemetry password reset instructions.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: AuthColors.textSubtitle,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (!_submitted) ...[
                      AuthTextField(
                        label: 'Rider ID or Email',
                        controller: _emailController,
                        hintText: 'moto.rider@camp.io',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleReset(),
                      ),

                      const SizedBox(height: 22),

                      AuthPrimaryButton(
                        label: 'Send Recovery Link',
                        isLoading: _isLoading,
                        onTap: _handleReset,
                      ),
                    ] else ...[
                      AuthPrimaryButton(
                        label: 'Return to Sign In',
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
