/// Emergency Contact (In Case of Emergency)
class IceContact {
  const IceContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    required this.dispatchBadge,
    required this.initials,
  });

  final String id;
  final String name;
  final String relationship;
  final String phone;
  final String dispatchBadge;
  final String initials;

  static const List<IceContact> defaultContacts = [];
}

/// Offline First Responder Medical Profile
class MedicalProfile {
  const MedicalProfile({
    this.bloodType = '',
    this.allergies = '',
    this.touringNotes = '',
    this.donorStatus = '',
  });

  final String bloodType;
  final String allergies;
  final String touringNotes;
  final String donorStatus;
}

/// Telemetry Fix & Stream Snapshot from Phone Sensors
class TelemetrySnapshot {
  const TelemetrySnapshot({
    this.coordinates = 'Waiting for GPS fix...',
    this.locationName = 'Locating...',
    this.elevation = '--',
    this.accuracy = '--',
    this.bikeModel = 'Motorcycle',
    this.speed = '0 km/h',
  });

  final String coordinates;
  final String locationName;
  final String elevation;
  final String accuracy;
  final String bikeModel;
  final String speed;
}
