/// Trip Budget & Fuel Economics domain model.
class TripBudget {
  const TripBudget({
    required this.tripName,
    required this.capAmount,
    this.id = 'budget-active',
    this.startDate,
    this.endDate,
    this.allocatedSoFar = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory TripBudget.fromJson(Map<String, dynamic> json) {
    DateTime? parseUtc(dynamic val) {
      if (val == null) return null;
      if (val is String) return DateTime.tryParse(val)?.toUtc();
      return null;
    }

    final rawId = json['id'] as String?;
    final effectiveId = (rawId != null && rawId.trim().isNotEmpty)
        ? rawId.trim()
        : 'budget-active';

    final createdUtc = parseUtc(json['createdAt']) ?? DateTime.now().toUtc();
    final updatedUtc = parseUtc(json['updatedAt']) ?? createdUtc;

    return TripBudget(
      id: effectiveId,
      tripName: json['tripName'] as String? ?? 'Trip Budget',
      capAmount: (json['capAmount'] as num?)?.toDouble() ?? 0.0,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      allocatedSoFar: (json['allocatedSoFar'] as num?)?.toDouble() ?? 0.0,
      createdAt: createdUtc,
      updatedAt: updatedUtc,
    );
  }

  final String id;
  final String tripName;
  final double capAmount;
  final String? startDate;
  final String? endDate;
  final double allocatedSoFar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get effectiveId => id;
  DateTime get effectiveCreatedAt =>
      createdAt?.toUtc() ?? DateTime(2024, 1, 1).toUtc();
  DateTime get effectiveUpdatedAt =>
      updatedAt?.toUtc() ?? effectiveCreatedAt;

  /// Progress ratio clamped between 0.0 and 1.0 for progress indicators
  double get spentRatio =>
      capAmount > 0 ? (allocatedSoFar / capAmount).clamp(0.0, 1.0) : 0.0;

  /// Integer percentage e.g. 62
  int get spentPercentInt =>
      capAmount > 0 ? ((allocatedSoFar / capAmount) * 100).round() : 0;

  /// Remaining amount below cap
  double get remainingAmount => (capAmount - allocatedSoFar);

  /// Alias for remaining amount under budget
  double get underBudgetAmount => (capAmount - allocatedSoFar);

  /// Remaining percentage e.g. 38.5
  double get remainingPercent =>
      capAmount > 0 ? (100.0 - (allocatedSoFar / capAmount * 100.0)).clamp(0.0, 100.0) : 0.0;

  bool get isUnderBudget => allocatedSoFar <= capAmount;

  TripBudget copyWith({
    String? id,
    String? tripName,
    double? capAmount,
    String? startDate,
    String? endDate,
    double? allocatedSoFar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripBudget(
      id: id ?? this.id,
      tripName: tripName ?? this.tripName,
      capAmount: capAmount ?? this.capAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      allocatedSoFar: allocatedSoFar ?? this.allocatedSoFar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
    );
  }

  /// Default trip budget for Alpine Ridge Tour (Demo data)
  static const TripBudget defaultSampleBudget = TripBudget(
    tripName: 'Alpine Ridge Tour',
    capAmount: 75000.0,
    startDate: 'Oct 12, 2026',
    endDate: 'Oct 18, 2026',
    allocatedSoFar: 46125.0,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripBudget &&
          runtimeType == other.runtimeType &&
          tripName == other.tripName &&
          capAmount == other.capAmount &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          allocatedSoFar == other.allocatedSoFar;

  @override
  int get hashCode => Object.hash(
        tripName,
        capAmount,
        startDate,
        endDate,
        allocatedSoFar,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': effectiveCreatedAt.toIso8601String(),
        'updatedAt': effectiveUpdatedAt.toIso8601String(),
        'tripName': tripName,
        'capAmount': capAmount,
        'startDate': startDate,
        'endDate': endDate,
        'allocatedSoFar': allocatedSoFar,
      };
}
