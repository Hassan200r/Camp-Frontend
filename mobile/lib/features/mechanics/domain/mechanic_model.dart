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
    required this.phone,
    this.address,
    this.notes,
  });

  factory Mechanic.fromJson(Map<String, dynamic> json) {
    return Mechanic(
      id: json['id'] as String? ?? '0',
      name: json['name'] as String? ?? 'Mechanic',
      distance: json['distance'] as String? ?? 'Nearby',
      durationOrLocation: json['durationOrLocation'] as String? ?? '',
      badgeType: (json['badgeType'] as String?) == 'emergency'
          ? BadgeType.emergency
          : BadgeType.verified,
      badgeLabel: json['badgeLabel'] as String? ?? 'Verified Shop',
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
      openStatus: json['openStatus'] as String? ?? 'OPEN NOW',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String?,
      notes: json['notes'] as String?,
    );
  }

  final String id;
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
  final String phone;
  final String? address;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'id': id,
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
        'phone': phone,
        'address': address,
        'notes': notes,
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
          openStatus: 'OPEN NOW (Closes 7:00 PM)',
          phone: '+1 (555) 482-9921',
          address: '42 Timberline Rd, Pass Junction',
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
          openStatus: 'OPEN NOW (Closes 9:00 PM)',
          phone: '+1 (555) 832-1049',
          address: 'Mile Marker 88, Babusar Valley',
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
          openStatus: 'OPEN NOW (Closes 6:30 PM)',
          phone: '+1 (555) 671-8842',
          address: '104 Alpine Loop Hwy',
        ),
      ];
}
