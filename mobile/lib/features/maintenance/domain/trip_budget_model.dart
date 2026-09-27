/// Trip Budget & Fuel Economics domain model.
class TripBudget {
  const TripBudget({
    required this.tripName,
    required this.capAmount,
    this.startDate,
    this.endDate,
    this.allocatedSoFar = 0.0,
  });

  final String tripName;
  final double capAmount;
  final String? startDate;
  final String? endDate;
  final double allocatedSoFar;

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
    String? tripName,
    double? capAmount,
    String? startDate,
    String? endDate,
    double? allocatedSoFar,
  }) {
    return TripBudget(
      tripName: tripName ?? this.tripName,
      capAmount: capAmount ?? this.capAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      allocatedSoFar: allocatedSoFar ?? this.allocatedSoFar,
    );
  }

  /// Default trip budget for Alpine Ridge Tour
  static const TripBudget defaultSampleBudget = TripBudget(
    tripName: 'Alpine Ridge Tour',
    capAmount: 300.0,
    startDate: 'Oct 12, 2026',
    endDate: 'Oct 18, 2026',
    allocatedSoFar: 184.50,
  );
}
