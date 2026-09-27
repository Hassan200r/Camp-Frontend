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
  });

  final String id;
  final ExpenseCategory category;
  final String title;
  final double amount;
  final ExpenseTrackingMode trackingMode;
  final String? subtitle;
  final String? note;
  final DateTime? dateRecorded;
  final String? formattedDate;

  /// Default line items matching the Alpine Ridge Tour budget ledger
  static List<Expense> get defaultSampleExpenses => [
        const Expense(
          id: 'exp-1',
          category: ExpenseCategory.fuel,
          title: 'Fuel Cost',
          subtitle: 'Shell V-Power 98 • 4.2 gal',
          amount: 62.50,
          trackingMode: ExpenseTrackingMode.autoTrack,
          formattedDate: 'Today, 11:20 AM',
        ),
        const Expense(
          id: 'exp-2',
          category: ExpenseCategory.permits,
          title: 'Park Permits & Passes',
          subtitle: 'Pass #8491 • Babusar West',
          amount: 45.00,
          trackingMode: ExpenseTrackingMode.manualEntry,
          formattedDate: 'Yesterday, 4:15 PM',
        ),
        const Expense(
          id: 'exp-3',
          category: ExpenseCategory.lodging,
          title: 'Camp Lodging & Fees',
          subtitle: 'Deosai Basecamp • 2 Nights',
          amount: 77.00,
          trackingMode: ExpenseTrackingMode.manualEntry,
          formattedDate: 'Oct 14, 6:00 PM',
        ),
      ];
}
