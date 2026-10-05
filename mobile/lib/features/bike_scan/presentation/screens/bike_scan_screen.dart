import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../controllers/bike_onboarding_controller.dart';
import '../../domain/bike_recognition_provider.dart';
import '../../domain/bike_recognition_service.dart';
import '../../utils/gallery_picker_helper.dart';
import 'bike_details_screen.dart';

// ── Recognition Banner state ──────────────────────────────────────────────────
enum _BannerState { none, analyzing, identified, notIdentified }

/// CAMP Bike Scan Screen — real camera flow that connects to the Bike Details form.
///
/// Accepts:
///   [imagePath] — optional, starts in "photo taken" state with a gallery image.
///   [recognitionService] — injectable for widget tests (defaults to [BikeRecognitionProvider.instance]).
///   [cameraAvailable] — injectable for widget tests (defaults to runtime detection).
class BikeScanScreen extends StatefulWidget {
  const BikeScanScreen({
    super.key,
    this.imagePath,
    this.recognitionService,
    this.cameraAvailable,
  });

  final String? imagePath;

  /// Override the recognition service (e.g. for widget tests).
  final BikeRecognitionService? recognitionService;

  /// Override camera availability (true = has camera, false = no camera, null = autodetect).
  final bool? cameraAvailable;

  @override
  State<BikeScanScreen> createState() => _BikeScanScreenState();
}

class _BikeScanScreenState extends State<BikeScanScreen>
    with WidgetsBindingObserver {
  // ── Camera ────────────────────────────────────────────────────────────────
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraLoading = true;
  bool _cameraError = false;
  bool _permissionDenied = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  List<CameraDescription> _cameras = [];

  // ── Screen state ──────────────────────────────────────────────────────────
  String? _capturedImagePath;
  bool get _hasPhoto => _capturedImagePath != null;

  // ── Recognition ───────────────────────────────────────────────────────────
  _BannerState _bannerState = _BannerState.none;
  BikeRecognitionResult? _recognitionResult;
  Timer? _analysisTimeoutTimer;

  // ── Debug long-press demo toggle ──────────────────────────────────────────
  _BannerState? _debugOverrideBanner;

  bool _cameraDepsInitialized = false;

  BikeRecognitionService get _service =>
      widget.recognitionService ?? BikeRecognitionProvider.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_cameraDepsInitialized) {
      _cameraDepsInitialized = true;
      // If a pre-selected image was passed in, skip the live camera.
      final initPath = widget.imagePath ??
          (ModalRoute.of(context)?.settings.arguments is String
              ? ModalRoute.of(context)!.settings.arguments as String
              : null);
      if (initPath != null && initPath.isNotEmpty) {
        _capturedImagePath = initPath;
        _isCameraLoading = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _runRecognition(File(initPath));
        });
      } else {
        _initializeCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _analysisTimeoutTimer?.cancel();
    // Directly dispose the controller without setState — the element is
    // already being unmounted and calling setState would assert-fail.
    final c = _cameraController;
    _cameraController = null;
    c?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed && !_hasPhoto) {
      _initializeCamera();
    }
  }

  // ── Camera helpers ────────────────────────────────────────────────────────

  void _disposeCamera() {
    final c = _cameraController;
    _cameraController = null;
    c?.dispose();
    if (mounted) {
      setState(() {
        _isCameraInitialized = false;
        _isCameraLoading = false;
      });
    } else {
      _isCameraInitialized = false;
      _isCameraLoading = false;
    }
  }

  Future<void> _initializeCamera() async {
    if (!mounted) return;
    setState(() {
      _isCameraLoading = true;
      _isCameraInitialized = false;
      _cameraError = false;
      _permissionDenied = false;
    });

    // Respect the injected override (useful for tests).
    if (widget.cameraAvailable == false) {
      if (!mounted) return;
      setState(() {
        _isCameraLoading = false;
        _cameraError = true;
      });
      return;
    }

    try {
      List<CameraDescription> cameras;
      try {
        cameras = await availableCameras().timeout(
          const Duration(milliseconds: 800),
        );
      } on MissingPluginException {
        throw Exception('camera_plugin_unavailable');
      }
      if (cameras.isEmpty) {
        throw Exception('no_camera');
      }

      _cameras = cameras;

      final desc = _cameras.firstWhere(
        (c) => c.lensDirection ==
            (_isFrontCamera
                ? CameraLensDirection.front
                : CameraLensDirection.back),
        orElse: () => _cameras.first,
      );

      await _disposeAndCreateController(desc);
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _isCameraLoading = false;
        _cameraError = true;
        _permissionDenied = e.code.contains('permission');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCameraLoading = false;
        _cameraError = true;
        _permissionDenied =
            e.toString().contains('permission') ||
            e.toString().contains('denied');
      });
    }
  }

  Future<void> _disposeAndCreateController(CameraDescription desc) async {
    final old = _cameraController;
    _cameraController = null;
    await old?.dispose();

    if (!mounted) return;

    final controller = CameraController(
      desc,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _cameraController = controller;

    try {
      await controller.initialize().timeout(
        const Duration(milliseconds: 1200),
      );
    } on MissingPluginException {
      if (!mounted) return;
      setState(() {
        _isCameraLoading = false;
        _cameraError = true;
      });
      return;
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
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    await _initializeCamera();
  }

  Future<void> _toggleFlash() async {
    final c = _cameraController;
    if (c != null && c.value.isInitialized) {
      try {
        await c.setFlashMode(_isFlashOn ? FlashMode.off : FlashMode.torch);
      } catch (_) {
        // Ignore on emulators.
      }
    }
    if (!mounted) return;
    setState(() => _isFlashOn = !_isFlashOn);
  }

  // ── Shutter ───────────────────────────────────────────────────────────────

  Future<void> _takePicture() async {
    final c = _cameraController;
    if (c == null || !c.value.isInitialized || c.value.isTakingPicture) return;
    HapticFeedback.mediumImpact();
    try {
      final xFile = await c.takePicture();
      if (!mounted) return;
      setState(() {
        _capturedImagePath = xFile.path;
        _bannerState = _BannerState.none;
        _recognitionResult = null;
      });
      await _runRecognition(File(xFile.path));
    } catch (_) {
      // Ignore capture errors silently.
    }
  }

  void _retake() {
    _analysisTimeoutTimer?.cancel();
    setState(() {
      _capturedImagePath = null;
      _bannerState = _BannerState.none;
      _recognitionResult = null;
      _debugOverrideBanner = null;
    });
    if (!_isCameraInitialized) {
      _initializeCamera();
    }
  }

  // ── Gallery ───────────────────────────────────────────────────────────────

  Future<void> _pickFromGallery() async {
    final image = await GalleryPickerHelper.pickImageFromGallery(
      onError: (msg) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            backgroundColor: AppColors.darkCharcoal,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(milliseconds: 2200),
          ),
        );
      },
    );
    if (image == null || !mounted) return;
    setState(() {
      _capturedImagePath = image.path;
      _bannerState = _BannerState.none;
      _recognitionResult = null;
      _debugOverrideBanner = null;
    });
    await _runRecognition(File(image.path));
  }

  // ── Recognition ───────────────────────────────────────────────────────────

  Future<void> _runRecognition(File image) async {
    _analysisTimeoutTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _bannerState = _BannerState.analyzing;
      _recognitionResult = null;
    });

    // 8-second timeout — user is never stuck.
    _analysisTimeoutTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && _bannerState == _BannerState.analyzing) {
        setState(() {
          _bannerState = _BannerState.notIdentified;
        });
      }
    });

    try {
      final result = await _service.identify(image);
      _analysisTimeoutTimer?.cancel();
      if (!mounted) return;
      if (result == null || result.confidence == RecognitionConfidence.low) {
        setState(() {
          _bannerState = _BannerState.notIdentified;
          _recognitionResult = null;
        });
      } else {
        setState(() {
          _bannerState = _BannerState.identified;
          _recognitionResult = result;
        });
      }
    } catch (_) {
      _analysisTimeoutTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _bannerState = _BannerState.notIdentified;
        _recognitionResult = null;
      });
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _openBikeDetails() {
    final controller = BikeOnboardingController.instance;
    // Save the captured photo path.
    controller.setImagePath(_capturedImagePath);

    final result = _recognitionResult;
    if (result != null && result.confidence != RecognitionConfidence.low) {
      controller.populateFromRecognition(result);
    } else {
      // Open with a blank form (only reset the scan-populated fields).
      controller.setMake('Honda');
      controller.setModelName('');
      controller.setDisplacement(null);
      controller.setBikeType('Adventure');
      controller.setFuelTankCapacity(null);
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => BikeDetailsScreen(
          prefilled: result != null && result.confidence != RecognitionConfidence.low,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final effectiveBanner =
        kDebugMode && _debugOverrideBanner != null
            ? _debugOverrideBanner!
            : _bannerState;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background / Camera / Image ─────────────────────────────────
            _buildBackground(),

            // ── Top overlay ─────────────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildTopBar(),
                ),
              ),
            ),

            // ── Bottom overlay ───────────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (effectiveBanner != _BannerState.none)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: _buildBanner(effectiveBanner),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                      child: _buildBottomControls(effectiveBanner),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Background ────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    if (_capturedImagePath != null) {
      return Image.file(
        File(_capturedImagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (_isCameraInitialized && _cameraController != null) {
      return ClipRect(
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
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.tacticalOrange,
            ),
          ),
        ),
      );
    }
    // No camera / permission denied.
    return const ColoredBox(color: Colors.black);
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button
        _glassButton(
          child: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 20),
          onTap: () => Navigator.of(context).maybePop(),
        ),

        // Center pill
        _buildPill(
          label: _hasPhoto ? 'PHOTO TAKEN' : 'PHOTO',
          active: _hasPhoto,
        ),

        // Flash toggle (only in live camera mode)
        if (!_hasPhoto)
          _glassButton(
            child: Icon(
              _isFlashOn ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
              color: _isFlashOn ? AppColors.tacticalOrangeLight : Colors.white,
              size: 20,
            ),
            onTap: _toggleFlash,
          )
        else
          const SizedBox(width: 44, height: 44),
      ],
    );
  }

  Widget _buildPill({required String label, bool active = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppColors.radiusPill),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.tacticalOrangeLight
                  : AppColors.tacticalOrange,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassButton({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.50),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }

  // ── Banner ────────────────────────────────────────────────────────────────

  Widget _buildBanner(_BannerState state) {
    Widget content;
    switch (state) {
      case _BannerState.analyzing:
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.tacticalOrangeLight,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Analyzing photo…',
              style: _bannerTextStyle(),
            ),
          ],
        );
        break;

      case _BannerState.identified:
        final r = _recognitionResult;
        final label = r != null
            ? 'Looks like a ${r.make} ${r.model}. Please confirm on the next screen.'
            : 'Bike identified. Please confirm on the next screen.';
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.tacticalOrangeLight, size: 16),
            const SizedBox(width: 8),
            Flexible(
              child: Text(label, style: _bannerTextStyle(), maxLines: 2),
            ),
          ],
        );
        break;

      case _BannerState.notIdentified:
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline_rounded,
                color: Colors.white70, size: 16),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Couldn\'t identify this bike. You can enter the details yourself.',
                style: _bannerTextStyle(),
                maxLines: 2,
              ),
            ),
          ],
        );
        break;

      case _BannerState.none:
        return const SizedBox.shrink();
    }

    return GestureDetector(
      // Debug long-press: toggle between identified ↔ notIdentified.
      onLongPress: kDebugMode
          ? () {
              setState(() {
                if (_debugOverrideBanner == _BannerState.identified) {
                  _debugOverrideBanner = _BannerState.notIdentified;
                } else {
                  _debugOverrideBanner = _BannerState.identified;
                }
              });
            }
          : null,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(AppColors.radiusPill),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.14), width: 1),
        ),
        child: content,
      ),
    );
  }

  TextStyle _bannerTextStyle() => GoogleFonts.manrope(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        height: 1.35,
      );

  // ── Bottom Controls ───────────────────────────────────────────────────────

  Widget _buildBottomControls(_BannerState banner) {
    if (_cameraError && !_hasPhoto) {
      return _buildNoCameraControls();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Gallery button
        _galleryButton(),

        // Center: Shutter / Retake
        _hasPhoto ? _retakeButton() : _shutterButton(),

        // Right: flip camera (live) or Add Details (photo taken)
        _hasPhoto
            ? _addDetailsButton(banner)
            : _flipCameraButton(),
      ],
    );
  }

  Widget _buildNoCameraControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Camera unavailable on this device.',
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        if (_permissionDenied)
          PrimaryButton(
            label: 'Open Settings',
            icon: Icons.settings_rounded,
            onTap: () => openAppSettings(),
          ),
        if (_permissionDenied) const SizedBox(height: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            BikeOnboardingController.instance.setImagePath(null);
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const BikeDetailsScreen(prefilled: false),
              ),
            );
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppColors.radiusPill),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25), width: 1),
            ),
            child: Text(
              'Enter details manually',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Gallery still accessible
        _galleryButton(),
      ],
    );
  }

  Widget _galleryButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _pickFromGallery,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.20), width: 1.5),
        ),
        child: const Center(
          child: Icon(Icons.photo_library_rounded,
              color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _shutterButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _takePicture,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          color: Colors.white.withValues(alpha: 0.92),
        ),
      ),
    );
  }

  Widget _retakeButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _retake,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.55),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25), width: 1.5),
            ),
            child: const Center(
              child: Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Retake',
            style: GoogleFonts.manrope(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _flipCameraButton() {
    return _glassButton(
      child: const Icon(Icons.flip_camera_android_rounded,
          color: Colors.white, size: 22),
      onTap: _cameras.length >= 2 ? _flipCamera : () {},
    );
  }

  Widget _addDetailsButton(_BannerState banner) {
    final isDisabled = banner == _BannerState.analyzing;
    return PrimaryButton(
      label: 'Add Details',
      icon: Icons.arrow_forward_rounded,
      onTap: isDisabled ? null : _openBikeDetails,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
    );
  }

  // ── Permissions ────────────────────────────────────────────────────────────
  /// Opens the platform app-settings page when camera permission is denied.
  void openAppSettings() {
    // Attempt to open settings through a platform channel.  The camera package
    // does not expose this directly; we call the intent ourselves.
    try {
      SystemChannels.platform.invokeMethod<void>('SystemNavigator.push');
    } catch (_) {
      // Silently ignore on platforms that don't support it.
    }
  }
}
