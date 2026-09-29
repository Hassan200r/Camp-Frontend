/// Emergency Contact (In Case of Emergency)
class IceContact {
  const IceContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    required this.dispatchBadge,
    required this.initials,
    this.isVhf = false,
  });

  final String id;
  final String name;
  final String relationship;
  final String phone;
  final String dispatchBadge;
  final String initials;
  final bool isVhf;

  static const List<IceContact> defaultContacts = [
    IceContact(
      id: 'ice-1',
      name: 'Sarah Henderson',
      relationship: 'Spouse',
      phone: '+1 (555) 019-4821',
      dispatchBadge: 'SMS + Sat',
      initials: 'SH',
      isVhf: false,
    ),
    IceContact(
      id: 'ice-2',
      name: 'Karakoram Rescue Dispatch',
      relationship: 'Emergency Authority',
      phone: '+92 5811 920-HELP',
      dispatchBadge: 'Direct VHF/Sat',
      initials: 'KM',
      isVhf: true,
    ),
  ];
}

/// Offline First Responder Medical Profile
class MedicalProfile {
  const MedicalProfile({
    this.bloodType = 'O+ POS',
    this.allergies = 'Penicillin / Amoxicillin',
    this.touringNotes = 'Adventure Enduro Rider • Organ Donor • Titanium Rod in Left Tibia (2021).',
    this.donorStatus = 'Organ Donor',
  });

  final String bloodType;
  final String allergies;
  final String touringNotes;
  final String donorStatus;
}

/// Telemetry Fix & Stream Snapshot
class TelemetrySnapshot {
  const TelemetrySnapshot({
    this.coordinates = '35°21\'44.2"N 74°05\'12.8"E',
    this.locationName = 'Babusar Pass Summit',
    this.elevation = '4,173m',
    this.accuracy = '±1.2m',
    this.imuStatus = 'ARMED',
    this.gForce = '0.02G',
    this.leanAngle = '0°',
    this.bikeModel = 'BMW R 1250 GS',
    this.ignitionState = 'ON',
    this.speed = '0 km/h',
    this.heartRateBpm = 78,
    this.bodyTempCelsius = 36.8,
  });

  final String coordinates;
  final String locationName;
  final String elevation;
  final String accuracy;
  final String imuStatus;
  final String gForce;
  final String leanAngle;
  final String bikeModel;
  final String ignitionState;
  final String speed;
  final int heartRateBpm;
  final double bodyTempCelsius;
}
