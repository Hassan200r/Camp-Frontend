import 'package:flutter/material.dart';

/// Categories for expedition expenses
enum ExpenseCategory {
  fuel,
  permits,
  lodging,
  parts,
  service,
  food,
  other;

  String get displayName {
    switch (this) {
      case ExpenseCategory.fuel:
        return 'Fuel';
      case ExpenseCategory.permits:
        return 'Permits';
      case ExpenseCategory.lodging:
        return 'Lodging';
      case ExpenseCategory.parts:
        return 'Parts';
      case ExpenseCategory.service:
        return 'Service';
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  String get chipLabel {
    switch (this) {
      case ExpenseCategory.fuel:
        return '🛢 Fuel';
      case ExpenseCategory.permits:
        return '🎫 Permits';
      case ExpenseCategory.lodging:
        return '⛺ Lodging';
      case ExpenseCategory.parts:
        return '🔧 Parts';
      case ExpenseCategory.service:
        return '🛠 Service';
      case ExpenseCategory.food:
        return '🍴 Food';
      case ExpenseCategory.other:
        return '⋯ Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.fuel:
        return Icons.local_gas_station_rounded;
      case ExpenseCategory.permits:
        return Icons.confirmation_number_rounded;
      case ExpenseCategory.lodging:
        return Icons.holiday_village_rounded;
      case ExpenseCategory.parts:
        return Icons.build_circle_rounded;
      case ExpenseCategory.service:
        return Icons.handyman_rounded;
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.other:
        return Icons.more_horiz_rounded;
    }
  }
}

/// Telemetry vs Manual Entry mode
enum ExpenseTrackingMode {
  autoTrack,
  manualEntry;

  String get label {
    switch (this) {
      case ExpenseTrackingMode.autoTrack:
        return 'Auto';
      case ExpenseTrackingMode.manualEntry:
        return 'Manual';
    }
  }
}

/// An expense record in a trip's budget ledger
class Expense {
  const Expense({
    required this.id,
    required this.category,
    required this.title,
    required this.amount,
    required this.trackingMode,
    this.subtitle,
    this.note,
    this.dateRecorded,
    this.formattedDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    DateTime? parseUtc(dynamic val) {
      if (val == null) return null;
      if (val is String) return DateTime.tryParse(val)?.toUtc();
      return null;
    }

    final rawId = json['id'] as String?;
    final effectiveId = (rawId != null && rawId.trim().isNotEmpty)
        ? rawId.trim()
        : 'exp-${DateTime.now().millisecondsSinceEpoch}';

    final dateRec = json['dateRecorded'] != null
        ? DateTime.tryParse(json['dateRecorded'] as String)
        : null;
    final createdUtc =
        parseUtc(json['createdAt']) ?? dateRec?.toUtc() ?? DateTime.now().toUtc();
    final updatedUtc = parseUtc(json['updatedAt']) ?? createdUtc;

    return Expense(
      id: effectiveId,
      createdAt: createdUtc,
      updatedAt: updatedUtc,
      category: ExpenseCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => ExpenseCategory.other,
      ),
      title: json['title'] as String? ?? 'Expense',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      trackingMode: json['trackingMode'] == 'autoTrack'
          ? ExpenseTrackingMode.autoTrack
          : ExpenseTrackingMode.manualEntry,
      subtitle: json['subtitle'] as String?,
      note: json['note'] as String?,
      dateRecorded: dateRec,
      formattedDate: json['formattedDate'] as String?,
    );
  }

  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get effectiveId => id;
  DateTime get effectiveCreatedAt =>
      createdAt?.toUtc() ?? dateRecorded?.toUtc() ?? DateTime.now().toUtc();
  DateTime get effectiveUpdatedAt =>
      updatedAt?.toUtc() ?? effectiveCreatedAt;

  final ExpenseCategory category;
  final String title;
  final double amount;
  final ExpenseTrackingMode trackingMode;
  final String? subtitle;
  final String? note;
  final DateTime? dateRecorded;
  final String? formattedDate;

  Expense copyWith({
    String? id,
    ExpenseCategory? category,
    String? title,
    double? amount,
    ExpenseTrackingMode? trackingMode,
    String? subtitle,
    String? note,
    DateTime? dateRecorded,
    String? formattedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      trackingMode: trackingMode ?? this.trackingMode,
      subtitle: subtitle ?? this.subtitle,
      note: note ?? this.note,
      dateRecorded: dateRecorded ?? this.dateRecorded,
      formattedDate: formattedDate ?? this.formattedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
    );
  }

  /// Default line items matching the Alpine Ridge Tour budget ledger (Demo data)
  static List<Expense> get defaultSampleExpenses => [
        const Expense(
          id: 'exp-1',
          category: ExpenseCategory.fuel,
          title: 'Fuel Cost',
          subtitle: 'Shell V-Power • 35 L (Demo data)',
          note: 'Demo data',
          amount: 9800.0,
          trackingMode: ExpenseTrackingMode.autoTrack,
          formattedDate: 'Today, 11:20 AM',
        ),
        const Expense(
          id: 'exp-2',
          category: ExpenseCategory.permits,
          title: 'Park Permits & Passes',
          subtitle: 'Pass #8491 • Babusar West (Demo data)',
          note: 'Demo data',
          amount: 15500.0,
          trackingMode: ExpenseTrackingMode.manualEntry,
          formattedDate: 'Yesterday, 4:15 PM',
        ),
        const Expense(
          id: 'exp-3',
          category: ExpenseCategory.lodging,
          title: 'Camp Lodging & Fees',
          subtitle: 'Deosai Basecamp • 2 Nights (Demo data)',
          note: 'Demo data',
          amount: 20825.0,
          trackingMode: ExpenseTrackingMode.manualEntry,
          formattedDate: 'Oct 14, 6:00 PM',
        ),
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          category == other.category &&
          title == other.title &&
          amount == other.amount &&
          trackingMode == other.trackingMode &&
          subtitle == other.subtitle &&
          note == other.note &&
          dateRecorded == other.dateRecorded &&
          formattedDate == other.formattedDate;

  @override
  int get hashCode => Object.hash(
        id,
        category,
        title,
        amount,
        trackingMode,
        subtitle,
        note,
        dateRecorded,
        formattedDate,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': effectiveCreatedAt.toIso8601String(),
        'updatedAt': effectiveUpdatedAt.toIso8601String(),
        'category': category.name,
        'title': title,
        'amount': amount,
        'trackingMode': trackingMode.name,
        'subtitle': subtitle,
        'note': note,
        'dateRecorded': dateRecorded?.toIso8601String(),
        'formattedDate': formattedDate,
      };
}
