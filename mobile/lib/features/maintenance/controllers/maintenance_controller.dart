import 'package:flutter/foundation.dart';

import '../../garage/controllers/active_bike_controller.dart';
import '../../garage/domain/bike_model.dart';
import '../domain/maintenance_prediction_engine.dart';
import 'post_ride_report_controller.dart';

/// Singleton ChangeNotifier controller exposing maintenance predictions and urgency.
/// Follows the single-controller pattern so the upcoming rider-set service schedule
/// can replace the rule engine without touching the presentation layer.
class MaintenanceController extends ChangeNotifier {
  MaintenanceController._();

  static final MaintenanceController instance = MaintenanceController._();

  /// Whether the given bike has odometer or service records logged.
  bool hasMaintenanceData(Bike? bike) {
    if (bike == null) return false;
    return bike.odometerKm > 0 ||
        bike.lastOilChange != null ||
        bike.lastTuneUp != null;
  }

  /// Returns the most urgent maintenance item (Overdue > Due soon).
  /// If nothing is due or there is no maintenance data, returns null.
  ComponentPrediction? mostUrgentItem(String? bikeId) {
    // Note: The fixed interval table in MaintenancePredictionEngine is temporary
    // and will be replaced by the rider-set service schedule once implemented.
    final bike = _resolveBike(bikeId);
    if (bike == null || !hasMaintenanceData(bike)) {
      return null;
    }

    final reports = PostRideReportController.instance.getReportsForBike(bike.id);
    final assessment = MaintenancePredictionEngine.analyze(
      bike: bike,
      rideReports: reports,
    );

    // Overdue items take absolute priority
    final overdue = assessment.components
        .where((c) => c.status == ComponentStatus.overdue)
        .toList();
    if (overdue.isNotEmpty) {
      overdue.sort((a, b) => b.wearPercent.compareTo(a.wearPercent));
      return overdue.first;
    }

    // Due soon items are second priority
    final dueSoon = assessment.components
        .where((c) => c.status == ComponentStatus.dueSoon)
        .toList();
    if (dueSoon.isNotEmpty) {
      dueSoon.sort((a, b) => b.wearPercent.compareTo(a.wearPercent));
      return dueSoon.first;
    }

    // All components are OK
    return null;
  }

  /// Returns the total number of components that are overdue or due soon.
  int countDueItems(String? bikeId) {
    final bike = _resolveBike(bikeId);
    if (bike == null || !hasMaintenanceData(bike)) {
      return 0;
    }

    final reports = PostRideReportController.instance.getReportsForBike(bike.id);
    final assessment = MaintenancePredictionEngine.analyze(
      bike: bike,
      rideReports: reports,
    );

    return assessment.components
        .where((c) =>
            c.status == ComponentStatus.overdue ||
            c.status == ComponentStatus.dueSoon)
        .length;
  }

  /// Calculates the full maintenance assessment for the given bike.
  MaintenanceAssessment? getAssessment(String? bikeId) {
    final bike = _resolveBike(bikeId);
    if (bike == null) return null;

    final reports = PostRideReportController.instance.getReportsForBike(bike.id);
    return MaintenancePredictionEngine.analyze(
      bike: bike,
      rideReports: reports,
    );
  }

  /// Resolves bike by id or defaults to activeBike.
  Bike? _resolveBike(String? bikeId) {
    if (bikeId != null && bikeId.isNotEmpty) {
      return ActiveBikeController.instance.getBikeById(bikeId);
    }
    return ActiveBikeController.instance.activeBike;
  }

  /// Refreshes state and notifies listeners.
  void refresh() {
    notifyListeners();
  }
}
