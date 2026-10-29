/// CAMP Rider User Model representing an authenticated rider profile.
class RiderUser {
  /// Creates an immutable rider user instance.
  const RiderUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.callSign = 'Ghost Rider',
    this.telemetryActive = true,
    this.biometricEnabled = true,
    this.memberSince,
  });

  /// Unique rider identifier.
  final String id;

  /// Full display name of the rider.
  final String name;

  /// Contact email address.
  final String email;

  /// Contact telephone number.
  final String phone;

  /// Radio/community call sign handle.
  final String callSign;

  /// Whether offline telemetry logging is active.
  final bool telemetryActive;

  /// Whether biometric sign-in is supported/enabled.
  final bool biometricEnabled;

  /// Registration date of the rider account.
  final DateTime? memberSince;

  /// Default baseline rider profile.
  static RiderUser defaultRider = RiderUser(
    id: 'RIDER-441-MX',
    name: 'Alex Henderson',
    email: 'moto.rider@example.com',
    phone: '+1 (555) 019–2834',
    callSign: 'Apex Navigator',
    telemetryActive: true,
    biometricEnabled: true,
    memberSince: DateTime(2024, 3, 15),
  );

  /// Creates a copy of this rider with updated fields.
  RiderUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? callSign,
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
      telemetryActive: telemetryActive ?? this.telemetryActive,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}
