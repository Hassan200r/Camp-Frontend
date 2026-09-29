import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/auth_colors.dart';

/// Recessed dark input field with icon and custom label row
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    required this.label,
    required this.controller,
    super.key,
    this.hintText,
    this.prefixIcon,
    this.trailingWidget,
    this.labelTrailing,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.onChanged,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? trailingWidget;
  final Widget? labelTrailing;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label Row ────────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: GoogleFonts.manrope(
                color: AuthColors.textLabel,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
            if (widget.labelTrailing != null) widget.labelTrailing!,
          ],
        ),
        const SizedBox(height: 8),

        // ── Input Box Container ──────────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 52,
          decoration: BoxDecoration(
            color: AuthColors.inputBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFDC2626)
                  : (_isFocused ? AuthColors.inputBorderFocused : AuthColors.inputBorder),
              width: _isFocused || hasError ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null) ...[
                const SizedBox(width: 14),
                Icon(
                  widget.prefixIcon,
                  color: _isFocused ? AuthColors.orangeLight : AuthColors.inputIcon,
                  size: 20,
                ),
                const SizedBox(width: 10),
              ] else
                const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  onChanged: widget.onChanged,
                  cursorColor: AuthColors.orangePrimary,
                  style: GoogleFonts.manrope(
                    color: AuthColors.inputText,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: widget.obscureText ? 2.0 : 0.2,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: GoogleFonts.manrope(
                      color: AuthColors.inputHint,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (widget.trailingWidget != null) ...[
                widget.trailingWidget!,
                const SizedBox(width: 6),
              ] else
                const SizedBox(width: 12),
            ],
          ),
        ),

        // Error message if any
        if (hasError) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              widget.errorText!,
              style: GoogleFonts.manrope(
                color: const Color(0xFFEF4444),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
