import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/skeuomorphic_container.dart';
import '../../../../core/widgets/camp_bottom_nav.dart';
import '../../../dashboard/presentation/widgets/app_drawer_widget.dart';
import '../../../dashboard/presentation/widgets/tactical_bottom_dock_widget.dart';
import '../../controllers/bike_onboarding_controller.dart';

/// Strongly typed motorcycle telemetry record for scan results.
class BikeScanData {
  const BikeScanData({
    required this.model,
    required this.matchRate,
    required this.vin,
    required this.vinSnippet,
    required this.mileage,
    required this.mileageSnippet,
    required this.displacement,
    required this.powerplantType,
    required this.powerplantTech,
    required this.frontPsi,
    required this.frontOk,
    required this.rearPsi,
    required this.rearOk,
    required this.nextMaintenance,
    required this.heading,
  });

  final String model;
  final String matchRate;
  final String vin;
  final String vinSnippet;
  final String mileage;
  final String mileageSnippet;
  final String displacement;
  final String powerplantType;
  final String powerplantTech;
  final int frontPsi;
  final bool frontOk;
  final int rearPsi;
  final bool rearOk;
  final String nextMaintenance;
  final String heading;
}

/// CAMP Bike Scan & Computer Vision Telemetry Screen.
/// Provides live camera feed, scan laser animation, mock telemetry randomization,
/// and full skeuomorphic clay tactile UI.
class BikeScanScreen extends StatefulWidget {
  const BikeScanScreen({super.key, this.imagePath});

  final String? imagePath;

  @override
  State<BikeScanScreen> createState() => _BikeScanScreenState();
}

class _BikeScanScreenState extends State<BikeScanScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Camera Controller & State ──────────────────────────────────────────────
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraLoading = true;
  bool _cameraError = false;
  bool _isFlashOn = false;
  bool _isAudioActive = false;

  // ── Scan Animation & Simulation State ─────────────────────────────────────
  bool _isScanning = false;
  late AnimationController _scanAnimController;
  late Animation<double> _scanProgress;

  // ── Mock Scanned Telemetry Data ───────────────────────────────────────────
  int _variantIndex = 0;
  static const List<BikeScanData> _mockVariants = [
    BikeScanData(
      model: '2023 BMW R 1250 GS Adventure',
      matchRate: '99.4%',
      vin: 'WB10J9309PZE84102',
      vinSnippet: 'WB10J93...',
      mileage: '14,820',
      mileageSnippet: '14.8k km',
      displacement: '1,254 cc',
      powerplantType: 'TWIN BOXER',
      powerplantTech: 'SHIFTCAM',
      frontPsi: 34,
      frontOk: true,
      rearPsi: 31,
      rearOk: false,
      nextMaintenance: '18,000 km • Valve Check & Fluids',
      heading: '330° NW',
    ),
    BikeScanData(
      model: '2024 Ducati Multistrada V4 Rally',
      matchRate: '99.8%',
      vin: 'ZD12A9308PZE92811',
      vinSnippet: 'ZD12A93...',
      mileage: '8,340',
      mileageSnippet: '8.3k km',
      displacement: '1,158 cc',
      powerplantType: 'V4 GRANTURISMO',
      powerplantTech: 'DESMO-FREE',
      frontPsi: 36,
      frontOk: true,
      rearPsi: 38,
      rearOk: true,
      nextMaintenance: '15,000 km • Desmo Service Check',
      heading: '045° NE',
    ),
    BikeScanData(
      model: '2023 KTM 1290 Super Adventure R',
      matchRate: '98.9%',
      vin: 'VBKVA4407P9281033',
      vinSnippet: 'VBKVA44...',
      mileage: '11,250',
      mileageSnippet: '11.2k km',
      displacement: '1,301 cc',
      powerplantType: 'LC8 75° V-TWIN',
      powerplantTech: 'RALLY TUNED',
      frontPsi: 35,
      frontOk: true,
      rearPsi: 32,
      rearOk: false,
      nextMaintenance: '15,000 km • Suspension & Fluids',
      heading: '190° S',
    ),
  ];

  static const BikeScanData _unpopulatedData = BikeScanData(
    model: 'Manual Vehicle Entry',
    matchRate: '0%',
    vin: 'Unfilled',
    vinSnippet: 'Unfilled',
    mileage: 'Unfilled',
    mileageSnippet: 'Unfilled',
    displacement: 'Unfilled',
    powerplantType: 'Unfilled',
    powerplantTech: 'Unfilled',
    frontPsi: 0,
    frontOk: true,
    rearPsi: 0,
    rearOk: true,
    nextMaintenance: 'Unfilled',
    heading: 'N/A',
  );

  // True once didChangeDependencies has run for the first time.
  bool _cameraDepsInitialized = false;

  /// Checks whether an image path was supplied via constructor or route args.
  /// SAFE to call from build() / didChangeDependencies() — uses ModalRoute.
  String? get _effectiveImagePath {
    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      return widget.imagePath;
    }
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      return args;
    }
    return null;
  }

  BikeScanData get _currentData {
    if (_effectiveImagePath != null) {
      return _unpopulatedData;
    }
    return _mockVariants[_variantIndex];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize scan animation controller (1.5s sweep)
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scanProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanAnimController, curve: Curves.easeInOut),
    );
    // NOTE: camera is initialized in didChangeDependencies (safe to use
    // ModalRoute.of(context) there, unlike initState).
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_cameraDepsInitialized) {
      _cameraDepsInitialized = true;
      // widget.imagePath is sufficient here; full ModalRoute check happens in
      // _effectiveImagePath during _initializeCamera's first async frame.
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanAnimController.dispose();
    _cameraController?.dispose();
    _cameraController = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? camera = _cameraController;
    if (camera == null) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _isCameraLoading = false;
        });
      }
      camera.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  // ── Camera Initialization & Graceful Fallback ─────────────────────────────
  Future<void> _initializeCamera() async {
    if (!mounted || _effectiveImagePath != null) {
      if (mounted) {
        setState(() {
          _isCameraLoading = false;
          _isCameraInitialized = false;
        });
      }
      return;
    }
    setState(() {
      _isCameraLoading = true;
      _isCameraInitialized = false;
      _cameraError = false;
    });

    try {
      List<CameraDescription> cameras;
      try {
        cameras = await availableCameras().timeout(
          const Duration(milliseconds: 600),
        );
      } on MissingPluginException {
        throw Exception('Camera plugin unavailable');
      }
      if (cameras.isEmpty) {
        throw Exception('No camera devices available');
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final oldController = _cameraController;
      _cameraController = null;
      await oldController?.dispose();

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _cameraController = controller;
      try {
        await controller.initialize().timeout(
          const Duration(milliseconds: 800),
        );
      } on MissingPluginException {
        throw Exception('Camera plugin unavailable');
      }

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _isCameraInitialized = true;
        _isCameraLoading = false;
        _cameraError = false;
      });
    } catch (_) {
      if (!mounted) return;
      _cameraController?.dispose();
      _cameraController = null;
      setState(() {
        _isCameraInitialized = false;
        _isCameraLoading = false;
        _cameraError = true;
      });
    }
  }

  // ── Flash Toggle ──────────────────────────────────────────────────────────
  Future<void> _toggleFlash() async {
    final controller = _cameraController;
    if (controller != null && _isCameraInitialized && controller.value.isInitialized) {
      try {
        final newMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
        await controller.setFlashMode(newMode);
        if (!mounted) return;
        setState(() {
          _isFlashOn = !_isFlashOn;
        });
        _showNotification(_isFlashOn ? 'Torch Active (High Output)' : 'Torch Disengaged');
        return;
      } catch (_) {
        // Fallback simulated toggle
      }
    }

    if (!mounted) return;
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    _showNotification(_isFlashOn ? 'Simulated Torch ON' : 'Simulated Torch OFF');
  }

  // ── Audio/Mic Toggle ──────────────────────────────────────────────────────
  void _toggleAudio() {
    setState(() {
      _isAudioActive = !_isAudioActive;
    });
    _showNotification(_isAudioActive ? 'Acoustic Diagnostic Mic Active' : 'Acoustic Mic Muted');
  }

  // ── Scan Animation & Randomization ────────────────────────────────────────
  void _runScanAnimation() {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    HapticFeedback.mediumImpact();

    _scanAnimController.forward(from: 0.0).then((_) {
      if (!mounted) return;

      setState(() {
        _isScanning = false;
        _variantIndex = (_variantIndex + 1) % _mockVariants.length;
      });

      HapticFeedback.heavyImpact();
      _showNotification('Optical Telemetry Locked: ${_currentData.model}');
    });
  }

  // ── Save & Sync to Garage ─────────────────────────────────────────────────
  void _saveAndSyncToGarage() {
    HapticFeedback.lightImpact();
    BikeOnboardingController.instance.populateFromScan(
      rawModel: _currentData.model,
      rawVin: _currentData.vin,
      rawMileage: _currentData.mileage,
      rawDisplacement: _currentData.displacement,
    );
    _showNotification('Optical telemetry locked. Reviewing bike details...');
    Navigator.of(context).pushNamed('/bike-details');
  }

  void _showNotification(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2200),
      ),
    );
  }

  void _copyVin(String vin) {
    Clipboard.setData(ClipboardData(text: vin));
    HapticFeedback.selectionClick();
    _showNotification('VIN copied to clipboard: $vin');
  }

  void _showEditManualDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.clay,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.charcoalLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Manual Telemetry Override',
                style: TextStyle(
                  color: AppColors.darkCharcoal,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Adjust scanned vehicle parameters, VIN, or sensor readings manually if the vision scanner misidentified custom components.',
                style: TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              SkeuomorphicOrangeButton(
                label: 'Edit in Bike Details (Step 2)',
                icon: Icons.edit_note_rounded,
                onTap: () {
                  Navigator.of(ctx).pop();
                  BikeOnboardingController.instance.populateFromScan(
                    rawModel: _currentData.model,
                    rawVin: _currentData.vin,
                    rawMileage: _currentData.mileage,
                    rawDisplacement: _currentData.displacement,
                  );
                  Navigator.of(context).pushNamed('/bike-details');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 115.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Top Header Bar
                    _buildTopHeader(),

                    const SizedBox(height: 12),

                    // 2. Telemetry Vision 4.2 Sub-Header Row
                    _buildSubHeader(),

                    const SizedBox(height: 12),

                    // 3. Interactive Camera Viewport / Scanner HUD
                    _buildCameraViewport(),

                    const SizedBox(height: 16),

                    // 4. Detected Vehicle Spec Card
                    _buildDetectedVehicleCard(),

                    const SizedBox(height: 16),

                    // 5. Next Scheduled Maintenance Card
                    _buildMaintenanceCard(),
                  ],
                ),
              ),
            ),

            // ── 6. Tactical Floating Bottom Dock (Index 1: Bike Scan Active) ──
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: TacticalBottomDockWidget(
                  selectedIndex: 1, // Bike Scan Tab Active
                  onIndexChanged: (index) {
                    if (index == 1) {
                      _runScanAnimation();
                    } else {
                      CampBottomNav.navigateToTab(context, index, currentIndex: 1);
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

  // ── 1. Top Header Bar ──────────────────────────────────────────────────────
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Skeuomorphic Raised Circular Menu Button (Solid, NO dashed border!)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                _scaffoldKey.currentState?.openDrawer();
              }
            },
            child: SkeuomorphicContainer(
              borderRadius: 100,
              shadows: AppColors.skeuRaisedSmall,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Navigator.of(context).canPop()
                      ? const Icon(Icons.arrow_back_rounded, color: AppColors.darkCharcoal, size: 22)
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _menuBar(),
                            const SizedBox(height: 3.2),
                            _menuBar(),
                            const SizedBox(height: 3.2),
                            _menuBar(),
                          ],
                        ),
                ),
              ),
            ),
          ),

          // Center: CAMP Mountain Logo + Wordmark
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                size: const Size(20, 16),
                painter: _CampMountainLogoPainter(),
              ),
              const SizedBox(width: 6),
              const Text(
                'CAMP',
                style: TextStyle(
                  color: AppColors.darkCharcoal,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          // Right: Skeuomorphic Pill Badge ("• BIKE SCAN")
          SkeuomorphicContainer(
            borderRadius: 20,
            shadows: AppColors.skeuRaisedSmall,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF56500),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x66F56500),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                const Text(
                  'BIKE SCAN',
                  style: TextStyle(
                    color: AppColors.darkCharcoal,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuBar() {
    return Container(
      width: 17,
      height: 2.2,
      decoration: BoxDecoration(
        color: AppColors.darkCharcoal,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }

  // ── 2. Sub-Header: Vision Engine Status & ISO Readout ──────────────────────
  Widget _buildSubHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Pulsing orange indicator + Vision version
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF56500),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x99F56500),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Flexible(
                  child: Text(
                    'TELEMETRY VISION 4.2',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.darkCharcoal,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Right: Inset sensor telemetry readout
          const SkeuomorphicInsetContainer(
            borderRadius: 14,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sensors_rounded,
                  size: 13,
                  color: Color(0xFFF56500),
                ),
                SizedBox(width: 4),
                Text(
                  'ISO AUTO • 60 FPS',
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Interactive Camera Viewport / Scanner HUD ───────────────────────────
  Widget _buildCameraViewport() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.clay,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.cockpitBezel,
      ),
      padding: const EdgeInsets.all(5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 275,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // A. Live Camera Preview or Graceful High-Res Fallback
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _runScanAnimation,
                child: _buildViewportBackground(),
              ),

              // B. Subtle Vignette Shadow
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.72),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // C. Top Left HUD: Corner Bracket & VIN Snippet Pill
              Positioned(
                top: 14,
                left: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomPaint(
                      size: const Size(22, 22),
                      painter: _ReticleCornerPainter(color: const Color(0xFFF56500)),
                    ),
                    const SizedBox(height: 8),
                    _hudPill(
                      icon: Icons.qr_code_2_rounded,
                      iconColor: const Color(0xFFF56500),
                      label: 'VIN: ${_currentData.vinSnippet}',
                    ),
                  ],
                ),
              ),

              // D. Top Right HUD: Torch & Mic Controls (Solid, NO dashed border!)
              Positioned(
                top: 14,
                right: 14,
                child: Row(
                  children: [
                    // Flash Torch Toggle Button
                    GestureDetector(
                      onTap: _toggleFlash,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isFlashOn
                              ? const Color(0xFFF56500)
                              : Colors.black.withValues(alpha: 0.6),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                          boxShadow: _isFlashOn
                              ? const [
                                  BoxShadow(
                                    color: Color(0x99F56500),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Icon(
                            _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Acoustic Mic Button
                    GestureDetector(
                      onTap: _toggleAudio,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isAudioActive
                              ? const Color(0xFFF56500)
                              : Colors.black.withValues(alpha: 0.6),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _isAudioActive ? Icons.mic_rounded : Icons.mic_none_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // E. Center Reticle & ODO Lock Callout
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Reticle ring
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0x77F56500),
                              width: 1.5,
                            ),
                          ),
                        ),

                        // Center orange aiming dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF56500),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFF56500),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),

                        // Compass Heading Label
                        Positioned(
                          top: -18,
                          child: Text(
                            _currentData.heading,
                            style: const TextStyle(
                              color: Color(0xFFF56500),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        // Connected ODO Lock Callout Tag
                        Positioned(
                          right: -105,
                          top: -12,
                          child: _hudPill(
                            icon: Icons.lock_clock_rounded,
                            iconColor: const Color(0xFFF56500),
                            label: 'ODO Lock: ${_currentData.mileageSnippet}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // F. Bottom Left HUD: Fork Sensor Status
              Positioned(
                left: 14,
                bottom: 48,
                child: _hudPill(
                  icon: Icons.check_circle_rounded,
                  iconColor: AppColors.statusGreen,
                  label: 'Fork Sensor OK',
                ),
              ),

              // G. Bottom HUD Status Bar: Optical Frame Locked + RE-SCAN Action
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Frame Status
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isScanning ? AppColors.alertRed : const Color(0xFFF56500),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _isScanning ? AppColors.alertRed : const Color(0xFFF56500),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isScanning ? 'Vision Scanning Frame...' : 'Optical Frame Locked',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),

                    // Right: RE-SCAN Pill Button
                    GestureDetector(
                      onTap: _runScanAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.28),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RotationTransition(
                              turns: _scanProgress,
                              child: const Icon(
                                Icons.sync_rounded,
                                size: 14,
                                color: Color(0xFFF56500),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'RE-SCAN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // H. Animated Vertical Laser Scanning Line (Sweeps across viewport)
              if (_isScanning)
                AnimatedBuilder(
                  animation: _scanProgress,
                  builder: (context, _) {
                    final double topPosition = _scanProgress.value * 270;
                    return Positioned(
                      top: topPosition,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Laser glow sweep
                            Container(
                              height: 3,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Color(0x88F56500),
                                    Color(0xFFF56500),
                                    Color(0x88F56500),
                                    Colors.transparent,
                                  ],
                                  stops: [0.0, 0.2, 0.5, 0.8, 1.0],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFF56500),
                                    blurRadius: 14,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            // Trailing laser flare
                            Container(
                              height: 18,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x33F56500),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Viewport Background (Camera feed vs High-Res Placeholder) ──────────────
  Widget _buildViewportBackground() {
    final imagePath = _effectiveImagePath;
    if (imagePath != null) {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFF222222),
          child: const Center(
            child: Icon(Icons.broken_image_rounded, color: Colors.white38, size: 54),
          ),
        ),
      );
    }

    if (_isCameraInitialized &&
        _cameraController != null &&
        _cameraController!.value.isInitialized &&
        !_cameraError) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _cameraController!.value.previewSize?.height ?? 1,
            height: _cameraController!.value.previewSize?.width ?? 1,
            child: CameraPreview(_cameraController!),
          ),
        ),
      );
    }

    if (_isCameraLoading) {
      return Container(
        color: const Color(0xFF181818),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF56500)),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'INITIALIZING VISION OPTICS...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Graceful fallback to bundled high-resolution motorcycle asset
    return Image.asset(
      'assets/images/bmw_r1250_scan_placeholder.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFF222222),
        child: const Center(
          child: Icon(Icons.directions_bike_rounded, color: Colors.white38, size: 54),
        ),
      ),
    );
  }

  // Helper: Glassmorphic dark HUD badge
  Widget _hudPill({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Lower Skeuomorphic Card: Detected Vehicle Specs & Telemetry ─────────
  Widget _buildDetectedVehicleCard() {
    return SkeuomorphicContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Match Rate Pill + Circular Verification Check
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8D4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0x33F56500),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_outlined,
                        size: 15,
                        color: Color(0xFFF56500),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Auto-Detected Vehicle • ${_currentData.matchRate} Match',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFF56500),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Circular Verified Badge
              SkeuomorphicContainer(
                borderRadius: 24,
                shadows: AppColors.skeuRaisedSmall,
                color: Colors.white,
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFFF56500),
                      size: 21,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Vehicle Title Heading
          Text(
            _currentData.model,
            style: const TextStyle(
              color: AppColors.darkCharcoal,
              fontSize: 19.5,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 8),

          // VIN Code Row with Copy Button
          Row(
            children: [
              const Text(
                'VIN',
                style: TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              SkeuomorphicInsetContainer(
                borderRadius: 8,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                child: Text(
                  _currentData.vin,
                  style: const TextStyle(
                    color: AppColors.darkCharcoal,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _copyVin(_currentData.vin),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: Color(0xFFF56500),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Two-Column Spec Cards: Mileage & Powerplant
          Row(
            children: [
              // Left: Mileage Card
              Expanded(
                child: _buildSpecSubCard(
                  icon: Icons.speed_rounded,
                  label: 'DETECTED\nMILEAGE',
                  value: _currentData.mileage,
                  subtitle: 'VERIFIED MILES',
                ),
              ),
              const SizedBox(width: 12),
              // Right: Powerplant Card
              Expanded(
                child: _buildSpecSubCard(
                  icon: Icons.electric_bolt_rounded,
                  label: 'POWERPLANT\n ',
                  value: _currentData.displacement,
                  subtitle: '${_currentData.powerplantType}\n${_currentData.powerplantTech}',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // RDC Tire Telemetry Sub-Card
          _buildTireTelemetrySection(),

          const SizedBox(height: 14),

          // Incorrect Details? Edit Manually
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.edit_note_rounded,
                  size: 16,
                  color: AppColors.mutedText,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Incorrect details? ',
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: _showEditManualDialog,
                  child: const Text(
                    'Edit Manually',
                    style: TextStyle(
                      color: Color(0xFFF56500),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFFF56500),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Full-Width Extruded Glowing Orange Button: Save & Sync to Garage
          GestureDetector(
            onTap: _saveAndSyncToGarage,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.tacticalOrangeLight,
                    AppColors.tacticalOrange,
                    AppColors.tacticalOrangeDark,
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
                boxShadow: AppColors.orangeGlow,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sync_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Save & Sync to Garage',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
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

  // Helper: Sub-spec tile (white clay raised card)
  Widget _buildSpecSubCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return SkeuomorphicContainer(
      borderRadius: 18,
      color: Colors.white.withValues(alpha: 0.88),
      padding: const EdgeInsets.all(14),
      shadows: AppColors.skeuRaisedSmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE8D4),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: const Color(0xFFF56500), size: 15),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.darkCharcoal,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.mutedText,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // Helper: RDC Tire Telemetry Section with Front/Rear Readings
  Widget _buildTireTelemetrySection() {
    return SkeuomorphicInsetContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.tire_repair_rounded,
                    size: 15,
                    color: Color(0xFFF56500),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'RDC TIRE TELEMETRY',
                    style: TextStyle(
                      color: Color(0xFFF56500),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'TPMS Live',
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              // Front Tire
              Expanded(
                child: SkeuomorphicContainer(
                  borderRadius: 14,
                  color: Colors.white,
                  shadows: AppColors.skeuRaisedSmall,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FRONT',
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              text: '${_currentData.frontPsi}',
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkCharcoal,
                              ),
                              children: const [
                                TextSpan(
                                  text: ' PSI',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.statusGreen,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Rear Tire
              Expanded(
                child: SkeuomorphicContainer(
                  borderRadius: 14,
                  color: Colors.white,
                  shadows: AppColors.skeuRaisedSmall,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'REAR',
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              text: '${_currentData.rearPsi}',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                                color: _currentData.rearOk
                                    ? AppColors.darkCharcoal
                                    : const Color(0xFFF56500),
                              ),
                              children: const [
                                TextSpan(
                                  text: ' PSI',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(
                        _currentData.rearOk
                            ? Icons.check_circle_outline_rounded
                            : Icons.warning_amber_rounded,
                        color: _currentData.rearOk
                            ? AppColors.statusGreen
                            : const Color(0xFFF56500),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 5. Next Scheduled Maintenance Card ────────────────────────────────────
  Widget _buildMaintenanceCard() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pushNamed('/mechanics'),
      child: SkeuomorphicContainer(
        borderRadius: 22,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Circular Wrench Badge
          SkeuomorphicContainer(
            borderRadius: 20,
            shadows: AppColors.skeuRaisedSmall,
            color: Colors.white,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Icon(
                  Icons.build_rounded,
                  color: Color(0xFFF56500),
                  size: 19,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEXT SCHEDULED MAINTENANCE',
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _currentData.nextMaintenance,
                  style: const TextStyle(
                    color: AppColors.darkCharcoal,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          // Chevron Action
          SkeuomorphicContainer(
            borderRadius: 16,
            shadows: AppColors.skeuRaisedSmall,
            child: const SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.mutedText,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ── Custom Painters ─────────────────────────────────────────────────────────

/// Corner HUD bracket painter (L-bracket)
class _ReticleCornerPainter extends CustomPainter {
  _ReticleCornerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Geometric CAMP Mountain Logo Painter
class _CampMountainLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF56500)
      ..style = PaintingStyle.fill;

    // Peak 1
    final path1 = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.42, 0)
      ..lineTo(size.width * 0.72, size.height)
      ..close();

    // Peak 2
    final path2 = Path()
      ..moveTo(size.width * 0.45, size.height)
      ..lineTo(size.width * 0.75, size.height * 0.3)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path1, paint);
    canvas.drawPath(
      path2,
      Paint()
        ..color = const Color(0xFFE25300)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
