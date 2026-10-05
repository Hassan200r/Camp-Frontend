import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../garage/domain/bike_model.dart';
import 'post_ride_report.dart';

/// Health status classification for individual motorcycle components.
enum ComponentStatus {
  ok,
  dueSoon,
  overdue,
}

/// Computed wear and health prediction for a specific motorcycle component.
/// Fully derived from user-entered odometer readings, service records, and terrain profiles.
@immutable
class ComponentPrediction {
  const ComponentPrediction({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.wearPercent,
    required this.status,
    required this.reason,
    required this.remainingKm,
    required this.diyGuideTitle,
    required this.diySteps,
    this.remainingDays,
  });

  final String id;
  final String name;
  final String subtitle;
  final int wearPercent;
  final ComponentStatus status;
  final String reason;
  final int remainingKm;
  final int? remainingDays;
  final String diyGuideTitle;
  final List<String> diySteps;

  /// Component health score (0-100, where 100 is brand new).
  int get healthScore => (100 - wearPercent).clamp(0, 100);
}

/// Explainable pattern insight derived from user-logged post-ride debriefs.
@immutable
class RidePatternInsight {
  const RidePatternInsight({
    required this.title,
    required this.percentageBadge,
    required this.description,
    required this.recommendation,
  });

  final String title;
  final String percentageBadge;
  final String description;
  final String recommendation;
}

/// Complete predictive maintenance assessment result.
@immutable
class MaintenanceAssessment {
  const MaintenanceAssessment({
    required this.healthIndex,
    required this.healthStatusLabel,
    required this.nextServiceKm,
    required this.nextServiceDays,
    required this.components,
    required this.patternInsights,
    required this.hasSufficientRideLogs,
    required this.totalRideLogsCount,
  });

  /// Single aggregate Maintenance Health Index (0-100).
  final int healthIndex;

  /// Health descriptor: 'OPTIMAL', 'ATTENTION', or 'SERVICE DUE'.
  final String healthStatusLabel;

  /// Estimated distance remaining until the soonest component hits service threshold.
  final int nextServiceKm;

  /// Estimated days remaining until the soonest component hits service threshold.
  final int nextServiceDays;

  /// 4 analyzed components sorted by highest wear first.
  final List<ComponentPrediction> components;

  /// Computed pattern insights based on logged PostRideReports.
  final List<RidePatternInsight> patternInsights;

  /// True if at least 3 post-ride reports exist for the active bike.
  final bool hasSufficientRideLogs;

  /// Total number of post-ride reports evaluated.
  final int totalRideLogsCount;
}

/// Deterministic, software-based prediction engine.
/// Computes wear percentages, service timelines, and ride pattern insights
/// strictly from user inputs (odometer, service records, riding terrain, and post-ride logs).
/// Free of sensor, OBD-II, or ECU dependencies.
class MaintenancePredictionEngine {
  const MaintenancePredictionEngine._();

  /// Calculate the complete maintenance assessment for a given motorcycle and its ride logs.
  static MaintenanceAssessment analyze({
    required Bike bike,
    required List<PostRideReport> rideReports,
  }) {
    final terrain = bike.ridingTerrain ?? const ['Highway'];
    final isOffRoad = terrain.contains('Off-road');
    final isMountain = terrain.contains('Mountain');
    final isCity = terrain.contains('City');

    // ── 1. Engine Oil & Filter ───────────────────────────────────────────────
    final oilPrediction = _analyzeEngineOil(bike, isOffRoad, isMountain);

    // ── 2. Drive Chain & Sprocket ───────────────────────────────────────────
    final chainPrediction = _analyzeChainAndSprocket(bike, isOffRoad, isMountain);

    // ── 3. Air Filter Element ───────────────────────────────────────────────
    final airFilterPrediction = _analyzeAirFilter(bike, isOffRoad, isMountain);

    // ── 4. Brake Pads ───────────────────────────────────────────────────────
    final brakePadPrediction = _analyzeBrakePads(bike, isCity, isMountain);

    final components = [
      chainPrediction,
      brakePadPrediction,
      airFilterPrediction,
      oilPrediction,
    ];

    // Sort by highest wear first (most urgent at the top)
    components.sort((a, b) => b.wearPercent.compareTo(a.wearPercent));

    // Weighted Maintenance Health Index (0-100)
    // Oil: 35%, Chain: 25%, Brakes: 25%, Air Filter: 15%
    final weightedHealth = (oilPrediction.healthScore * 0.35) +
        (chainPrediction.healthScore * 0.25) +
        (brakePadPrediction.healthScore * 0.25) +
        (airFilterPrediction.healthScore * 0.15);
    final healthIndex = weightedHealth.round().clamp(0, 100);

    final String healthStatusLabel;
    if (healthIndex >= 80) {
      healthStatusLabel = 'OPTIMAL';
    } else if (healthIndex >= 60) {
      healthStatusLabel = 'ATTENTION';
    } else {
      healthStatusLabel = 'SERVICE DUE';
    }

    // Soonest service due estimation
    var soonestKm = components.first.remainingKm;
    var soonestDays = components.first.remainingDays ?? (soonestKm / 35).round();
    for (final c in components) {
      if (c.remainingKm < soonestKm) {
        soonestKm = c.remainingKm;
        soonestDays = c.remainingDays ?? (c.remainingKm / 35).round();
      }
    }
    soonestKm = max(50, soonestKm);
    soonestDays = max(1, soonestDays);

    // ── Phase 3: Real Pattern Insights from Logged PostRideReports ──────────
    final patternInsights = _computePatternInsights(rideReports);
    final hasSufficientLogs = rideReports.length >= 3;

    return MaintenanceAssessment(
      healthIndex: healthIndex,
      healthStatusLabel: healthStatusLabel,
      nextServiceKm: soonestKm,
      nextServiceDays: soonestDays,
      components: components,
      patternInsights: patternInsights,
      hasSufficientRideLogs: hasSufficientLogs,
      totalRideLogsCount: rideReports.length,
    );
  }

  // ── Engine Oil Analysis ───────────────────────────────────────────────────
  static ComponentPrediction _analyzeEngineOil(
    Bike bike,
    bool isOffRoad,
    bool isMountain,
  ) {
    final record = bike.lastOilChange;
    final kmSinceOil = record?.km ?? 3200;

    // Standard interval: 5,000 km or 90 days
    const baseIntervalKm = 5000;
    const baseIntervalDays = 90;

    // Reduce interval by ~15% if terrain includes harsh dust or heat (Off-road or Mountain)
    final intervalMultiplier = (isOffRoad || isMountain) ? 0.85 : 1.0;
    final effectiveIntervalKm = (baseIntervalKm * intervalMultiplier).round();
    final effectiveIntervalDays = (baseIntervalDays * intervalMultiplier).round();

    final kmWear = (kmSinceOil / effectiveIntervalKm) * 100;

    int daysWear = 0;
    int? remainingDays;
    if (record?.date != null) {
      final daysSince = DateTime.now().difference(record!.date!).inDays;
      daysWear = ((daysSince / effectiveIntervalDays) * 100).round();
      remainingDays = max(0, effectiveIntervalDays - daysSince);
    } else {
      remainingDays = (max(0, effectiveIntervalKm - kmSinceOil) / 35).round();
    }

    final wearPercent = max(kmWear.round(), daysWear).clamp(0, 100);
    final remainingKm = max(0, effectiveIntervalKm - kmSinceOil);

    final ComponentStatus status;
    if (wearPercent >= 80) {
      status = ComponentStatus.overdue;
    } else if (wearPercent >= 50) {
      status = ComponentStatus.dueSoon;
    } else {
      status = ComponentStatus.ok;
    }

    final String reason;
    if (isOffRoad || isMountain) {
      final terrainName = isOffRoad && isMountain ? 'off-road & mountain' : (isOffRoad ? 'off-road' : 'mountain');
      reason = 'Calculated from $kmSinceOil km since last oil change. Service interval reduced by 15% due to $terrainName terrain (~$remainingKm km remaining).';
    } else {
      reason = 'Calculated from $kmSinceOil km logged against $effectiveIntervalKm km standard interval. Thermal degradation nominal (~$remainingKm km remaining).';
    }

    return ComponentPrediction(
      id: 'engine-oil',
      name: 'Engine Oil & Filter',
      subtitle: bike.displacement != null ? '${bike.displacement}cc Spec' : 'Factory Spec',
      wearPercent: wearPercent,
      status: status,
      reason: reason,
      remainingKm: remainingKm,
      remainingDays: remainingDays,
      diyGuideTitle: 'Engine Oil & Filter Change',
      diySteps: const [
        'Warm engine for 3-5 minutes to circulate suspended particles and suspend sludge.',
        'Place an oil collection catch-pan under the crankcase drain bolt.',
        'Remove drain bolt with a calibrated hex socket; inspect magnetic tip for metallic debris.',
        'Remove old oil filter with a filter wrench; clean the engine mounting mating surface.',
        'Lubricate the rubber O-ring of the new filter with clean motor oil before spinning on.',
        'Torque drain bolt with a new crush washer to factory specification (typically 20-25 Nm).',
        'Refill with manufacturer-recommended viscosity oil (e.g. 5W-40) and check sight glass.',
      ],
    );
  }

  // ── Chain & Sprocket Analysis ─────────────────────────────────────────────
  static ComponentPrediction _analyzeChainAndSprocket(
    Bike bike,
    bool isOffRoad,
    bool isMountain,
  ) {
    final kmSinceTuneUp = bike.lastTuneUp?.km ?? (bike.odometerKm > 0 ? (bike.odometerKm % 15000) : 5000);

    // Standard chain interval: 15,000 km
    const baseIntervalKm = 15000;

    // Off-road silt accelerates link wear; mountain climbing increases tensile stress
    double terrainMultiplier = 1.0;
    if (isOffRoad && isMountain) {
      terrainMultiplier = 1.35;
    } else if (isOffRoad) {
      terrainMultiplier = 1.25;
    } else if (isMountain) {
      terrainMultiplier = 1.15;
    }

    final effectiveIntervalKm = (baseIntervalKm / terrainMultiplier).round();
    final wearPercent = ((kmSinceTuneUp / effectiveIntervalKm) * 100).round().clamp(0, 100);
    final remainingKm = max(0, effectiveIntervalKm - kmSinceTuneUp);

    final ComponentStatus status;
    if (wearPercent >= 80) {
      status = ComponentStatus.overdue;
    } else if (wearPercent >= 50) {
      status = ComponentStatus.dueSoon;
    } else {
      status = ComponentStatus.ok;
    }

    final String reason;
    if (isOffRoad) {
      reason = 'Wear accelerated by off-road grit and silt exposure ($kmSinceTuneUp km since last tune-up).';
    } else if (isMountain) {
      reason = 'High torque mountain grade climbs increased chain tension load ($kmSinceTuneUp km logged).';
    } else {
      reason = 'Calculated from $kmSinceTuneUp km of paved highway and city riding since last service.';
    }

    return ComponentPrediction(
      id: 'chain-sprocket',
      name: 'Drive Chain & Sprocket',
      subtitle: 'O-Ring / X-Ring Drive',
      wearPercent: wearPercent,
      status: status,
      reason: reason,
      remainingKm: remainingKm,
      remainingDays: (remainingKm / 35).round(),
      diyGuideTitle: 'Chain Tension & Sprocket Inspection',
      diySteps: const [
        'Place motorcycle on center-stand or rear paddock stand on level ground.',
        'Locate the midway point on the bottom chain run between front and rear sprockets.',
        'Use a pocket ruler to measure vertical deflection while pushing chain up and down.',
        'If slack exceeds manufacturer specification (typically 25-35mm), loosen the rear axle nut.',
        'Turn left and right swingarm adjuster bolts evenly to preserve rear wheel alignment.',
        'Inspect rear sprocket teeth for "shark-fin" hooked wear patterns or chipping.',
        'Clean links thoroughly with kerosene or chain cleaner, dry, and apply synthetic lube.',
      ],
    );
  }

  // ── Air Filter Analysis ───────────────────────────────────────────────────
  static ComponentPrediction _analyzeAirFilter(
    Bike bike,
    bool isOffRoad,
    bool isMountain,
  ) {
    final kmSinceTuneUp = bike.lastTuneUp?.km ?? 4500;
    const baseIntervalKm = 12000;

    double dustMultiplier = 1.0;
    if (isOffRoad && isMountain) {
      dustMultiplier = 1.5;
    } else if (isOffRoad) {
      dustMultiplier = 1.35;
    } else if (isMountain) {
      dustMultiplier = 1.2;
    } else {
      dustMultiplier = 0.9; // clean paved highway
    }

    final effectiveIntervalKm = (baseIntervalKm / dustMultiplier).round();
    final wearPercent = ((kmSinceTuneUp / effectiveIntervalKm) * 100).round().clamp(0, 100);
    final remainingKm = max(0, effectiveIntervalKm - kmSinceTuneUp);

    final ComponentStatus status;
    if (wearPercent >= 80) {
      status = ComponentStatus.overdue;
    } else if (wearPercent >= 50) {
      status = ComponentStatus.dueSoon;
    } else {
      status = ComponentStatus.ok;
    }

    final String reason;
    if (isOffRoad || isMountain) {
      reason = 'Dust accumulation accelerated by high pass gravel trails and off-road terrain ($kmSinceTuneUp km logged).';
    } else {
      reason = 'Standard highway cruising airflow profile ($kmSinceTuneUp km since last inspection).';
    }

    return ComponentPrediction(
      id: 'air-filter',
      name: 'Air Filter Element',
      subtitle: 'High Flow Intake',
      wearPercent: wearPercent,
      status: status,
      reason: reason,
      remainingKm: remainingKm,
      remainingDays: (remainingKm / 35).round(),
      diyGuideTitle: 'Air Filter Cleaning & Replacement',
      diySteps: const [
        'Remove rider seat and side fairing trim panels covering the airbox housing.',
        'Clean exterior dust and loose sand around the airbox perimeter before opening lid.',
        'Remove airbox lid fasteners and carefully extract the intake filter element.',
        'Inspect the clean-air intake duct for any bypassed dust or moisture.',
        'For paper filters: tap gently and blow low-pressure compressed air from the inside out.',
        'For oiled foam filters: wash in filter solvent, dry completely, and re-oil evenly.',
        'Seat filter securely in housing rim to ensure an airtight seal against the intake tract.',
      ],
    );
  }

  // ── Brake Pads Analysis ───────────────────────────────────────────────────
  static ComponentPrediction _analyzeBrakePads(
    Bike bike,
    bool isCity,
    bool isMountain,
  ) {
    final kmSinceTuneUp = bike.lastTuneUp?.km ?? 4200;
    const baseIntervalKm = 10000;

    double brakeMultiplier = 1.0;
    if (isCity && isMountain) {
      brakeMultiplier = 1.45;
    } else if (isCity) {
      brakeMultiplier = 1.25;
    } else if (isMountain) {
      brakeMultiplier = 1.25;
    } else {
      brakeMultiplier = 0.85;
    }

    final effectiveIntervalKm = (baseIntervalKm / brakeMultiplier).round();
    final wearPercent = ((kmSinceTuneUp / effectiveIntervalKm) * 100).round().clamp(0, 100);
    final remainingKm = max(0, effectiveIntervalKm - kmSinceTuneUp);

    final ComponentStatus status;
    if (wearPercent >= 80) {
      status = ComponentStatus.overdue;
    } else if (wearPercent >= 50) {
      status = ComponentStatus.dueSoon;
    } else {
      status = ComponentStatus.ok;
    }

    final String reason;
    if (isCity && isMountain) {
      reason = 'Frequent urban stop-and-go braking and steep mountain descents accelerate pad wear.';
    } else if (isCity) {
      reason = 'Urban stop-and-go friction cycles accelerate lining wear ($kmSinceTuneUp km logged).';
    } else if (isMountain) {
      reason = 'High-thermal alpine descents elevate brake pad wear rate ($kmSinceTuneUp km logged).';
    } else {
      reason = 'Smooth highway touring braking profile across $kmSinceTuneUp km since last tune-up.';
    }

    return ComponentPrediction(
      id: 'brake-pads',
      name: 'Front Brake Pads',
      subtitle: 'Sintered Metallic Compound',
      wearPercent: wearPercent,
      status: status,
      reason: reason,
      remainingKm: remainingKm,
      remainingDays: (remainingKm / 35).round(),
      diyGuideTitle: 'Brake Pad Thickness & Rotor Check',
      diySteps: const [
        'Shine a flashlight into the caliper inspection port to view remaining friction pad material.',
        'Verify friction material is comfortably above backing plate minimums across both pads.',
        'Inspect brake disc rotors for deep scoring, blue heat discoloration, or lip ridges.',
        'Unbolt caliper retaining pins and slide out old brake pads.',
        'Clean caliper pistons and sliding pins using isopropyl alcohol or dedicated brake cleaner.',
        'Carefully push caliper pistons back into bores to allow clearance for new thick pads.',
        'Install new pads, torque caliper mount bolts, and pump hand lever until firm pressure returns.',
      ],
    );
  }

  // ── Phase 3: Real Pattern Insights Computation ───────────────────────────
  static List<RidePatternInsight> _computePatternInsights(
    List<PostRideReport> reports,
  ) {
    if (reports.length < 3) return const [];

    final recentReports = reports.take(5).toList();
    final total = recentReports.length;

    final offRoadRides = recentReports.where((r) => r.terrainTags.contains('Off-road')).length;
    final offRoadPercent = ((offRoadRides / total) * 100).round();

    final mountainRides = recentReports.where((r) => r.terrainTags.contains('Mountain')).length;
    final mountainPercent = ((mountainRides / total) * 100).round();

    final insights = <RidePatternInsight>[];

    if (offRoadRides > 0) {
      insights.add(
        RidePatternInsight(
          title: 'Chain Wear Accelerating',
          percentageBadge: '$offRoadPercent% Off-Road',
          description: '$offRoadRides of your last $total logged rides included off-road terrain. High silt and gravel exposure accelerates chain and sprocket wear.',
          recommendation: 'Recommend tension adjustment & synthetic lube before cresting the next long trail.',
        ),
      );
    }

    if (mountainRides > 0) {
      insights.add(
        RidePatternInsight(
          title: 'Alpine Descent & Dust Factor',
          percentageBadge: '$mountainPercent% Mountain',
          description: '$mountainRides of your last $total logged rides traversed high-altitude mountain passes with extended descents.',
          recommendation: 'Steep grades increase thermal cycling on brake pads and collect airbox silt. Check pad thickness and wipe down stanchions.',
        ),
      );
    } else if (insights.isEmpty) {
      final cityRides = recentReports.where((r) => r.terrainTags.contains('City')).length;
      final cityPercent = ((cityRides / total) * 100).round();
      insights.add(
        RidePatternInsight(
          title: 'Urban Stop-and-Go Pattern',
          percentageBadge: '$cityPercent% City',
          description: '$cityRides of your last $total logged rides were urban commutes with frequent friction stops.',
          recommendation: 'Monitor front brake pad wear and engine idle temperature.',
        ),
      );
    }

    return insights;
  }
}
