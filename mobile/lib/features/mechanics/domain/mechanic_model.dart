import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

enum BadgeType {
  verified,
  emergency,
}

class Mechanic {
  const Mechanic({
    required this.id,
    required this.name,
    required this.distance,
    required this.durationOrLocation,
    required this.badgeType,
    required this.badgeLabel,
    required this.beaconStatus,
    required this.beaconColor,
    required this.categoryTitle1,
    required this.tags1,
    required this.categoryTitle2,
    required this.tags2,
    required this.rating,
    required this.reviewCount,
    required this.openStatus,
    String? phoneNumber,
    String? phone,
    this.address,
    this.notes,
    this.photoPath,
    this.openDays = const [],
    this.openMinutes,
    this.closeMinutes,
    this.open24Hours = false,
    this.createdAt,
    this.updatedAt,
  }) : phoneNumber = phoneNumber ?? phone;

  factory Mechanic.fromJson(Map<String, dynamic> json) {
    DateTime? parseUtc(dynamic val) {
      if (val == null) return null;
      if (val is String) return DateTime.tryParse(val)?.toUtc();
      return null;
    }

    final rawId = json['id'] as String?;
    final effectiveId = (rawId != null && rawId.trim().isNotEmpty)
        ? rawId.trim()
        : 'mechanic-${DateTime.now().millisecondsSinceEpoch}';

    final createdUtc = parseUtc(json['createdAt']) ?? DateTime.now().toUtc();
    final updatedUtc = parseUtc(json['updatedAt']) ?? createdUtc;

    final rawPhone = (json['phoneNumber'] ?? json['phone']) as String?;
    final effectivePhone =
        (rawPhone != null && rawPhone.trim().isNotEmpty) ? rawPhone.trim() : null;

    final rawBadge = json['badgeLabel'] as String? ?? 'Added by you';
    final effectiveBadge =
        rawBadge == 'Community Added' ? 'Added by you' : rawBadge;

    return Mechanic(
      id: effectiveId,
      createdAt: createdUtc,
      updatedAt: updatedUtc,
      name: json['name'] as String? ?? 'Mechanic',
      distance: json['distance'] as String? ?? 'Nearby',
      durationOrLocation: json['durationOrLocation'] as String? ?? '',
      badgeType: (json['badgeType'] as String?) == 'emergency'
          ? BadgeType.emergency
          : BadgeType.verified,
      badgeLabel: effectiveBadge,
      beaconStatus: json['beaconStatus'] as String? ?? 'Active',
      beaconColor: json['beaconColor'] != null
          ? Color(json['beaconColor'] as int)
          : AppColors.statusGreen,
      categoryTitle1: json['categoryTitle1'] as String? ?? 'SERVICES',
      tags1: (json['tags1'] as List?)?.cast<String>() ?? const [],
      categoryTitle2: json['categoryTitle2'] as String? ?? 'SPECIALTIES',
      tags2: (json['tags2'] as List?)?.cast<String>() ?? const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 1,
      openStatus: json['openStatus'] as String? ?? '',
      phoneNumber: effectivePhone,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      photoPath: (json['photoPath'] ?? json['photo']) as String?,
      openDays: (json['openDays'] as List?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      openMinutes: (json['openMinutes'] as num?)?.toInt(),
      closeMinutes: (json['closeMinutes'] as num?)?.toInt(),
      open24Hours: json['open24Hours'] as bool? ?? false,
    );
  }

  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get effectiveId => id;

  DateTime get effectiveCreatedAt =>
      createdAt?.toUtc() ?? DateTime(2024, 1, 1).toUtc();

  DateTime get effectiveUpdatedAt =>
      updatedAt?.toUtc() ?? effectiveCreatedAt;
  final String name;
  final String distance;
  final String durationOrLocation;
  final BadgeType badgeType;
  final String badgeLabel;
  final String beaconStatus;
  final Color beaconColor;
  final String categoryTitle1;
  final List<String> tags1;
  final String categoryTitle2;
  final List<String> tags2;
  final double rating;
  final int reviewCount;
  final String openStatus;
  final String? phoneNumber;

  /// Legacy accessor for backwards compatibility.
  String get phone => phoneNumber ?? '';

  final String? address;
  final String? notes;
  final String? photoPath;
  final List<int> openDays;
  final int? openMinutes;
  final int? closeMinutes;
  final bool open24Hours;

  /// Whether this shop has a valid phone number saved.
  bool get hasPhone => phoneNumber != null && phoneNumber!.trim().isNotEmpty;

  Mechanic copyWith({
    String? id,
    String? name,
    String? distance,
    String? durationOrLocation,
    BadgeType? badgeType,
    String? badgeLabel,
    String? beaconStatus,
    Color? beaconColor,
    String? categoryTitle1,
    List<String>? tags1,
    String? categoryTitle2,
    List<String>? tags2,
    double? rating,
    int? reviewCount,
    String? openStatus,
    String? phone,
    String? phoneNumber,
    String? address,
    String? notes,
    String? photoPath,
    List<int>? openDays,
    int? openMinutes,
    int? closeMinutes,
    bool? open24Hours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final effectivePhone = phoneNumber ?? phone ?? this.phoneNumber;

    return Mechanic(
      id: id ?? this.id,
      name: name ?? this.name,
      distance: distance ?? this.distance,
      durationOrLocation: durationOrLocation ?? this.durationOrLocation,
      badgeType: badgeType ?? this.badgeType,
      badgeLabel: badgeLabel ?? this.badgeLabel,
      beaconStatus: beaconStatus ?? this.beaconStatus,
      beaconColor: beaconColor ?? this.beaconColor,
      categoryTitle1: categoryTitle1 ?? this.categoryTitle1,
      tags1: tags1 ?? this.tags1,
      categoryTitle2: categoryTitle2 ?? this.categoryTitle2,
      tags2: tags2 ?? this.tags2,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      openStatus: openStatus ?? this.openStatus,
      phoneNumber: effectivePhone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      openDays: openDays ?? this.openDays,
      openMinutes: openMinutes ?? this.openMinutes,
      closeMinutes: closeMinutes ?? this.closeMinutes,
      open24Hours: open24Hours ?? this.open24Hours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': effectiveCreatedAt.toIso8601String(),
        'updatedAt': effectiveUpdatedAt.toIso8601String(),
        'name': name,
        'distance': distance,
        'durationOrLocation': durationOrLocation,
        'badgeType': badgeType.name,
        'badgeLabel': badgeLabel,
        'beaconStatus': beaconStatus,
        'beaconColor': beaconColor.toARGB32(),
        'categoryTitle1': categoryTitle1,
        'tags1': tags1,
        'categoryTitle2': categoryTitle2,
        'tags2': tags2,
        'rating': rating,
        'reviewCount': reviewCount,
        'openStatus': openStatus,
        'phoneNumber': phoneNumber,
        'phone': phoneNumber ?? '',
        'address': address,
        'notes': notes,
        'photoPath': photoPath,
        'openDays': openDays,
        'openMinutes': openMinutes,
        'closeMinutes': closeMinutes,
        'open24Hours': open24Hours,
      };

  static List<Mechanic> get sampleMechanics => [
        const Mechanic(
          id: '1',
          name: 'Peak Moto & Adventure Rig Prep',
          distance: '4.2 km away',
          durationOrLocation: '12 min',
          badgeType: BadgeType.verified,
          badgeLabel: 'CAMP Verified',
          beaconStatus: 'Active',
          beaconColor: AppColors.statusGreen,
          categoryTitle1: 'CERTIFIED PLATFORMS',
          tags1: ['BMW Motorrad', 'KTM Adventure', 'Yamaha Ténéré'],
          categoryTitle2: 'FIELD CAPABILITIES',
          tags2: [
            'Suspension Valving',
            'Carb Jetting & Altitude Re-jet',
            'Tire Machine',
          ],
          rating: 4.9,
          reviewCount: 128,
          openStatus: '',
          phoneNumber: null,
          address: '42 Timberline Rd, Pass Junction',
          openDays: [1, 2, 3, 4, 5, 6],
          openMinutes: 480, // 8:00 AM
          closeMinutes: 1140, // 7:00 PM
          open24Hours: false,
        ),
        const Mechanic(
          id: '2',
          name: 'Highland Moto Rescue & Spares',
          distance: '18.6 km away',
          durationOrLocation: 'Babusar Valley',
          badgeType: BadgeType.emergency,
          badgeLabel: 'Emergency Pitstop',
          beaconStatus: 'Remote Cache Stocked',
          beaconColor: Color(0xFF3B82F6),
          categoryTitle1: 'SUPPORTED RIGS',
          tags1: [
            'Honda Transalp',
            'Royal Enfield Himalayan',
            'Universal Adventure',
          ],
          categoryTitle2: 'FIELD CAPABILITIES',
          tags2: [
            'Emergency Welding',
            'Tread Plug & Tubes',
            'High Altitude Carburetor Tune',
          ],
          rating: 4.8,
          reviewCount: 89,
          openStatus: '',
          phoneNumber: null,
          address: 'Mile Marker 88, Babusar Valley',
          openDays: [1, 2, 3, 4, 5, 6, 7],
          open24Hours: true,
        ),
        const Mechanic(
          id: '3',
          name: 'Alpine Rally Works & Garage',
          distance: '24.1 km away',
          durationOrLocation: '35 min',
          badgeType: BadgeType.verified,
          badgeLabel: 'CAMP Verified',
          beaconStatus: 'Active',
          beaconColor: AppColors.statusGreen,
          categoryTitle1: 'CERTIFIED PLATFORMS',
          tags1: ['KTM Adventure', 'Husqvarna Norden', 'Ducati DesertX'],
          categoryTitle2: 'FIELD CAPABILITIES',
          tags2: [
            'Electrical & Stator Check',
            'Spoke Lacing & Truing',
            'Hydraulic Clutch Bleed',
          ],
          rating: 4.95,
          reviewCount: 204,
          openStatus: '',
          phoneNumber: null,
          address: '104 Alpine Loop Hwy',
          openDays: [1, 2, 3, 4, 5],
          openMinutes: 510, // 8:30 AM
          closeMinutes: 1110, // 6:30 PM
          open24Hours: false,
        ),
      ];
}
