import 'package:url_launcher/url_launcher.dart';

import '../../navigation/domain/location_service.dart';

/// Pre-configured emergency response service options (Pakistan standard).
class EmergencyServiceOption {
  const EmergencyServiceOption({
    required this.number,
    required this.label,
    required this.description,
  });

  final String number;
  final String label;
  final String description;
}

const List<EmergencyServiceOption> kEmergencyServiceOptions = [
  EmergencyServiceOption(
    number: '1122',
    label: '1122 Rescue',
    description: 'Pakistan Rescue 1122 (Disaster & Medical)',
  ),
  EmergencyServiceOption(
    number: '15',
    label: '15 Police',
    description: 'Police Assistance Helpline',
  ),
  EmergencyServiceOption(
    number: '115',
    label: '115 Ambulance',
    description: 'Ambulance Emergency Dispatch',
  ),
];

/// Helper to build honest emergency SMS body with Google Maps coordinate link if GPS fix is available.
String buildEmergencySmsBody(PositionData? position) {
  if (position != null) {
    return 'I need help. My location: https://www.google.com/maps?q=${position.latitude},${position.longitude}';
  } else {
    return 'I need help. My location: location not available yet';
  }
}

/// Opens the device dialer with `tel:<number>`.
Future<bool> launchTel(String number) async {
  final cleanNumber = number.trim();
  final uri = Uri(scheme: 'tel', path: cleanNumber);
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

/// Opens the SMS composer with `sms:<number>?body=...` prefilled.
Future<bool> launchSms(String number, String body) async {
  final cleanNumber = number.trim();
  final uri = Uri(
    scheme: 'sms',
    path: cleanNumber,
    queryParameters: {'body': body},
  );
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
