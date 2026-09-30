import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../dashboard/presentation/widgets/app_drawer_widget.dart';
import '../../../dashboard/presentation/widgets/tactical_bottom_dock_widget.dart';
import '../../../garage/domain/bike_model.dart';
import '../../controllers/bike_onboarding_controller.dart';

/// CAMP Bike Details Screen (Step 2 of 4 in the Add Bike onboarding journey).
/// Captures core mechanical specs, telemetry baseline, and fuel system configuration.
class BikeDetailsScreen extends StatefulWidget {
  const BikeDetailsScreen({super.key, this.initialBike});

  final Bike? initialBike;

  @override
  State<BikeDetailsScreen> createState() => _BikeDetailsScreenState();
}

class _BikeDetailsScreenState extends State<BikeDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final BikeOnboardingController _controller = BikeOnboardingController.instance;

  late TextEditingController _modelNameController;
  late TextEditingController _displacementController;
  late TextEditingController _carburetorTypeController;
  late TextEditingController _fuelTankCapacityController;
  late TextEditingController _odometerController;
  late TextEditingController _currentFuelController;
  late TextEditingController _vinController;
  late TextEditingController _nicknameController;

  bool _submittedOnce = false;

  static const List<String> _makes = [
    'Honda',
    'BMW',
    'Ducati',
    'KTM',
    'Yamaha',
    'Kawasaki',
    'Suzuki',
    'Harley-Davidson',
    'Triumph',
    'Royal Enfield',
    'Aprilia',
    'Husqvarna',
  ];

  static final List<int> _years = List.generate(
    47,
    (index) => DateTime.now().year + 1 - index,
  );

  static const List<Map<String, dynamic>> _bikeTypes = [
    {'name': 'Commuter', 'icon': Icons.commute_rounded},
    {'name': 'Sport', 'icon': Icons.sports_motorsports_rounded},
    {'name': 'Adventure', 'icon': Icons.terrain_rounded},
    {'name': 'Cruiser', 'icon': Icons.motorcycle_rounded},
    {'name': 'Scooter', 'icon': Icons.electric_moped_rounded},
    {'name': 'Electric', 'icon': Icons.bolt_rounded},
  ];

  @override
  void initState() {
    super.initState();

    // If an initialBike was passed into this screen, populate the controller
    if (widget.initialBike != null) {
      final b = widget.initialBike!;
      _controller.setMake(b.make);
      _controller.setModelName(b.modelName);
      _controller.setModelYear(b.modelYear);
      _controller.setDisplacement(b.displacement);
      if (b.bikeType != null) _controller.setBikeType(b.bikeType!);
      _controller.setFuelSystem(b.fuelSystem);
      _controller.setCarburetorType(b.carburetorType);
      _controller.setFuelTankCapacity(b.fuelTankCapacityLiters);
      _controller.setOdometerKm(b.odometerKm);
      _controller.setCurrentFuelLiters(b.currentFuelLiters);
      if (b.lastOilChange != null) {
        _controller.setLastOilChange(b.lastOilChange!);
      }
      if (b.lastTuneUp != null) {
        _controller.setLastTuneUp(b.lastTuneUp!);
      }
      _controller.setVin(b.vin);
      _controller.setNickname(b.nickname);
    }

    _modelNameController =
        TextEditingController(text: _controller.modelName);
    _displacementController = TextEditingController(
      text: _controller.displacement != null
          ? _controller.displacement.toString()
          : '',
    );
    _carburetorTypeController =
        TextEditingController(text: _controller.carburetorType ?? '');
    _fuelTankCapacityController = TextEditingController(
      text: _controller.fuelTankCapacityLiters != null
          ? _controller.fuelTankCapacityLiters.toString()
          : '',
    );
    _odometerController = TextEditingController(
      text: _controller.odometerKm != null
          ? _controller.odometerKm.toString()
          : '',
    );
    _currentFuelController = TextEditingController(
      text: _controller.currentFuelLiters != null
          ? _controller.currentFuelLiters.toString()
          : '',
    );
    _vinController = TextEditingController(text: _controller.vin ?? '');
    _nicknameController =
        TextEditingController(text: _controller.nickname ?? '');

    _controller.addListener(_onControllerUpdated);
  }

  void _onControllerUpdated() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdated);
    _modelNameController.dispose();
    _displacementController.dispose();
    _carburetorTypeController.dispose();
    _fuelTankCapacityController.dispose();
    _odometerController.dispose();
    _currentFuelController.dispose();
    _vinController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    setState(() {
      _submittedOnce = true;
    });

    if (!_controller.isFormValid) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please complete the 4 required fields to proceed.',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: AppColors.alertRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final completedBike = _controller.buildBike();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Motorcycle ${completedBike.make} ${completedBike.modelName} configured!',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2000),
      ),
    );

    // Proceed to Garage screen with newly registered bike telemetry
    Navigator.of(context).pushNamed('/garage');
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _controller.isFormValid;
    final bool isModelNameEmpty =
        _submittedOnce && _controller.modelName.trim().isEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const AppDrawerWidget(),
        backgroundColor: AppColors.clay,
        body: Stack(
          children: [
            // ── Scrollable Body Content ─────────────────────────────────────
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppColors.screenPadding,
                  8.0,
                  AppColors.screenPadding,
                  120.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Top Header Bar (Back Button, CAMP Pill, ADD BIKE Pill)
                    _buildTopAppBar(),

                    const SizedBox(height: 18),

                    // 2. Progress Row: Step Indicator & 4-Segment Progress Bar (Step 2 Filled)
                    _buildProgressRow(),

                    const SizedBox(height: 18),

                    // 3. Title & Subtitle
                    Text(
                      'Bike Details',
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tell us about your motorcycle so CAMP can tailor maintenance predictions.',
                      style: AppTextStyles.bodySecondary,
                    ),

                    const SizedBox(height: 22),

                    // ── Card 1: Basic Information ───────────────────────────
                    _buildBasicInfoCard(isModelNameEmpty),

                    const SizedBox(height: AppColors.cardGap),

                    // ── Card 2: Bike Type ───────────────────────────────────
                    _buildBikeTypeCard(),

                    const SizedBox(height: AppColors.cardGap),

                    // ── Card 3: Engine & Fuel System (Required) ─────────────
                    _buildEngineAndFuelSystemCard(),

                    const SizedBox(height: AppColors.cardGap),

                    // ── Card 4: Current Status ──────────────────────────────
                    _buildCurrentStatusCard(),

                    const SizedBox(height: AppColors.cardGap),

                    // ── Card 5: Optional Info ───────────────────────────────
                    _buildOptionalInfoCard(),

                    const SizedBox(height: 16),

                    // ── Footnote: * Required fields ─────────────────────────
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: '* ',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.alertRed,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'Required fields: Make, Model Name, Model Year, Current Odometer',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.mutedText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── 6. Info Banner ──────────────────────────────────────
                    _buildInfoBanner(),

                    const SizedBox(height: 22),

                    // ── 7. Continue Button ──────────────────────────────────
                    _buildContinueButton(canContinue),

                    const SizedBox(height: 14),

                    // ── 8. Back to Options Link ─────────────────────────────
                    Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            'Back to options',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Floating Bottom Dock (Index 1: Bike Scan Active) ─────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: TacticalBottomDockWidget(
                  selectedIndex: 1,
                  onIndexChanged: (index) {
                    CampBottomNav.navigateToTab(
                      context,
                      index,
                      currentIndex: 1,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Navigation Bar ────────────────────────────────────────────────────
  Widget _buildTopAppBar() {
    return CampAppBar(
      leading: CampAppBarLeading.back,
      titleWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.clay,
          borderRadius: BorderRadius.circular(AppColors.radiusPill),
          boxShadow: AppColors.skeuRaisedSmall,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomPaint(
              size: Size(18, 14),
              painter: CampMountainLogoPainter(),
            ),
            const SizedBox(width: 6),
            Text(
              'CAMP',
              style: GoogleFonts.manrope(
                color: AppColors.darkCharcoal,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      actionWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.clay,
          borderRadius: BorderRadius.circular(AppColors.radiusPill),
          boxShadow: AppColors.skeuRaisedSmall,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 6),
              decoration: const BoxDecoration(
                color: AppColors.tacticalOrange,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              'ADD BIKE',
              style: GoogleFonts.manrope(
                color: AppColors.terracotta,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Progress Row: Step 2 of 4 ─────────────────────────────────────────────
  Widget _buildProgressRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STEP 2 OF 4',
          style: AppTextStyles.overlineOrange,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Segment 1 (Filled - Tactical Orange)
            Expanded(
              child: Container(
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.tacticalOrange,
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Segment 2 (Filled - Tactical Orange)
            Expanded(
              child: Container(
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.tacticalOrange,
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Segment 3 (Unfilled - Clay Deep)
            Expanded(
              child: Container(
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.clayDeep,
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Segment 4 (Unfilled - Clay Deep)
            Expanded(
              child: Container(
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.clayDeep,
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Card 1: Basic Information ─────────────────────────────────────────────
  Widget _buildBasicInfoCard(bool isModelNameEmpty) {
    return CampCard(
      padding: const EdgeInsets.all(AppColors.cardPadding),
      borderRadius: AppColors.radiusCard,
      color: AppColors.clay,
      shadows: AppColors.skeuRaised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BASIC INFORMATION',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.mutedText,
                ),
              ),
              Text(
                'Required',
                style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Make / Manufacturer Dropdown
          LabeledDropdown<String>(
            label: 'Make / Manufacturer',
            value: _makes.contains(_controller.make) ? _controller.make : _makes.first,
            items: _makes,
            onChanged: (val) {
              if (val != null) _controller.setMake(val);
            },
          ),
          const SizedBox(height: 14),

          // Model Name
          LabeledTextField(
            label: 'Model Name',
            controller: _modelNameController,
            placeholder: 'e.g. Africa Twin, CB650R',
            isError: isModelNameEmpty,
            errorText: isModelNameEmpty ? 'Model is required' : null,
            errorLabel: isModelNameEmpty ? '!' : null,
            onChanged: (val) => _controller.setModelName(val),
          ),
          const SizedBox(height: 14),

          // Row: Model Year + Displacement
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LabeledDropdown<int>(
                  label: 'Model Year',
                  value: _years.contains(_controller.modelYear)
                      ? _controller.modelYear
                      : 2024,
                  items: _years,
                  onChanged: (val) {
                    if (val != null) _controller.setModelYear(val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LabeledTextField(
                  label: 'Displacement',
                  controller: _displacementController,
                  placeholder: '1100',
                  suffixText: 'cc',
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final parsed = int.tryParse(val.trim());
                    _controller.setDisplacement(parsed);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Card 2: Bike Type ─────────────────────────────────────────────────────
  Widget _buildBikeTypeCard() {
    return CampCard(
      padding: const EdgeInsets.all(AppColors.cardPadding),
      borderRadius: AppColors.radiusCard,
      color: AppColors.clay,
      shadows: AppColors.skeuRaised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BIKE TYPE',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.mutedText,
                ),
              ),
              Text(
                '${_controller.bikeType} selected',
                style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tacticalOrangeDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2 Rows of 3 Pills
          Row(
            children: [
              _buildTypeChip(_bikeTypes[0]),
              const SizedBox(width: 8),
              _buildTypeChip(_bikeTypes[1]),
              const SizedBox(width: 8),
              _buildTypeChip(_bikeTypes[2]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTypeChip(_bikeTypes[3]),
              const SizedBox(width: 8),
              _buildTypeChip(_bikeTypes[4]),
              const SizedBox(width: 8),
              _buildTypeChip(_bikeTypes[5]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(Map<String, dynamic> item) {
    final name = item['name'] as String;
    final icon = item['icon'] as IconData;
    final isSelected = _controller.bikeType.toLowerCase() == name.toLowerCase();

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          _controller.setBikeType(name);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.tacticalOrangeLight,
                      AppColors.tacticalOrange,
                      AppColors.tacticalOrangeDark,
                    ],
                  )
                : null,
            color: isSelected ? null : AppColors.clay,
            borderRadius: BorderRadius.circular(AppColors.radiusTile - 2),
            border: Border.all(
              color: isSelected
                  ? AppColors.tacticalOrangeLight
                  : Colors.white.withValues(alpha: 0.8),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? AppColors.orangeGlow
                : AppColors.skeuRaisedSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) ...[
                Icon(
                  icon,
                  size: 15,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                name,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.darkCharcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card 3: Engine & Fuel System (Required) ───────────────────────────────
  Widget _buildEngineAndFuelSystemCard() {
    final bool isCarburetor =
        _controller.fuelSystem == FuelSystem.carburetor;

    return CampCard(
      padding: const EdgeInsets.all(AppColors.cardPadding),
      borderRadius: AppColors.radiusCard,
      color: AppColors.clay,
      shadows: AppColors.skeuRaised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ENGINE & FUEL SYSTEM',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.mutedText,
                ),
              ),
              Text(
                'Required',
                style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Fuel System Segmented Control
          Text(
            'Fuel System',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          SegmentedControl(
            options: const ['Carburetor', 'Fuel Injection (EFI)'],
            selectedIndex: isCarburetor ? 0 : 1,
            onChanged: (idx) {
              HapticFeedback.selectionClick();
              _controller.setFuelSystem(
                idx == 0 ? FuelSystem.carburetor : FuelSystem.efi,
              );
            },
          ),
          const SizedBox(height: 14),

          // Conditional Carburetor Type (Removed completely from widget tree when EFI)
          if (isCarburetor) ...[
            LabeledTextField(
              label: 'Carburetor Type',
              controller: _carburetorTypeController,
              placeholder: 'e.g. Mikuni, Keihin, CV',
              helperText: 'Specify the carburetor make or slide configuration',
              onChanged: (val) => _controller.setCarburetorType(val),
            ),
            const SizedBox(height: 14),
          ],

          // Fuel Tank Capacity
          LabeledTextField(
            label: 'Fuel Tank Capacity',
            controller: _fuelTankCapacityController,
            placeholder: 'e.g. 18.8',
            suffixText: 'L',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (val) {
              final parsed = double.tryParse(val.trim());
              _controller.setFuelTankCapacity(parsed);
            },
          ),
        ],
      ),
    );
  }

  // ── Card 4: Current Status ────────────────────────────────────────────────
  Widget _buildCurrentStatusCard() {
    final bool isOdoEmpty =
        _submittedOnce && (_controller.odometerKm == null || _controller.odometerKm! < 0);

    return CampCard(
      padding: const EdgeInsets.all(AppColors.cardPadding),
      borderRadius: AppColors.radiusCard,
      color: AppColors.clay,
      shadows: AppColors.skeuRaised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CURRENT STATUS',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.mutedText,
                ),
              ),
              Text(
                'Update anytime from Garage',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mutedLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Current Odometer Reading (Required)
          LabeledTextField(
            label: 'Current Odometer Reading *',
            controller: _odometerController,
            placeholder: 'e.g. 14,820',
            suffixText: 'km',
            keyboardType: TextInputType.number,
            isError: isOdoEmpty,
            errorText: isOdoEmpty ? 'Current odometer reading is required' : null,
            rightLabelWidget: Text(
              'REQUIRED',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: AppColors.alertRed,
              ),
            ),
            onChanged: (val) {
              final cleaned = val.replaceAll(RegExp(r'[^\d]'), '');
              final parsed = int.tryParse(cleaned);
              _controller.setOdometerKm(parsed);
            },
          ),
          const SizedBox(height: 14),

          // Current Fuel Level (Optional)
          LabeledTextField(
            label: 'Current Fuel Level (Optional)',
            controller: _currentFuelController,
            placeholder: 'e.g. 12.5',
            suffixText: 'L',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (val) {
              final parsed = double.tryParse(val.trim());
              _controller.setCurrentFuelLiters(parsed);
            },
          ),
          const SizedBox(height: 14),

          // Last Oil Change (DistanceOrDateInput from Phase 2)
          DistanceOrDateInput(
            label: 'Last Oil Change',
            value: _controller.lastOilChange,
            placeholderKm: 'e.g. 3,200',
            onChanged: (record) => _controller.setLastOilChange(record),
          ),
          const SizedBox(height: 14),

          // Last Tune-Up (DistanceOrDateInput from Phase 2)
          DistanceOrDateInput(
            label: 'Last Tune-Up',
            value: _controller.lastTuneUp,
            placeholderKm: 'e.g. 5,000',
            onChanged: (record) => _controller.setLastTuneUp(record),
          ),
        ],
      ),
    );
  }

  // ── Card 5: Optional Info ─────────────────────────────────────────────────
  Widget _buildOptionalInfoCard() {
    return CampCard(
      padding: const EdgeInsets.all(AppColors.cardPadding),
      borderRadius: AppColors.radiusCard,
      color: AppColors.clay,
      shadows: AppColors.skeuRaised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OPTIONAL INFO',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.mutedText,
                ),
              ),
              Text(
                'Telemetry Sync',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Serial / VIN with Camera Trailing Icon
          LabeledTextField(
            label: 'Serial / VIN',
            controller: _vinController,
            placeholder: 'E.G. JH2SD0408MK000...',
            helperText: '17 characters, found on the steering stem plate',
            trailingWidget: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.clay,
                borderRadius: BorderRadius.circular(8),
                boxShadow: AppColors.skeuRaisedSmall,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 16,
                color: AppColors.tacticalOrange,
              ),
            ),
            onChanged: (val) => _controller.setVin(val),
          ),
          const SizedBox(height: 14),

          // Vehicle Nickname
          LabeledTextField(
            label: 'Vehicle Nickname',
            controller: _nicknameController,
            placeholder: 'e.g. Black Beast',
            onChanged: (val) => _controller.setNickname(val),
          ),
        ],
      ),
    );
  }

  // ── 6. Info Banner ────────────────────────────────────────────────────────
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.clay,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: AppColors.skeuRaisedSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFFFFEDE1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.tacticalOrangeDark,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You can edit these details anytime from your Garage.',
              style: GoogleFonts.manrope(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoalLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 7. Continue Button ────────────────────────────────────────────────────
  Widget _buildContinueButton(bool canContinue) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleContinue,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: canContinue
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.tacticalOrangeLight,
                    AppColors.tacticalOrange,
                    AppColors.tacticalOrangeDark,
                  ],
                )
              : null,
          color: canContinue ? null : AppColors.clayDark,
          borderRadius: BorderRadius.circular(AppColors.radiusTile),
          border: Border.all(
            color: canContinue
                ? AppColors.tacticalOrangeLight
                : Colors.white.withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: canContinue
              ? AppColors.orangeGlow
              : AppColors.skeuRaisedSmall,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: GoogleFonts.manrope(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: canContinue ? Colors.white : AppColors.mutedLight,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: canContinue ? Colors.white : AppColors.mutedLight,
            ),
          ],
        ),
      ),
    );
  }
}
