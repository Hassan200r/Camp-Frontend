/// CAMP Rider User Model
class RiderUser {
  const RiderUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.callSign = 'Ghost Rider',
    this.helmetTokenId = 'CAMP-OBD-9842',
    this.telemetryActive = true,
    this.biometricEnabled = true,
    this.memberSince,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String callSign;
  final String helmetTokenId;
  final bool telemetryActive;
  final bool biometricEnabled;
  final DateTime? memberSince;

  /// Default mock rider matching the screenshot mockup
  static RiderUser defaultRider = RiderUser(
    id: 'RIDER-441-MX',
    name: 'Alex Henderson',
    email: 'moto.rider@camp.io',
    phone: '+1 (555) 019–2834',
    callSign: 'Apex Navigator',
    helmetTokenId: 'TOKEN-SCHUBERTH-C5',
    telemetryActive: true,
    biometricEnabled: true,
    memberSince: DateTime(2024, 3, 15),
  );

  RiderUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? callSign,
    String? helmetTokenId,
    bool? telemetryActive,
    bool? biometricEnabled,
    DateTime? memberSince,
  }) {
    return RiderUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      callSign: callSign ?? this.callSign,
      helmetTokenId: helmetTokenId ?? this.helmetTokenId,
      telemetryActive: telemetryActive ?? this.telemetryActive,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}
