import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../controllers/profile_controller.dart';
import '../../domain/user_profile_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CAMP Edit Profile Screen
//  Reached from the "Edit Profile" button on the Profile hero card.
//  No bottom nav bar — this is a sub-screen.
// ─────────────────────────────────────────────────────────────────────────────
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ── Personal Info controllers ─────────────────────────────────────────────
  final _fullNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _homeCityCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  // ── Riding Profile state ──────────────────────────────────────────────────
  int _experienceIndex = 2; // 0=Beginner 1=Intermediate 2=Advanced
  final Set<String> _ridingStyles = {'Touring'};
  int _unitIndex = 0; // 0=Metric 1=Imperial

  // ── Emergency Contact controllers ─────────────────────────────────────────
  final _ecNameCtrl = TextEditingController();
  final _ecRelCtrl = TextEditingController();
  final _ecPhoneCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _medicalNotesCtrl = TextEditingController();
  String _bloodGroup = '';
  String? _avatarPath;

  static const List<String> _bloodGroups = UserProfile.kNormalizedBloodTypes;

  @override
  void initState() {
    super.initState();
    final profile = ProfileController.instance;
    _fullNameCtrl.text = profile.fullName;
    _usernameCtrl.text = profile.username;
    _emailCtrl.text = profile.email;
    _phoneCtrl.text = profile.phone;
    _homeCityCtrl.text = profile.homeCity;
    _dobCtrl.text = profile.dob;
    _experienceIndex = profile.experienceIndex;
    _ridingStyles.clear();
    _ridingStyles.addAll(profile.ridingStyles);
    _unitIndex = profile.unitIndex;
    _ecNameCtrl.text = profile.emergencyContactName;
    _ecRelCtrl.text = profile.emergencyContactRelation;
    _ecPhoneCtrl.text = profile.emergencyContactPhone;
    _allergiesCtrl.text = profile.allergies;
    _medicalNotesCtrl.text = profile.medicalNotes;
    _bloodGroup = UserProfile.normalizeBloodType(profile.bloodGroup);
    _avatarPath = profile.avatarPath;
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _homeCityCtrl.dispose();
    _dobCtrl.dispose();
    _ecNameCtrl.dispose();
    _ecRelCtrl.dispose();
    _ecPhoneCtrl.dispose();
    _allergiesCtrl.dispose();
    _medicalNotesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _avatarPath = picked.path;
        });
        ProfileController.instance.setAvatarPath(picked.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Camera or storage access was not available ($e)',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.darkCharcoal,
          ),
        );
      }
    }
  }

  void _showPhotoOptions() {
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
              Text('Change Profile Photo', style: AppTextStyles.cardTitle),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded,
                    color: AppColors.tacticalOrange),
                title: Text('Take Photo with Camera',
                    style: AppTextStyles.itemTitle),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: AppColors.tacticalOrange),
                title: Text('Choose from Gallery',
                    style: AppTextStyles.itemTitle),
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

  // ── Date picker for Date of Birth ─────────────────────────────────────────
  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1991, 3, 14),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.tacticalOrange),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      setState(() {
        _dobCtrl.text =
            '${months[picked.month - 1]} ${picked.day}, ${picked.year}';
      });
    }
  }

  void _onSave() {
    ProfileController.instance.updateProfile(
      fullName: _fullNameCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      homeCity: _homeCityCtrl.text.trim(),
      dob: _dobCtrl.text.trim(),
      avatarPath: _avatarPath,
      experienceIndex: _experienceIndex,
      ridingStyles: _ridingStyles,
      unitIndex: _unitIndex,
      emergencyContactName: _ecNameCtrl.text.trim(),
      emergencyContactRelation: _ecRelCtrl.text.trim(),
      emergencyContactPhone: _ecPhoneCtrl.text.trim(),
      bloodGroup: _bloodGroup,
      allergies: _allergiesCtrl.text.trim(),
      medicalNotes: _medicalNotesCtrl.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile saved successfully',
          style: GoogleFonts.manrope(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2000),
      ),
    );
    Navigator.of(context).pop();
  }

  void _onDeleteAccount() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusCard)),
        backgroundColor: AppColors.clay,
        title: Text('Delete Account?', style: AppTextStyles.cardTitle),
        content: Text(
          'This action is permanent and cannot be undone. All your ride history, garage, and SOS data will be erased.',
          style: AppTextStyles.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: GoogleFonts.manrope(
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Delete',
                style: GoogleFonts.manrope(
                    color: AppColors.alertRed,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.clay,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── 1. Header ────────────────────────────────────────────────
              _buildHeader(context),

              // ── Scrollable Body ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppColors.screenPadding,
                    20,
                    AppColors.screenPadding,
                    40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── 2. Avatar Section ──────────────────────────────
                      _buildAvatarSection(),

                      const SizedBox(height: AppColors.cardGap),

                      // ── 3. Personal Info Card ──────────────────────────
                      _buildPersonalInfoCard(),

                      const SizedBox(height: AppColors.cardGap),

                      // ── 4. Riding Profile Card ─────────────────────────
                      _buildRidingProfileCard(),

                      const SizedBox(height: AppColors.cardGap),

                      // ── 5. Emergency Contact Card ──────────────────────
                      _buildEmergencyContactCard(),

                      const SizedBox(height: AppColors.cardGap),

                      // ── 6. Security & Auth Card ────────────────────────
                      _buildSecurityCard(),

                      const SizedBox(height: 24),

                      // ── 7. Save Changes Button ─────────────────────────
                      PrimaryButton(
                        label: 'Save Changes',
                        icon: Icons.arrow_forward_rounded,
                        isFullWidth: true,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        onTap: _onSave,
                      ),

                      const SizedBox(height: 24),

                      // ── 8. Delete Account Link ─────────────────────────
                      _buildDeleteAccountLink(),

                      // Bottom safe-area clearance
                      SizedBox(
                          height:
                              MediaQuery.of(context).padding.bottom + 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  1. Header
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return CampAppBar(
      leading: CampAppBarLeading.back,
      titleText: 'Edit Profile',
      actionText: 'Save',
      onActionPressed: _onSave,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  2. Avatar Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAvatarSection() {
    Widget avatarChild;
    if (_avatarPath != null && _avatarPath!.isNotEmpty) {
      final file = File(_avatarPath!);
      if (file.existsSync()) {
        avatarChild = Image.file(
          file,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
        );
      } else {
        avatarChild = Center(
          child: Text(
            _fullNameCtrl.text.isNotEmpty ? _fullNameCtrl.text[0] : 'R',
            style: GoogleFonts.manrope(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.tacticalOrange,
            ),
          ),
        );
      }
    } else {
      avatarChild = const Center(
        child: Icon(
          Icons.person_rounded,
          size: 50,
          color: AppColors.mutedLight,
        ),
      );
    }

    return Column(
      children: [
        // Avatar circle with orange camera badge overlapping bottom-right
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _showPhotoOptions,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.clayDark,
                  boxShadow: AppColors.skeuRaised,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ClipOval(child: avatarChild),
              ),
              // Camera badge
              Positioned(
                bottom: 0,
                right: -2,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.tacticalOrangeLight,
                        AppColors.tacticalOrangeDark
                      ],
                    ),
                    boxShadow: AppColors.orangeGlow,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // "Change Photo" orange link
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _showPhotoOptions,
          child: Text('Change Photo', style: AppTextStyles.orangeLink),
        ),

        const SizedBox(height: 4),

        // Caption
        Text(
          'Recommended 400x400px JPEG or PNG',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  3. Personal Info Card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPersonalInfoCard() {
    return CampCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardSectionHeader(
            icon: Icons.person_outline_rounded,
            title: 'Personal Info',
            pill: const StatusChip(
              label: 'Public & SOS',
              variant: StatusChipVariant.neutral,
            ),
          ),

          const SizedBox(height: 16),

          LabeledTextField(label: 'FULL NAME', controller: _fullNameCtrl),
          const SizedBox(height: 12),
          LabeledTextField(label: 'USERNAME', controller: _usernameCtrl),
          const SizedBox(height: 12),
          LabeledTextField(
            label: 'EMAIL ADDRESS',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),

          // Phone — ERROR state
          LabeledTextField(
            label: 'PHONE NUMBER',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            isError: true,
            errorText: 'Enter a valid phone number',
            errorLabel: 'Requires verification',
            trailingIcon: Icons.warning_rounded,
          ),
          const SizedBox(height: 12),

          LabeledTextField(label: 'HOME CITY', controller: _homeCityCtrl),
          const SizedBox(height: 12),

          // Date of Birth — calendar icon, opens date picker
          LabeledTextField(
            label: 'DATE OF BIRTH',
            controller: _dobCtrl,
            readOnly: true,
            trailingIcon: Icons.calendar_today_rounded,
            trailingIconColor: AppColors.mutedLight,
            onTap: _pickDob,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  4. Riding Profile Card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildRidingProfileCard() {
    return CampCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardSectionHeader(
            icon: Icons.directions_bike_rounded,
            title: 'Riding Profile',
          ),

          const SizedBox(height: 16),

          // Riding Experience
          Text('RIDING EXPERIENCE', style: AppTextStyles.overline),
          const SizedBox(height: 8),
          SegmentedControl(
            options: const ['Beginner', 'Intermediate', 'Advanced'],
            selectedIndex: _experienceIndex,
            onChanged: (i) => setState(() => _experienceIndex = i),
          ),

          const SizedBox(height: 16),

          // Riding Style (Multi-Select)
          Text('RIDING STYLE (MULTI-SELECT)', style: AppTextStyles.overline),
          const SizedBox(height: 8),
          MultiSelectChipRow(
            options: const ['Commuter', 'Touring', 'Off-road', 'Sport'],
            selected: _ridingStyles,
            onToggle: (s) => setState(() {
              if (_ridingStyles.contains(s)) {
                _ridingStyles.remove(s);
              } else {
                _ridingStyles.add(s);
              }
            }),
          ),

          const SizedBox(height: 16),

          // Preferred Units
          Text('PREFERRED UNITS', style: AppTextStyles.overline),
          const SizedBox(height: 8),
          SegmentedControl(
            options: const ['Metric (km, \u00b0C)', 'Imperial (mi, \u00b0F)'],
            selectedIndex: _unitIndex,
            onChanged: (i) => setState(() => _unitIndex = i),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  5. Emergency Contact Card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEmergencyContactCard() {
    return CampCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardSectionHeader(
            icon: Icons.add_rounded,
            iconColor: AppColors.tacticalOrangeDark,
            title: 'Emergency Contact',
            pill: const StatusChip(
              label: 'SOS Ready',
              variant: StatusChipVariant.danger,
            ),
          ),

          const SizedBox(height: 16),

          LabeledTextField(
              label: 'PRIMARY CONTACT NAME', controller: _ecNameCtrl),
          const SizedBox(height: 12),
          LabeledTextField(label: 'RELATIONSHIP', controller: _ecRelCtrl),
          const SizedBox(height: 12),
          LabeledTextField(
            label: 'CONTACT PHONE',
            controller: _ecPhoneCtrl,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),

          // Blood Group dropdown
          LabeledDropdown<String>(
            label: 'RIDER BLOOD GROUP',
            value: _bloodGroups.contains(_bloodGroup) ? _bloodGroup : _bloodGroups.last,
            items: _bloodGroups,
            onChanged: (v) {
              if (v != null) {
                setState(() => _bloodGroup = v);
              }
            },
          ),
          const SizedBox(height: 12),

          LabeledTextField(
            label: 'KNOWN ALLERGIES',
            controller: _allergiesCtrl,
            maxLength: 100,
            placeholder: 'e.g. Penicillin, Peanuts (optional)',
          ),
          const SizedBox(height: 12),

          LabeledTextField(
            label: 'MEDICAL NOTES',
            controller: _medicalNotesCtrl,
            maxLength: 120,
            maxLines: 2,
            placeholder: 'e.g. Asthma, Diabetic, Past surgeries (optional)',
          ),

          const SizedBox(height: 16),

          // Info banner
          _buildInfoBanner(
            'Shown on your Emergency SOS Medical ID card and accessible by first responders.',
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  6. Security & Authentication Card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSecurityCard() {
    return CampCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardSectionHeader(
            icon: Icons.lock_outline_rounded,
            title: 'Security & Authentication',
          ),
          const SizedBox(height: 8),

          // Change Password row — mirrors _buildSettingsRow in ProfileScreen
          _SettingsRow(
            icon: Icons.vpn_key_outlined,
            title: 'Change Password',
            subtitle: 'Last updated 3 months ago',
            onTap: () {},
          ),

          const Divider(height: 1, color: Color(0x12000000)),

          // Linked Accounts row with Google "G"
          _SettingsRow(
            customLeading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.clayDark,
                borderRadius:
                    BorderRadius.circular(AppColors.radiusTile),
                boxShadow: AppColors.skeuRecessed,
              ),
              child: Center(
                child: Text(
                  'G',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4285F4),
                  ),
                ),
              ),
            ),
            title: 'Linked Accounts',
            subtitle: 'Connected as ${_emailCtrl.text.isNotEmpty ? _emailCtrl.text : "rider@camp.io"}',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  8. Delete Account Link
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDeleteAccountLink() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onDeleteAccount,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.delete_outline_rounded,
              size: 16, color: AppColors.alertRed),
          const SizedBox(width: 6),
          Text(
            'Delete CAMP Account',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.alertRed,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Shared: Card section header
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCardSectionHeader({
    required IconData icon,
    required String title,
    Color? iconColor,
    Widget? pill,
  }) {
    return Row(
      children: [
        IconTile(
          icon: icon,
          size: 36,
          iconSize: 18,
          iconColor: iconColor ?? AppColors.darkCharcoal,
          isInset: true,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: AppTextStyles.cardTitle)),
        ?pill,
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Shared: Info banner
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildInfoBanner(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.clayDark,
        borderRadius: BorderRadius.circular(AppColors.radiusTile),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.45), width: 1),
        boxShadow: AppColors.skeuRecessed,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 16, color: AppColors.tacticalOrangeDark),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.caption)),
        ],
      ),
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
//  _SettingsRow
//  Mirrors _buildSettingsRow() from ProfileScreen exactly, extracted as a
//  standalone private widget for inline use inside a Card.
//  The pattern is REUSED (not new) — same icon, title, subtitle, chevron
//  layout as ProfileScreen._buildSettingsRow.
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.onTap,
    this.icon,
    this.customLeading,
    this.subtitle,
  });

  final String title;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? customLeading;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            customLeading ??
                IconTile(
                  icon: icon ?? Icons.settings_outlined,
                  size: 36,
                  iconSize: 18,
                  iconColor: AppColors.darkCharcoal,
                ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.mutedLight, size: 20),
          ],
        ),
      ),
    );
  }
}
