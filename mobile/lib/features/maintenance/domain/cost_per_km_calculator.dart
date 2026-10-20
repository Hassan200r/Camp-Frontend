import 'expense_model.dart';
import 'post_ride_report.dart';

/// Calculates total distance covered in ride reports during the trip budget dates
/// or expense period.
double calculateTripDistance({
  DateTime? tripStartDate,
  DateTime? tripEndDate,
  List<Expense> expenses = const [],
  List<PostRideReport> reports = const [],
  String? bikeId,
}) {
  DateTime? start = tripStartDate;
  DateTime? end = tripEndDate;

  // If no explicit trip dates, infer period from expenses
  if (start == null && end == null && expenses.isNotEmpty) {
    for (final exp in expenses) {
      final dt = exp.dateRecorded ?? exp.createdAt;
      if (dt != null) {
        if (start == null || dt.isBefore(start)) {
          start = dt;
        }
        if (end == null || dt.isAfter(end)) {
          end = dt;
        }
      }
    }
  }

  // Normalize start to beginning of day
  final startDay =
      start != null ? DateTime(start.year, start.month, start.day) : null;
  // Normalize end to end of day
  final endDay = end != null
      ? DateTime(end.year, end.month, end.day, 23, 59, 59, 999)
      : null;

  double totalDistance = 0.0;
  for (final report in reports) {
    if (bikeId != null &&
        bikeId.isNotEmpty &&
        report.bikeId.isNotEmpty &&
        report.bikeId != bikeId) {
      continue;
    }
    final rDate = report.date;
    if (startDay != null && rDate.isBefore(startDay)) {
      continue;
    }
    if (endDay != null && rDate.isAfter(endDay)) {
      continue;
    }
    totalDistance += report.distanceKm;
  }

  return totalDistance;
}

/// Calculates cost per km purely from ride reports during the trip budget dates
/// or expense period. Never divides by bike odometer!
///
/// Returns null if no distance was covered or totalCost <= 0 (rendered as "-").
double? calculateCostPerKm({
  required num totalCost,
  DateTime? tripStartDate,
  DateTime? tripEndDate,
  List<Expense> expenses = const [],
  List<PostRideReport> reports = const [],
  String? bikeId,
}) {
  if (totalCost <= 0) return null;

  final totalDistance = calculateTripDistance(
    tripStartDate: tripStartDate,
    tripEndDate: tripEndDate,
    expenses: expenses,
    reports: reports,
    bikeId: bikeId,
  );

  if (totalDistance <= 0.0) return null;
  return totalCost / totalDistance;
}
