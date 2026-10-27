// ignore_for_file: non_const_argument_for_const_parameter
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
    this.bikeId,
    this.dueMileage,
    this.dueDate,
    this.notes,
    this.actionLabel,
    this.trailingNote,
    this.cost,
    this.expenseId,
    this.mechanicName,
    this.statusValueDisplay,
    this.subtitle,
    this.conditionNote,
    this.icon,
    this.createdAt,
    this.updatedAt,
  });

  factory MaintenanceItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseUtc(dynamic val) {
      if (val == null) return null;
      if (val is String) return DateTime.tryParse(val)?.toUtc();
      return null;
    }

    final rawId = json['id'] as String?;
    final effectiveId = (rawId != null && rawId.trim().isNotEmpty)
        ? rawId.trim()
        : 'maint-${DateTime.now().millisecondsSinceEpoch}';

    final createdUtc = parseUtc(json['createdAt']) ?? DateTime.now().toUtc();
    final updatedUtc = parseUtc(json['updatedAt']) ?? createdUtc;

    IconData? icon;
    if (json['iconCodePoint'] != null) {
      icon = IconData(
        json['iconCodePoint'] as int,
        fontFamily: 'MaterialIcons',
      );
    }

    final rawExpId = (json['expenseId'] ?? json['expense_id']) as String?;

    return MaintenanceItem(
      id: effectiveId,
      createdAt: createdUtc,
      updatedAt: updatedUtc,
      name: json['name'] as String? ?? 'Maintenance Item',
      category: json['category'] as String? ?? 'General',
      status: MaintenanceStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => MaintenanceStatus.ok,
      ),
      trackingMode: MaintenanceTrackingMode.values.firstWhere(
        (m) => m.name == json['trackingMode'],
        orElse: () => MaintenanceTrackingMode.auto,
      ),
      bikeId: json['bikeId'] as String?,
      dueMileage: json['dueMileage'] as String?,
      dueDate: json['dueDate'] as String?,
      notes: json['notes'] as String?,
      actionLabel: json['actionLabel'] as String?,
      trailingNote: json['trailingNote'] as String?,
      cost: (json['cost'] as num?)?.toDouble(),
      expenseId: (rawExpId != null && rawExpId.trim().isNotEmpty)
          ? rawExpId.trim()
          : null,
      mechanicName: (json['mechanicName'] ?? json['mechanic'] ?? json['shopName']) as String?,
      statusValueDisplay: json['statusValueDisplay'] as String?,
      subtitle: json['subtitle'] as String?,
      conditionNote: json['conditionNote'] as String?,
      icon: icon,
    );
  }

  final String id;
  final String? bikeId;
  final String? expenseId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get effectiveId => id;

  DateTime get effectiveCreatedAt =>
      createdAt?.toUtc() ?? DateTime(2024, 1, 1).toUtc();
  DateTime get effectiveUpdatedAt =>
      updatedAt?.toUtc() ?? effectiveCreatedAt;

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
  final String? mechanicName;
  final String? statusValueDisplay;
  final String? subtitle;
  final String? conditionNote;
  final IconData? icon;

  static const _sentinel = Object();

  MaintenanceItem copyWith({
    String? id,
    String? name,
    String? category,
    MaintenanceStatus? status,
    MaintenanceTrackingMode? trackingMode,
    Object? bikeId = _sentinel,
    String? dueMileage,
    String? dueDate,
    String? notes,
    String? actionLabel,
    String? trailingNote,
    double? cost,
    Object? expenseId = _sentinel,
    String? mechanicName,
    String? statusValueDisplay,
    String? subtitle,
    String? conditionNote,
    IconData? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      status: status ?? this.status,
      trackingMode: trackingMode ?? this.trackingMode,
      bikeId: identical(bikeId, _sentinel) ? this.bikeId : (bikeId as String?),
      dueMileage: dueMileage ?? this.dueMileage,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      actionLabel: actionLabel ?? this.actionLabel,
      trailingNote: trailingNote ?? this.trailingNote,
      cost: cost ?? this.cost,
      expenseId: identical(expenseId, _sentinel)
          ? this.expenseId
          : (expenseId as String?),
      mechanicName: mechanicName ?? this.mechanicName,
      statusValueDisplay: statusValueDisplay ?? this.statusValueDisplay,
      subtitle: subtitle ?? this.subtitle,
      conditionNote: conditionNote ?? this.conditionNote,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'createdAt': effectiveCreatedAt.toIso8601String(),
      'updatedAt': effectiveUpdatedAt.toIso8601String(),
      'name': name,
      'category': category,
      'status': status.name,
      'trackingMode': trackingMode.name,
      'bikeId': bikeId,
      'dueMileage': dueMileage,
      'dueDate': dueDate,
      'notes': notes,
      'actionLabel': actionLabel,
      'trailingNote': trailingNote,
      'cost': cost,
      'mechanicName': mechanicName,
      'statusValueDisplay': statusValueDisplay,
      'subtitle': subtitle,
      'conditionNote': conditionNote,
      'iconCodePoint': icon?.codePoint,
    };
    if (expenseId != null) map['expenseId'] = expenseId;
    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaintenanceItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          category == other.category &&
          status == other.status &&
          trackingMode == other.trackingMode &&
          bikeId == other.bikeId &&
          dueMileage == other.dueMileage &&
          dueDate == other.dueDate &&
          notes == other.notes &&
          actionLabel == other.actionLabel &&
          trailingNote == other.trailingNote &&
          cost == other.cost &&
          expenseId == other.expenseId &&
          mechanicName == other.mechanicName &&
          statusValueDisplay == other.statusValueDisplay &&
          subtitle == other.subtitle &&
          conditionNote == other.conditionNote;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        category,
        status,
        trackingMode,
        bikeId,
        dueMileage,
        dueDate,
        notes,
        actionLabel,
        trailingNote,
        cost,
        expenseId,
        mechanicName,
        statusValueDisplay,
        subtitle,
        conditionNote,
      );
}
