/// Pure logic for motorcycle fuel estimation and consumption calculations.
/// IMPORTANT: Contains NO Flutter imports.
class FuelEstimator {
  const FuelEstimator._();

  /// Applies distance traveled [km] to [currentLiters] given consumption [kmPerLiter].
  /// Returns updated fuel in liters, clamped to never fall below 0.0.
  /// If [currentLiters] is null, returns null.
  /// If [kmPerLiter] is null or <= 0, or [km] <= 0, returns [currentLiters].
  static double? applyDistance(
    double? currentLiters,
    double km,
    double? kmPerLiter,
  ) {
    if (currentLiters == null) return null;
    if (kmPerLiter == null || kmPerLiter <= 0 || km <= 0) return currentLiters;
    final consumed = km / kmPerLiter;
    final remaining = currentLiters - consumed;
    return remaining < 0.0 ? 0.0 : remaining;
  }

  /// Calculates estimated range in km: liters * kmPerLiter.
  /// Returns null when liters is null or kmPerLiter is missing/non-positive.
  static double? rangeKm(double? liters, double? kmPerLiter) {
    if (liters == null || kmPerLiter == null || kmPerLiter <= 0) return null;
    return liters * kmPerLiter;
  }

  /// Calculates fuel percentage (0.0 to 100.0) based on [liters] and [tankCapacityL].
  /// Returns null when liters is null or tankCapacityL is missing/non-positive.
  static double? percent(double? liters, double? tankCapacityL) {
    if (liters == null || tankCapacityL == null || tankCapacityL <= 0) {
      return null;
    }
    return ((liters / tankCapacityL) * 100.0).clamp(0.0, 100.0);
  }

  /// Computes actual fuel consumption efficiency (km/L) between two full refills:
  /// distance tracked between them / liters added.
  /// Returns null if distance or liters added is non-positive.
  static double? computeFullToFullEfficiency(
    double distanceKm,
    double litersAdded,
  ) {
    if (distanceKm <= 0 || litersAdded <= 0) return null;
    return distanceKm / litersAdded;
  }
}
