import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/camp_app_bar.dart';
import '../../../../core/widgets/camp_bottom_nav.dart';
import '../../../../core/widgets/labeled_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../controllers/mechanic_controller.dart';
import '../../domain/mechanic_model.dart';

/// Screen for adding or editing a community roadside mechanic / workshop.
/// Follows the tactile CAMP clay design language with recessed inputs,
/// camera/gallery photo picker, and persistent storage.
class AddMechanicScreen extends StatefulWidget {
  const AddMechanicScreen({super.key, this.mechanic});

  final Mechanic? mechanic;

  @override
  State<AddMechanicScreen> createState() => _AddMechanicScreenState();
}

class _AddMechanicScreenState extends State<AddMechanicScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _specialityController;
  late final TextEditingController _notesController;

  String? _photoPath;
  bool _nameError = false;

  bool get _isEditing => widget.mechanic != null;

  @override
  void initState() {
    super.initState();
    final mech = widget.mechanic;
    _nameController = TextEditingController(text: mech?.name ?? '');
    _phoneController = TextEditingController(text: mech?.phone ?? '');
    _addressController = TextEditingController(
      text: mech?.address ?? (mech?.durationOrLocation ?? ''),
    );
    _specialityController = TextEditingController(
      text: mech != null && mech.tags1.isNotEmpty ? mech.tags1.join(', ') : '',
    );
    _notesController = TextEditingController(text: mech?.notes ?? '');
    _photoPath = mech?.photoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specialityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Ensures picked photos outside app storage are copied to the app documents directory
  /// so they survive app restarts and temporary cache purges.
  Future<String> _persistImage(String pickedPath) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final mechanicsDir = Directory('${docsDir.path}/mechanics');
      if (!await mechanicsDir.exists()) {
        await mechanicsDir.create(recursive: true);
      }
      if (pickedPath.startsWith(docsDir.path)) {
        return pickedPath;
      }
      final extension = pickedPath.contains('.') ? pickedPath.split('.').last : 'jpg';
      final fileName = 'mech_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final targetFile = File('${mechanicsDir.path}/$fileName');
      final copied = await File(pickedPath).copy(targetFile.path);
      return copied.path;
    } catch (_) {
      // Gracefully fall back to original picked path if storage copy fails
      return pickedPath;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        final persisted = await _persistImage(picked.path);
        if (mounted) {
          setState(() {
            _photoPath = persisted;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Camera or storage access was not available. Please check device permissions.',
            ),
            backgroundColor: AppColors.darkCharcoal,
          ),
        );
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.clay,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: AppColors.dockShadow,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mutedLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Shop or Signboard Photo',
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.tacticalOrange,
                ),
                title: Text(
                  'Take Photo with Camera',
                  style: AppTextStyles.itemTitle,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.tacticalOrange,
                ),
                title: Text(
                  'Choose from Gallery',
                  style: AppTextStyles.itemTitle,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMechanic() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameError = true;
      });
      return;
    }

    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final speciality = _specialityController.text.trim();
    final notes = _notesController.text.trim();

    final existing = widget.mechanic;
    final id = existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final List<String> tags1;
    if (speciality.isNotEmpty) {
      tags1 = speciality
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else {
      tags1 = existing?.tags1 ?? const ['General Repair'];
    }

    final List<String> tags2;
    if (address.isNotEmpty) {
      tags2 = [address];
    } else {
      tags2 = existing?.tags2 ?? const ['Local Area'];
    }

    final newMech = Mechanic(
      id: id,
      name: name,
      distance: existing?.distance ?? 'Local Workshop',
      durationOrLocation: address.isNotEmpty
          ? address
          : (existing?.durationOrLocation ?? 'Added by Rider'),
      badgeType: existing?.badgeType ?? BadgeType.verified,
      badgeLabel: existing?.badgeLabel ?? 'Verified Shop',
      beaconStatus: existing?.beaconStatus ?? 'Active',
      beaconColor: existing?.beaconColor ?? AppColors.statusGreen,
      categoryTitle1: 'SPECIALTIES',
      tags1: tags1,
      categoryTitle2: 'LOCATION',
      tags2: tags2,
      rating: existing?.rating ?? 5.0,
      reviewCount: existing?.reviewCount ?? 1,
      openStatus: existing?.openStatus ?? 'OPEN NOW',
      phone: phone,
      address: address.isNotEmpty ? address : null,
      notes: notes.isNotEmpty ? notes : null,
      photoPath: _photoPath,
    );

    if (_isEditing) {
      MechanicController.instance.updateMechanic(newMech);
    } else {
      MechanicController.instance.addMechanic(newMech);
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(newMech);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.clay,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                CampAppBar(
                  leading: CampAppBarLeading.back,
                  onLeadingPressed: () => Navigator.of(context).pop(),
                  titleText: _isEditing ? 'Edit Mechanic' : 'Add Mechanic',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    // Reserve space for the floating nav dock below
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header hint
                        Text(
                          'Know a mechanic or emergency pitstop? Add them so you and other riders can find reliable support offline.',
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Shop name (required)
                        LabeledTextField(
                          label: 'Shop / Mechanic Name',
                          controller: _nameController,
                          placeholder: 'e.g. Peak Moto & Adventure Rig Prep',
                          isError: _nameError,
                          errorText: _nameError ? 'Shop name is required' : null,
                          rightLabelWidget: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0DB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'REQUIRED',
                              style: GoogleFonts.manrope(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.tacticalOrangeDark,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          onChanged: (_) {
                            if (_nameError) {
                              setState(() => _nameError = false);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        LabeledTextField(
                          label: 'Phone Number',
                          controller: _phoneController,
                          placeholder: 'e.g. +92 300 1234567',
                          keyboardType: TextInputType.phone,
                          trailingIcon: Icons.phone_outlined,
                        ),
                        const SizedBox(height: 16),

                        // Address
                        LabeledTextField(
                          label: 'Address / Location',
                          controller: _addressController,
                          placeholder: 'e.g. 42 Timberline Rd, Babusar Valley',
                          trailingIcon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 16),

                        // Speciality (optional)
                        LabeledTextField(
                          label: 'Speciality (optional)',
                          controller: _specialityController,
                          placeholder: 'e.g. Engine rebuild, tire plugs, carb jetting',
                          trailingIcon: Icons.build_outlined,
                          helperText: 'Separate multiple skills with commas',
                        ),
                        const SizedBox(height: 16),

                        // Notes (optional)
                        LabeledTextField(
                          label: 'Rider Notes (optional)',
                          controller: _notesController,
                          placeholder: 'e.g. Has 220V arc welder, stocked tubes & spark plugs',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),

                        // Photo Section
                        _buildPhotoSection(),
                        const SizedBox(height: 28),

                        // Save Button
                        PrimaryButton(
                          label: _isEditing ? 'Save Changes' : 'Save Mechanic',
                          icon: Icons.check_rounded,
                          isFullWidth: true,
                          onTap: _saveMechanic,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating Bottom Nav Dock — CampBottomNav hides itself when keyboard is open
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: CampBottomNav(
                  selectedIndex: 3,
                  onIndexChanged: (index) {
                    if (index == 3) {
                      Navigator.of(context).pop();
                    } else {
                      CampBottomNav.navigateToTab(
                        context,
                        index,
                        currentIndex: 3,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    final photo = _photoPath;
    final file = photo != null ? File(photo) : null;
    final hasPhoto = file != null && file.existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Shop or Signboard Photo',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.darkCharcoal,
              ),
            ),
            Text(
              'OPTIONAL',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.mutedLight,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (hasPhoto)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.clay,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.clayDark, width: 1.2),
              boxShadow: AppColors.skeuRaisedSmall,
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    file,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: AppColors.clayDark,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: AppColors.mutedLight,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showImageSourcePicker,
                        icon: const Icon(
                          Icons.photo_camera_rounded,
                          size: 16,
                          color: AppColors.tacticalOrange,
                        ),
                        label: Text(
                          'Replace Photo',
                          style: GoogleFonts.manrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(color: AppColors.clayDark, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: AppColors.clay,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _photoPath = null),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: AppColors.alertRed,
                      ),
                      label: Text(
                        'Remove',
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.alertRed,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        side: BorderSide(
                          color: AppColors.alertRed.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: AppColors.alertRedBg,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: _showImageSourcePicker,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.clayDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.clayDark, width: 1.2),
                boxShadow: AppColors.skeuRecessed,
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.clay,
                      border: Border.all(color: AppColors.clayDark, width: 1),
                      boxShadow: AppColors.skeuRaisedSmall,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.photo_camera_rounded,
                        color: AppColors.tacticalOrange,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Take photo or choose from gallery',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Helps passing riders recognize the roadside workshop or signboard',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
