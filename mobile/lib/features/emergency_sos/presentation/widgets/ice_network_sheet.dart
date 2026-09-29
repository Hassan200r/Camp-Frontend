import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../controllers/emergency_sos_controller.dart';
import '../../domain/sos_telemetry_model.dart';

/// Modal bottom sheet for managing In Case of Emergency (ICE) rescue network contacts
class IceNetworkSheet extends StatefulWidget {
  const IceNetworkSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const IceNetworkSheet(),
    );
  }

  @override
  State<IceNetworkSheet> createState() => _IceNetworkSheetState();
}

class _IceNetworkSheetState extends State<IceNetworkSheet> {
  final _nameController = TextEditingController();
  final _relationController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isAddingNew = false;
  String _dispatchMode = 'SMS + Sat';

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleAddContact() {
    final name = _nameController.text.trim();
    final relation = _relationController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) return;

    final parts = name.split(' ');
    final initials = parts.length > 1
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();

    final newContact = IceContact(
      id: 'ice-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      relationship: relation.isEmpty ? 'Contact' : relation,
      phone: phone,
      dispatchBadge: _dispatchMode,
      initials: initials,
      isVhf: _dispatchMode.contains('VHF'),
    );

    EmergencySosController.instance.addContact(newContact);

    setState(() {
      _isAddingNew = false;
      _nameController.clear();
      _relationController.clear();
      _phoneController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
      child: ListenableBuilder(
        listenable: EmergencySosController.instance,
        builder: (context, _) {
          final contacts = EmergencySosController.instance.contacts;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assigned ICE Rescue Network',
                    style: GoogleFonts.manrope(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'These trusted contacts & authorities receive encrypted telemetry and GPS coordinates immediately upon beacon transmission.',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 14),

              // Existing contacts list
              for (final contact in contacts)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: contact.isVhf
                            ? const Color(0xFFFFCDD2)
                            : const Color(0xFFFEF3C7),
                        child: Text(
                          contact.initials,
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${contact.name} (${contact.relationship})',
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: AppColors.darkCharcoal,
                              ),
                            ),
                            Text(
                              contact.phone,
                              style: GoogleFonts.manrope(
                                color: const Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 19, color: Color(0xFF94A3B8)),
                        onPressed: contacts.length > 1
                            ? () => EmergencySosController.instance.removeContact(contact.id)
                            : null,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),

              if (!_isAddingNew)
                GestureDetector(
                  onTap: () => setState(() => _isAddingNew = true),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.tacticalOrange, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '+ Add New Emergency Contact',
                        style: GoogleFonts.manrope(
                          color: AppColors.tacticalOrange,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Contact Full Name',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _relationController,
                        decoration: const InputDecoration(
                          hintText: 'Relationship (e.g. Brother, Medic)',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Phone / Radio Channel',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('SMS + Sat'),
                            selected: _dispatchMode == 'SMS + Sat',
                            onSelected: (val) => setState(() => _dispatchMode = 'SMS + Sat'),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Direct VHF/Sat'),
                            selected: _dispatchMode == 'Direct VHF/Sat',
                            onSelected: (val) => setState(() => _dispatchMode = 'Direct VHF/Sat'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => _isAddingNew = false),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tacticalOrange,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _handleAddContact,
                              child: const Text('Save Contact'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
