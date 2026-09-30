import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/emergency_sos_controller.dart';

/// Card 6 / Bottom Action: "Test Alert" container matching the design
class EmergencyBottomActions extends StatefulWidget {
  const EmergencyBottomActions({
    super.key,
    this.onSatTestComplete,
  });

  final ValueChanged<String>? onSatTestComplete;

  @override
  State<EmergencyBottomActions> createState() => _EmergencyBottomActionsState();
}

class _EmergencyBottomActionsState extends State<EmergencyBottomActions> {
  bool _isSending = false;

  Future<void> _handleTestAlert() async {
    if (_isSending) return;

    setState(() => _isSending = true);

    final contacts = EmergencySosController.instance.contacts;
    final primaryName = contacts.isNotEmpty ? contacts.first.name : 'Sarah';
    final firstName = primaryName.split(' ').first;

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Sending silent test alert to $firstName...',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1200),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => _isSending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Test alert sent to $firstName without broadcasting GPS coordinates.',
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2500),
      ),
    );

    widget.onSatTestComplete?.call('SUCCESS');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: EmergencySosController.instance,
      builder: (context, _) {
        final contacts = EmergencySosController.instance.contacts;
        final primaryName = contacts.isNotEmpty ? contacts.first.name : 'Sarah';
        final firstName = primaryName.split(' ').first;

        return GestureDetector(
          onTap: () => _handleTestAlert(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.near_me_outlined,
                      color: Color(0xFF1E293B),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Test Alert',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFF1E293B),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Send a test notification to $firstName without broadcasting GPS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF64748B),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
