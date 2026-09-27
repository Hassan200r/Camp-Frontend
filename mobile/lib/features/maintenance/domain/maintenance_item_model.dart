import 'package:flutter/material.dart';

/// Status condition for maintenance items
enum MaintenanceStatus {
  ok,
  dueSoon,
  overdue,
  diyRec,
}

/// Tracking telemetry source
enum MaintenanceTrackingMode {
  auto,
  manual,
}

/// Data model representing a motorcycle maintenance or condition telemetry item.
class MaintenanceItem {
  const MaintenanceItem({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.trackingMode,
    this.dueMileage,
    this.dueDate,
    this.notes,
    this.actionLabel,
    this.trailingNote,
    this.cost,
    this.statusValueDisplay,
    this.subtitle,
    this.conditionNote,
    this.icon,
  });

  final String id;
  final String name;
  final String category;
  final MaintenanceStatus status;
  final MaintenanceTrackingMode trackingMode;
  final String? dueMileage;
  final String? dueDate;
  final String? notes;
  final String? actionLabel;
  final String? trailingNote;
  final double? cost;
  final String? statusValueDisplay;
  final String? subtitle;
  final String? conditionNote;
  final IconData? icon;

  /// Default 5 items matching the CAMP expedition maintenance telemetry spec
  static List<MaintenanceItem> get defaultSampleItems => const [
        MaintenanceItem(
          id: 'maint-1',
          name: 'Rear Brake Pad Replacement',
          category: 'Brakes',
          status: MaintenanceStatus.dueSoon,
          trackingMode: MaintenanceTrackingMode.auto,
          cost: 85.0,
          statusValueDisplay: '\$85',
          subtitle: 'Sintered Compound • Brembo Rear',
          conditionNote: 'Due in 350 mi',
          actionLabel: 'View Guide',
          icon: Icons.disc_full_rounded,
        ),
        MaintenanceItem(
          id: 'maint-2',
          name: 'Engine Oil & Filter',
          category: 'Engine',
          status: MaintenanceStatus.ok,
          trackingMode: MaintenanceTrackingMode.auto,
          statusValueDisplay: 'OK',
          subtitle: 'Synthetic 15W-50 • Motorex Cross Power',
          conditionNote: 'Good • 2,180 mi left',
          trailingNote: 'Changed Jun 04',
          icon: Icons.opacity_rounded,
        ),
        MaintenanceItem(
          id: 'maint-3',
          name: 'Chain / Final Drive Shaft',
          category: 'Drivetrain',
          status: MaintenanceStatus.diyRec,
          trackingMode: MaintenanceTrackingMode.auto,
          statusValueDisplay: 'DIY',
          subtitle: 'Tension Slack: 32mm (Spec: 30mm)',
          conditionNote: 'Recommended before pass',
          actionLabel: 'View Guide',
          icon: Icons.link_rounded,
        ),
        MaintenanceItem(
          id: 'maint-4',
          name: 'Tire Tread Depth',
          category: 'Tires',
          status: MaintenanceStatus.dueSoon,
          trackingMode: MaintenanceTrackingMode.auto,
          statusValueDisplay: 'T-45%',
          subtitle: 'Front: 4.2mm • Rear: 2.8mm',
          conditionNote: 'Monitor rear',
          trailingNote: 'Motoz Tractionator',
          icon: Icons.album_rounded,
        ),
        MaintenanceItem(
          id: 'maint-5',
          name: 'Fork Seals & Dust Boots',
          category: 'Suspension',
          status: MaintenanceStatus.dueSoon,
          trackingMode: MaintenanceTrackingMode.manual,
          cost: 65.0,
          statusValueDisplay: '\$65',
          subtitle: 'WP XPLOR 48mm • Inspect seal weeping',
          conditionNote: 'Due soon • 12,500 mi',
          actionLabel: 'View Guide',
          icon: Icons.swap_vert_circle_rounded,
        ),
      ];
}
