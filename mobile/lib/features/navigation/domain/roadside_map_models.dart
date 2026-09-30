import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum BreakdownSeverity {
  critical,
  high,
  moderate,
}

enum BreakdownCategory {
  flatTire,
  deadBattery,
  engineFailure,
  brokenChain,
  outOfFuel,
  towingRecovery,
}

class StrandedIncident {

  const StrandedIncident({
    required this.id,
    required this.driverName,
    required this.vehicleModel,
    required this.category,
    required this.severity,
    required this.issueDescription,
    required this.location,
    required this.distance,
    required this.eta,
    required this.phone,
    required this.timeReported,
    this.isUserReported = false,
  });
  final String id;
  final String driverName;
  final String vehicleModel;
  final BreakdownCategory category;
  final BreakdownSeverity severity;
  final String issueDescription;
  final LatLng location;
  final String distance;
  final String eta;
  final String phone;
  final String timeReported;
  final bool isUserReported;

  String get categoryLabel {
    switch (category) {
      case BreakdownCategory.flatTire:
        return 'Flat Tire / Bead Loss';
      case BreakdownCategory.deadBattery:
        return 'Dead Battery / No Crank';
      case BreakdownCategory.engineFailure:
        return 'Engine / Overheating';
      case BreakdownCategory.brokenChain:
        return 'Snapped Chain / Drive';
      case BreakdownCategory.outOfFuel:
        return 'Fuel Starvation / Dry';
      case BreakdownCategory.towingRecovery:
        return 'Ravine / Tow Recovery';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case BreakdownCategory.flatTire:
        return Icons.tire_repair_rounded;
      case BreakdownCategory.deadBattery:
        return Icons.battery_alert_rounded;
      case BreakdownCategory.engineFailure:
        return Icons.warning_rounded;
      case BreakdownCategory.brokenChain:
        return Icons.link_off_rounded;
      case BreakdownCategory.outOfFuel:
        return Icons.local_gas_station_rounded;
      case BreakdownCategory.towingRecovery:
        return Icons.car_crash_rounded;
    }
  }

  Color get severityColor {
    switch (severity) {
      case BreakdownSeverity.critical:
        return const Color(0xFFEF4444);
      case BreakdownSeverity.high:
        return const Color(0xFFF97316);
      case BreakdownSeverity.moderate:
        return const Color(0xFFFBBF24);
    }
  }
}

class RoadsideMechanic {

  const RoadsideMechanic({
    required this.id,
    required this.name,
    required this.vehicleType,
    required this.distance,
    required this.eta,
    required this.rating,
    required this.reviews,
    required this.phone,
    required this.location,
    required this.isMobileVan,
    required this.isEmergencyVerified,
    required this.capabilities,
    required this.supportedBikes,
    required this.openHours,
  });
  final String id;
  final String name;
  final String vehicleType;
  final String distance;
  final String eta;
  final double rating;
  final int reviews;
  final String phone;
  final LatLng location;
  final bool isMobileVan;
  final bool isEmergencyVerified;
  final List<String> capabilities;
  final List<String> supportedBikes;
  final String openHours;
}

class RoadsideSupplyCache {

  const RoadsideSupplyCache({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.location,
    required this.fuelTypes,
    required this.availableTools,
    this.hasCompressor = true,
  });
  final String id;
  final String name;
  final String subtitle;
  final LatLng location;
  final String fuelTypes;
  final List<String> availableTools;
  final bool hasCompressor;
}

class RoadsideSectorDataset {

  const RoadsideSectorDataset({
    required this.mechanics,
    required this.strandedIncidents,
    required this.supplyCaches,
    required this.primaryRescueRoute,
  });
  final List<RoadsideMechanic> mechanics;
  final List<StrandedIncident> strandedIncidents;
  final List<RoadsideSupplyCache> supplyCaches;
  final List<LatLng> primaryRescueRoute;

  /// Dynamically computes realistic mechanics, stranded vehicles, and emergency rescue routes around ANY target coordinate!
  static RoadsideSectorDataset generate(LatLng center, String sectorName) {
    // 1. Mobile Rescuers & Certified Garages
    final mechanics = [
      RoadsideMechanic(
        id: 'mech-1',
        name: 'Highland Mobile Rescue & Spares',
        vehicleType: 'Heavy 4x4 Support Rig & Mobile Pit',
        distance: '3.4 km away',
        eta: '8 min response',
        rating: 4.9,
        reviews: 142,
        phone: '+1 (555) 832-1049',
        location: LatLng(center.latitude - 0.038, center.longitude - 0.052),
        isMobileVan: true,
        isEmergencyVerified: true,
        capabilities: [
          'Tire Plug & Tube Change',
          'Battery Boost 12V',
          'Field TIG Welding',
          'High-Altitude Carb Tuning',
        ],
        supportedBikes: ['KTM Adventure', 'BMW GS', 'Honda Transalp', 'Yamaha'],
        openHours: '24/7 EMERGENCY DISPATCH',
      ),
      RoadsideMechanic(
        id: 'mech-2',
        name: 'Peak Moto Workshop & Recovery Base',
        vehicleType: 'Permanent Service Center & Tow Rig',
        distance: '6.8 km away',
        eta: '15 min response',
        rating: 4.8,
        reviews: 98,
        phone: '+1 (555) 482-9921',
        location: LatLng(center.latitude + 0.042, center.longitude + 0.065),
        isMobileVan: false,
        isEmergencyVerified: true,
        capabilities: [
          'Hydraulic Tire Changer',
          'Diagnostic Computer Tool',
          'Flatbed Motorcycle Tow',
          'Clutch & Brake Hydraulics',
        ],
        supportedBikes: ['All Dual Sports', 'Ducati DesertX', 'Royal Enfield'],
        openHours: 'OPEN NOW (Closes 9:00 PM)',
      ),
      RoadsideMechanic(
        id: 'mech-3',
        name: 'Apex Rapid-Response Dual-Sport Tech',
        vehicleType: 'Enduro Fast-Response Motorcycle',
        distance: '1.9 km away',
        eta: '5 min response',
        rating: 5.0,
        reviews: 56,
        phone: '+1 (555) 291-7443',
        location: LatLng(center.latitude + 0.018, center.longitude - 0.032),
        isMobileVan: true,
        isEmergencyVerified: true,
        capabilities: [
          'Puncture Quick Fix',
          'Cable & Chain Master Links',
          'Fuel Transfer Canister',
          'Handlebar & Lever Straightening',
        ],
        supportedBikes: ['Universal Single & Twin Cylinders'],
        openHours: 'ACTIVE ON PATROL',
      ),
    ];

    // 2. Active Stranded Drivers (SOS Beacons)
    final strandedIncidents = [
      StrandedIncident(
        id: 'sos-1',
        driverName: 'Alex Vance',
        vehicleModel: 'KTM 890 Adventure R',
        category: BreakdownCategory.flatTire,
        severity: BreakdownSeverity.high,
        issueDescription:
            'Front 21" tire punctured on sharp shale rock. Valve stem torn. Carrying spare tube but lacks bead breaker.',
        location: LatLng(center.latitude + 0.024, center.longitude + 0.018),
        distance: '2.1 km away',
        eta: '6 min drive',
        phone: '+1 (555) 392-8172',
        timeReported: '14 min ago',
      ),
      StrandedIncident(
        id: 'sos-2',
        driverName: 'Marcus Cole',
        vehicleModel: 'BMW R1250GS Trophy',
        category: BreakdownCategory.deadBattery,
        severity: BreakdownSeverity.critical,
        issueDescription:
            'Stopped at high overlook, ignition click only. Battery reading 10.1V. Needs jump starter or replacement lithium pack.',
        location: LatLng(center.latitude - 0.026, center.longitude + 0.042),
        distance: '4.8 km away',
        eta: '11 min drive',
        phone: '+1 (555) 604-1934',
        timeReported: '28 min ago',
      ),
      StrandedIncident(
        id: 'sos-3',
        driverName: 'Elena Rostova',
        vehicleModel: 'Yamaha Ténéré 700 Rally',
        category: BreakdownCategory.brokenChain,
        severity: BreakdownSeverity.moderate,
        issueDescription:
            'Drive chain snapped at creek exit. Chain gathered on swingarm. Requires 525 O-ring master link and rivet press tool.',
        location: LatLng(center.latitude + 0.051, center.longitude - 0.045),
        distance: '7.5 km away',
        eta: '18 min drive',
        phone: '+1 (555) 718-4420',
        timeReported: '45 min ago',
      ),
    ];

    // 3. 24/7 Roadside Supply & Tools Depots
    final supplyCaches = [
      RoadsideSupplyCache(
        id: 'cache-1',
        name: 'Pass 91-Octane & Spares Depot',
        subtitle: '24/7 High-Altitude Pitstop • MP 42',
        location: LatLng(center.latitude - 0.012, center.longitude - 0.008),
        fuelTypes: '91 Octane Non-Ethanol, Diesel, Water',
        availableTools: [
          'Compressed Air (120 psi)',
          'Metric Socket Set',
          'Heavy-Duty Tube Patch Kits',
          '10W-50 Synthetic Oil',
        ],
      ),
      RoadsideSupplyCache(
        id: 'cache-2',
        name: 'Alpine Ridge Emergency Tool Chest',
        subtitle: 'Community Trail Box • VHF Ch 4',
        location: LatLng(center.latitude + 0.038, center.longitude + 0.048),
        fuelTypes: 'Emergency 1-Gal Canisters only',
        availableTools: [
          'Tire Spoons & Bead Buddy',
          'Tow Strap (20ft 10,000 lbs)',
          'First Aid Trauma Kit',
        ],
      ),
    ];

    // 4. Primary Rescue Route connecting nearest mechanic (mech-1) -> user/stranded incident (sos-1)
    final mLoc = mechanics[0].location;
    final sLoc = strandedIncidents[0].location;
    final primaryRoute = [
      mLoc,
      LatLng(mLoc.latitude + (sLoc.latitude - mLoc.latitude) * 0.25,
          mLoc.longitude + (sLoc.longitude - mLoc.longitude) * 0.15),
      LatLng(mLoc.latitude + (sLoc.latitude - mLoc.latitude) * 0.45,
          mLoc.longitude + (sLoc.longitude - mLoc.longitude) * 0.40),
      LatLng(mLoc.latitude + (sLoc.latitude - mLoc.latitude) * 0.65,
          mLoc.longitude + (sLoc.longitude - mLoc.longitude) * 0.55),
      LatLng(mLoc.latitude + (sLoc.latitude - mLoc.latitude) * 0.85,
          mLoc.longitude + (sLoc.longitude - mLoc.longitude) * 0.80),
      sLoc,
    ];

    return RoadsideSectorDataset(
      mechanics: mechanics,
      strandedIncidents: strandedIncidents,
      supplyCaches: supplyCaches,
      primaryRescueRoute: primaryRoute,
    );
  }
}
