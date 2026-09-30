import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/emergency_sos_controller.dart';
import 'ice_network_sheet.dart';

/// Card 4: Emergency Contact Card with Call, Message, and 911 Dispatch Actions
class EmergencyContactCard extends StatelessWidget {
  const EmergencyContactCard({
    super.key,
    this.onEditPressed,
  });

  final VoidCallback? onEditPressed;

  void _handleCall(BuildContext context, String name, String phone) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.call_rounded, color: Color(0xFF10B981), size: 18),
            const SizedBox(width: 10),
            Text(
              'Calling $name ($phone)...',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  void _handleMessage(BuildContext context, String name, String phone) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF38BDF8), size: 18),
            const SizedBox(width: 10),
            Text(
              'Opening messaging for $name...',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  void _handleCall911(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFECEF),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.emergency_rounded,
                      color: Color(0xFFE53935),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Call Emergency Services',
                  style: GoogleFonts.manrope(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This will immediately dial 911 emergency rescue dispatch services and broadcast your GPS coordinates.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.manrope(
                                color: const Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Dialing 911 Emergency Services...',
                                style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                              backgroundColor: const Color(0xFFDC2626),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Call 911',
                              style: GoogleFonts.manrope(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: EmergencySosController.instance,
      builder: (context, _) {
        final contacts = EmergencySosController.instance.contacts;
        final primaryContact = contacts.isNotEmpty ? contacts.first : null;
        final name = primaryContact?.name ?? 'Sarah Henderson';
        final relation = primaryContact?.relationship ?? 'Spouse / Partner';
        final phone = primaryContact?.phone ?? '+1 (555) 942-8819';
        final initials = primaryContact?.initials ?? 'SH';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Row ─────────────────────────────────────────────────
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF1E293B),
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Emergency Contact',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onEditPressed ?? () => IceNetworkSheet.show(context),
                    child: Text(
                      'Edit >',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFFF6B00),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Contact Details Row ────────────────────────────────────────
              Row(
                children: [
                  // Initials Circle Avatar
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF1E293B),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name, Relation, Phone Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF1E293B),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        relation,
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF1E293B),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Action Buttons: Call & Message ─────────────────────────────
              Row(
                children: [
                  // Call Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _handleCall(context, name, phone),
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.call_rounded,
                              color: Color(0xFF059669),
                              size: 16,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              'Call',
                              style: GoogleFonts.manrope(
                                color: const Color(0xFF1E293B),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Message Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _handleMessage(context, name, phone),
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: Color(0xFF0284C7),
                              size: 16,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              'Message',
                              style: GoogleFonts.manrope(
                                color: const Color(0xFF1E293B),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Call Emergency Services (911) Button ───────────────────────
              GestureDetector(
                onTap: () => _handleCall911(context),
                child: Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFECDD3), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emergency_rounded,
                        color: Color(0xFFE53935),
                        size: 16,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Call Emergency Services (911)',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFE53935),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
