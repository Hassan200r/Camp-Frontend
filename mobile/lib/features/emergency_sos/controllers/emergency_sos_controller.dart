import 'package:flutter/foundation.dart';
import '../domain/sos_telemetry_model.dart';

/// State Controller for CAMP Emergency SOS and Offline Safety Protocols
class EmergencySosController extends ChangeNotifier {
  EmergencySosController._();
  static final EmergencySosController instance = EmergencySosController._();

  bool _isBeaconActive = false;
  bool _isSirenActive = false;

  final List<IceContact> _contacts = <IceContact>[];
  final MedicalProfile _medicalProfile = const MedicalProfile();
  TelemetrySnapshot _telemetry = const TelemetrySnapshot();

  bool get isBeaconActive => _isBeaconActive;
  bool get isSirenActive => _isSirenActive;

  List<IceContact> get contacts => List.unmodifiable(_contacts);
  MedicalProfile get medicalProfile => _medicalProfile;
  TelemetrySnapshot get telemetry => _telemetry;

  void updateTelemetry(TelemetrySnapshot snapshot) {
    _telemetry = snapshot;
    notifyListeners();
  }

  /// Trigger emergency state
  void triggerBeacon() {
    _isBeaconActive = true;
    notifyListeners();
  }

  /// Cancel emergency state
  void cancelBeacon() {
    _isBeaconActive = false;
    notifyListeners();
  }

  /// Toggle siren audio feedback
  void toggleSirenAndStrobe() {
    _isSirenActive = !_isSirenActive;
    notifyListeners();
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
