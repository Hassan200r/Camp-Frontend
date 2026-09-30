import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import 'stat_model.dart';

/// A footer content shape: either a list of chip labels or a plain note string.
sealed class ExpeditionFooter {
  const ExpeditionFooter();
}

class ExpeditionFooterChips extends ExpeditionFooter {
  const ExpeditionFooterChips(this.chips);
  final List<String> chips;
}

class ExpeditionFooterNote extends ExpeditionFooter {
  const ExpeditionFooterNote(this.note);
  final String note;
}

/// Represents one logged expedition entry displayed in the Ride History screen.
class ExpeditionLog {
  const ExpeditionLog({
    required this.date,
    required this.tag,
    required this.tagVariant,
    required this.icon,
    required this.title,
    required this.route,
    required this.bike,
    required this.stats,
    required this.footer,
    required this.footerLink,
    this.tagIcon,
  });

  /// Display date for the pill, e.g. "OCT 11, 2024".
  final String date;

  /// Status chip label, e.g. "Verified Loop".
  final String tag;

  /// StatusChip variant (success / warning / neutral).
  final StatusChipVariant tagVariant;

  /// Leading icon for the card (right of date + tag row), muted or orange.
  final IconData icon;

  /// Optional icon for the StatusChip.
  final IconData? tagIcon;

  /// Card heading, e.g. "Karakoram High-Altitude Corridor".
  final String title;

  /// Sub-heading: "Hasan Abdal → Khunjerab Border • KTM 890 Adv R".
  final String route;

  /// Bike name substring (used separately if needed).
  final String bike;

  /// Four stat tiles shown in a row.
  final List<Stat> stats;

  /// Footer content — chips or a plain note.
  final ExpeditionFooter footer;

  /// Orange link label shown on the right, e.g. "Review GPS →".
  final String footerLink;

  // ── Sample data ────────────────────────────────────────────────────────────

  static final List<ExpeditionLog> samples = [
    const ExpeditionLog(
      date: 'OCT 11, 2024',
      tag: 'Verified Loop',
      tagVariant: StatusChipVariant.success,
      icon: Icons.explore_rounded,
      tagIcon: Icons.verified_rounded,
      title: 'Karakoram High-Altitude Corridor',
      route: 'Hasan Abdal → Khunjerab Border',
      bike: 'KTM 890 Adv R',
      stats: [
        Stat(label: 'DISTANCE', value: '412.0', unit: 'KM'),
        Stat(label: 'TIME', value: '7h 15m'),
        Stat(label: 'AVG SPEED', value: '56.8', unit: 'KMH'),
        Stat(
          label: 'MAX LEAN',
          value: '34°',
          valueColor: Color(0xFFFA7014),
        ),
      ],
      footer: ExpeditionFooterChips(['#KKH', 'Pass Elev 4,693m']),
      footerLink: 'Review GPS →',
    ),
    const ExpeditionLog(
      date: 'SEP 28, 2024',
      tag: 'Crosswind 32kt',
      tagVariant: StatusChipVariant.warning,
      icon: Icons.waves_rounded,
      title: 'Makran Coastal Highway & Mud Volcanoes',
      route: 'Hingol National Park',
      bike: 'BMW R 1250 GS',
      stats: [
        Stat(label: 'DISTANCE', value: '340.5', unit: 'KM'),
        Stat(label: 'TIME', value: '4h 50m'),
        Stat(label: 'TIRE PSI', value: '32/36'),
        Stat(
          label: 'FUEL ECON',
          value: '4.4',
          unit: 'L',
          valueColor: Color(0xFF22C55E),
          unitColor: Color(0xFF22C55E),
        ),
      ],
      footer: ExpeditionFooterNote(
        'Mechanic Pitstop: Peak Moto (12 min check)',
      ),
      footerLink: 'Logs →',
    ),
    const ExpeditionLog(
      date: 'SEP 15, 2024',
      tag: 'Derawar Fort Circuit',
      tagVariant: StatusChipVariant.neutral,
      icon: Icons.flag_rounded,
      title: 'Cholistan Desert Sand Nav Loop',
      route: 'Deep Sand Dunes',
      bike: 'KTM 890 Adv R',
      stats: [
        Stat(label: 'DISTANCE', value: '188.0', unit: 'KM'),
        Stat(label: 'TIME', value: '3h 40m'),
        Stat(
          label: 'SAND PSI',
          value: '22/24',
          valueColor: Color(0xFFFA7014),
        ),
        Stat(label: 'IMU EVENT', value: '0 Fall'),
      ],
      footer: ExpeditionFooterNote('Sand filter cleaned at 188 KM'),
      footerLink: 'Logs →',
    ),
  ];
}
