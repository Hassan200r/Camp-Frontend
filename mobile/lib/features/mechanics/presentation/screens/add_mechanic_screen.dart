import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/camp_bottom_nav.dart';
import '../../../dashboard/presentation/widgets/tactical_bottom_dock_widget.dart';
import '../../domain/mechanic_model.dart';

class AddMechanicScreen extends StatefulWidget {
  const AddMechanicScreen({super.key});

  @override
  State<AddMechanicScreen> createState() => _AddMechanicScreenState();
}

class _AddMechanicScreenState extends State<AddMechanicScreen> {
  static const LinearGradient _orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.tacticalOrangeLight, AppColors.tacticalOrange],
  );

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _gpsCoordinates = '35.1824° N,\n74.0291° E';
  String? _uploadedPhotoName;

  // Selected Brand Chips (Pre-selected matching the provided screenshot)
  final Set<String> _selectedBrands = {
    'Honda',
    'Suzuki',
    'Yamaha',
    'Royal Enfield',
  };

  final List<String> _allBrands = [
    'Honda',
    'Suzuki',
    'Yamaha',
    'Kawasaki',
    'Royal Enfield',
    'BMW Motorrad',
    'Other / Chinese Trikes',
  ];

  // Selected Specialty Chips (Pre-selected matching the provided screenshot)
  final Set<String> _selectedSpecialties = {
    'Engine',
    'Tires & Tube Vulcanizing',
    'Carb Jetting',
  };

  final List<String> _allSpecialties = [
    'Engine',
    'Tires & Tube Vulcanizing',
    'Carb Jetting',
    'Suspension',
    'Electrical & Stator',
    'General Field Repair',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onGpsTap() {
    setState(() {
      _gpsCoordinates = '35.1824° N,\n74.0291° E';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('GPS Coordinates Locked (35.1824° N, 74.0291° E)'),
          ],
        ),
        backgroundColor: AppColors.tacticalOrange,
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  void _onPhotoTap() {
    setState(() {
      _uploadedPhotoName = _uploadedPhotoName == null
          ? 'signboard_workshop_babusar.jpg'
          : null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _uploadedPhotoName != null
              ? 'Signboard photo attached successfully!'
              : 'Photo removed.',
        ),
        backgroundColor: _uploadedPhotoName != null
            ? AppColors.statusGreen
            : AppColors.mutedText,
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  void _submitMechanic() {
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Babusar Valley Moto Spares & Welding';

    final manualLocation = _locationController.text.trim().isNotEmpty
        ? _locationController.text.trim()
        : 'Babusar Valley Pass';

    final phone = _phoneController.text.trim().isNotEmpty
        ? '+92 ${_phoneController.text.trim()}'
        : '+92 300 1234567';

    final newMechanic = Mechanic(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      distance: '0.8 km away',
      durationOrLocation: manualLocation,
      badgeType: BadgeType.verified,
      badgeLabel: 'Pending Verification',
      beaconStatus: 'Community Contributor',
      beaconColor: AppColors.tacticalOrange,
      categoryTitle1: 'BRANDS SERVICED',
      tags1: _selectedBrands.isNotEmpty
          ? _selectedBrands.toList()
          : ['Universal Adventure'],
      categoryTitle2: 'SPECIALTY & TOOLS',
      tags2: _selectedSpecialties.isNotEmpty
          ? _selectedSpecialties.toList()
          : ['General Field Repair'],
      rating: 5.0,
      reviewCount: 1,
      openStatus: 'JUST ADDED (Pending Review)',
      phone: phone,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$name submitted for CAMP verification!',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.statusGreen,
        duration: const Duration(milliseconds: 2500),
      ),
    );

    Navigator.of(context).pop(newMechanic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.clay,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Scrollable Content
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 120, // Space for bottom nav
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom App Bar Row
                  _buildCustomAppBar(),

                  const SizedBox(height: 16),

                  // Header Title & Remote Contributor Badge
                  _buildHeaderTitle(),

                  const SizedBox(height: 20),

                  // Card 1: Shop or Mechanic Name (REQUIRED)
                  _buildShopNameCard(),

                  const SizedBox(height: 16),

                  // Card 2: Location & Coordinates (Required)
                  _buildLocationCard(),

                  const SizedBox(height: 16),

                  // Card 3: Phone Number (OPTIONAL)
                  _buildPhoneCard(),

                  const SizedBox(height: 16),

                  // Card 4: Brands Serviced (Multi-Select)
                  _buildBrandsCard(),

                  const SizedBox(height: 16),

                  // Card 5: Specialty & Tools (Multi-Select)
                  _buildSpecialtyCard(),

                  const SizedBox(height: 16),

                  // Card 6: Shop or Signboard Photo (OPTIONAL)
                  _buildPhotoCard(),

                  const SizedBox(height: 16),

                  // Card 7: Rider Notes & Landmarks (OPTIONAL)
                  _buildNotesCard(),

                  const SizedBox(height: 16),

                  // Card 8: Pending Verification Information Box
                  _buildPendingVerificationNotice(),

                  const SizedBox(height: 24),

                  // Submit Mechanic Button
                  _buildSubmitButton(),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Floating Bottom Navigation Dock (Centered, bottom: 24)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: TacticalBottomDockWidget(
                  selectedIndex: 3,
                  onIndexChanged: (index) {
                    if (index == 3) {
                      Navigator.of(context).pop();
                    } else {
                      CampBottomNav.navigateToTab(context, index, currentIndex: 3);
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

  // --- Top App Bar ---
  Widget _buildCustomAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Circular Back Button with 3D Skeuomorphic Depth
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.clay,
              border: Border.all(color: AppColors.clayDark, width: 1.2),
              boxShadow: AppColors.skeuRaisedSmall,
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: AppColors.darkCharcoal,
              ),
            ),
          ),
        ),

        const SizedBox.shrink(),

        // PITSTOP Pill Badge with Tactile Relief
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.clay,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.clayDark, width: 1.2),
            boxShadow: AppColors.skeuRaisedSmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.statusGreen,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'PITSTOP',
                style: AppTextStyles.overline.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.charcoalLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Header Title Section ---
  Widget _buildHeaderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Add a Mechanic',
              style: AppTextStyles.title.copyWith(
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0DB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x33F56500), width: 1),
                boxShadow: AppColors.skeuRaisedSmall,
              ),
              child: Text(
                'REMOTE CONTRIBUTOR',
                style: AppTextStyles.overline.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: AppColors.tacticalOrangeDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Know a mechanic in a remote area? Add them so other riders can find reliable help on the trail.',
          style: AppTextStyles.bodySecondary.copyWith(
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  // Helper Card Wrapper with Skeuomorphic Dual-Shadow Lighting
  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.clay,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.clayDark, width: 1.2),
        boxShadow: AppColors.skeuRaised,
      ),
      child: child,
    );
  }

  // --- Card 1: Shop or Mechanic Name ---
  Widget _buildShopNameCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.storefront_rounded,
                    size: 18,
                    color: AppColors.tacticalOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SHOP OR MECHANIC NAME',
                    style: AppTextStyles.overline.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoalLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                'REQUIRED',
                style: AppTextStyles.overline.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.tacticalOrange,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.clayDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.clayDark, width: 1.2),
              boxShadow: AppColors.skeuRecessed,
            ),
            child: TextField(
              controller: _nameController,
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkCharcoal,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Babusar Valley Moto Spares & Welding',
                hintStyle: AppTextStyles.bodySecondary.copyWith(
                  color: AppColors.mutedLight,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Card 2: Location & Coordinates ---
  Widget _buildLocationCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.near_me_rounded,
                    size: 18,
                    color: AppColors.tacticalOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LOCATION & COORDINATES',
                    style: AppTextStyles.overline.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoalLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                'Required',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tacticalOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Primary Orange Tactile Push-Button
          GestureDetector(
            onTap: _onGpsTap,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: _orangeGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.orangeGlow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Use Current GPS\nLocation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tacticalOrangeDark.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      _gpsCoordinates,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Divider with Center Text
          Row(
            children: [
              const Expanded(
                child: Divider(color: AppColors.clayDark, thickness: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'OR ENTER MANUALLY',
                  style: AppTextStyles.overline.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mutedLight,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(color: AppColors.clayDark, thickness: 1),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Manual Location Field with Recessed Inset
          Container(
            decoration: BoxDecoration(
              color: AppColors.clayDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.clayDark, width: 1.2),
              boxShadow: AppColors.skeuRecessed,
            ),
            child: TextField(
              controller: _locationController,
              style: AppTextStyles.body.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.darkCharcoal,
              ),
              decoration: InputDecoration(
                hintText: 'Village, pass, valley, or nearby milestone (e.g. Kagha',
                hintStyle: AppTextStyles.bodySecondary.copyWith(
                  color: AppColors.mutedLight,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Card 3: Phone Number ---
  Widget _buildPhoneCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.phone_rounded,
                    size: 18,
                    color: AppColors.tacticalOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PHONE NUMBER',
                    style: AppTextStyles.overline.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoalLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                'OPTIONAL',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedLight,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // +92 Country Code Pill Box with Tactile Relief
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.clayDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.clayDark, width: 1.2),
                  boxShadow: AppColors.skeuRaisedSmall,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.phone_in_talk_rounded,
                      size: 15,
                      color: AppColors.tacticalOrange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+92',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.charcoalLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Phone Input Field with Inset Trough
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.clayDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.clayDark, width: 1.2),
                    boxShadow: AppColors.skeuRecessed,
                  ),
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkCharcoal,
                    ),
                    decoration: InputDecoration(
                      hintText: '300  1234567  /  Satellite Rad',
                      hintStyle: AppTextStyles.bodySecondary.copyWith(
                        color: AppColors.mutedLight,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Card 4: Brands Serviced ---
  Widget _buildBrandsCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.two_wheeler_rounded,
                    size: 18,
                    color: AppColors.tacticalOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'BRANDS SERVICED',
                    style: AppTextStyles.overline.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoalLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                'Select all that apply',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _allBrands.map((brand) {
              final isSelected = _selectedBrands.contains(brand);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedBrands.remove(brand);
                    } else {
                      _selectedBrands.add(brand);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFF0DB)
                        : AppColors.clayDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.tacticalOrangeDark
                          : AppColors.clayDark,
                      width: 1.3,
                    ),
                    boxShadow: isSelected
                        ? AppColors.orangeGlow
                        : AppColors.skeuRaisedSmall,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Icons.check_rounded : Icons.add_rounded,
                        size: 15,
                        color: isSelected
                            ? AppColors.tacticalOrangeDark
                            : AppColors.mutedText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        brand,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12.5,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected
                              ? AppColors.tacticalOrangeDark
                              : AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- Card 5: Specialty & Tools ---
  Widget _buildSpecialtyCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.build_rounded,
                    size: 17,
                    color: AppColors.tacticalOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SPECIALTY & TOOLS',
                    style: AppTextStyles.overline.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoalLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                'Tap to toggle',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _allSpecialties.map((specialty) {
              final isSelected = _selectedSpecialties.contains(specialty);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedSpecialties.remove(specialty);
                    } else {
                      _selectedSpecialties.add(specialty);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFF0DB)
                        : AppColors.clayDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.tacticalOrangeDark
                          : AppColors.clayDark,
                      width: 1.3,
                    ),
                    boxShadow: isSelected
                        ? AppColors.orangeGlow
                        : AppColors.skeuRaisedSmall,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Icons.check_rounded : Icons.add_rounded,
                        size: 15,
                        color: isSelected
                            ? AppColors.tacticalOrangeDark
                            : AppColors.mutedText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        specialty,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12.5,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected
                              ? AppColors.tacticalOrangeDark
                              : AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- Card 6: Shop or Signboard Photo ---
  Widget _buildPhotoCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.photo_camera_rounded,
                    size: 18,
                    color: AppColors.tacticalOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SHOP OR SIGNBOARD PHOTO',
                    style: AppTextStyles.overline.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoalLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                'OPTIONAL',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedLight,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _onPhotoTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.clayDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.clayDark,
                  width: 1.2,
                ),
                boxShadow: AppColors.skeuRecessed,
              ),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.clay,
                      border: Border.all(color: AppColors.clayDark, width: 1),
                      boxShadow: AppColors.skeuRaisedSmall,
                    ),
                    child: Center(
                      child: Icon(
                        _uploadedPhotoName != null
                            ? Icons.check_circle_rounded
                            : Icons.photo_camera_outlined,
                        color: _uploadedPhotoName != null
                            ? AppColors.statusGreen
                            : AppColors.tacticalOrange,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _uploadedPhotoName != null
                        ? _uploadedPhotoName!
                        : 'Take photo or upload signboard',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Helps passing riders recognize the roadside shack or workshop',
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
      ),
    );
  }

  // --- Card 7: Rider Notes & Landmarks ---
  Widget _buildNotesCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.notes_rounded,
                    size: 18,
                    color: AppColors.tacticalOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'RIDER NOTES & LANDMARKS',
                    style: AppTextStyles.overline.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoalLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                'OPTIONAL',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedLight,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.clayDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.clayDark, width: 1.2),
              boxShadow: AppColors.skeuRecessed,
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              style: AppTextStyles.body.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.darkCharcoal,
              ),
              decoration: InputDecoration(
                hintText:
                    'e.g. Next to wooden bridge crossing, has 220V arc welder and stocked spark plugs',
                hintStyle: AppTextStyles.bodySecondary.copyWith(
                  color: AppColors.mutedLight,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                ),
                contentPadding: const EdgeInsets.all(14),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Card 8: Pending Verification Information Box ---
  Widget _buildPendingVerificationNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
        boxShadow: AppColors.skeuRaisedSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: const Icon(
              Icons.access_time_rounded,
              color: Color(0xFFD97706),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF475569),
                  height: 1.45,
                ),
                children: [
                  TextSpan(
                    text: 'Pending Verification: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  TextSpan(
                    text: 'Submitted mechanics are marked ',
                  ),
                  TextSpan(
                    text: '"Pending Verification" ',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFD97706),
                    ),
                  ),
                  TextSpan(
                    text:
                        'until reviewed and corroborated by the CAMP rider network.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Submit Mechanic Button ---
  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _submitMechanic,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: _orangeGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.orangeGlow,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.handyman_rounded,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Submit Mechanic',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
