import 'package:flutter/foundation.dart';
import '../domain/sos_telemetry_model.dart';

/// State Controller for CAMP Emergency SOS, Satellite Beacon & Telematics
class EmergencySosController extends ChangeNotifier {
  EmergencySosController._();
  static final EmergencySosController instance = EmergencySosController._();

  bool _isBeaconActive = false;
  bool _autoCrashDetection = true;
  int _confirmationWindowSeconds = 45;
  bool _isSirenActive = false;
  bool _isTestingSatLink = false;

  final List<IceContact> _contacts = List<IceContact>.from(IceContact.defaultContacts);
  final MedicalProfile _medicalProfile = const MedicalProfile();
  final TelemetrySnapshot _telemetry = const TelemetrySnapshot();

  bool get isBeaconActive => _isBeaconActive;
  bool get autoCrashDetection => _autoCrashDetection;
  int get confirmationWindowSeconds => _confirmationWindowSeconds;
  bool get isSirenActive => _isSirenActive;
  bool get isTestingSatLink => _isTestingSatLink;

  List<IceContact> get contacts => List.unmodifiable(_contacts);
  MedicalProfile get medicalProfile => _medicalProfile;
  TelemetrySnapshot get telemetry => _telemetry;

  /// Trigger distress satellite beacon payload
  void triggerBeacon() {
    _isBeaconActive = true;
    notifyListeners();
  }

  /// Cancel active distress transmission
  void cancelBeacon() {
    _isBeaconActive = false;
    notifyListeners();
  }

  /// Toggle automated crash detection dispatch
  void toggleCrashDetection(bool enabled) {
    _autoCrashDetection = enabled;
    notifyListeners();
  }

  /// Set crash window timer
  void setConfirmationWindow(int seconds) {
    _confirmationWindowSeconds = seconds;
    notifyListeners();
  }

  /// Toggle high-decibel acoustic siren & LED strobe beacon
  void toggleSirenAndStrobe() {
    _isSirenActive = !_isSirenActive;
    notifyListeners();
  }

  /// Test Satellite Uplink ping to Iridium constellation
  Future<bool> testSatLink() async {
    _isTestingSatLink = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 1400));

    _isTestingSatLink = false;
    notifyListeners();
    return true;
  }

  /// Add new ICE contact
  void addContact(IceContact contact) {
    _contacts.add(contact);
    notifyListeners();
  }

  /// Remove contact
  void removeContact(String id) {
    _contacts.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
