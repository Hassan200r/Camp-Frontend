import 'package:flutter/foundation.dart';

import '../../../core/storage/local_store.dart';
import '../domain/post_ride_report.dart';

/// Central state controller managing user-logged post-ride debriefs.
/// Follows the singleton ChangeNotifier pattern established by ActiveBikeController
/// and SettingsController, serving as the single source of truth for ride logs
/// and pattern insight computations.
class PostRideReportController extends ChangeNotifier {
  PostRideReportController._() {
    _initializeDefaultReports();
  }

  /// Global singleton instance.
  static final PostRideReportController instance = PostRideReportController._();

  final List<PostRideReport> _reports = [];

  /// All stored post-ride reports across all bikes.
  List<PostRideReport> get reports => List.unmodifiable(_reports);

  /// Get all reports for a specific bike, ordered by most recent first.
  List<PostRideReport> getReportsForBike(String bikeId) {
    final bikeReports = _reports.where((r) => r.bikeId == bikeId).toList();
    bikeReports.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(bikeReports);
  }

  /// Add a new post-ride report for a motorcycle.
  void addReport(PostRideReport report) {
    _reports.insert(0, report);
    notifyListeners();
    save();
  }

  /// Remove a specific post-ride report by ID.
  void removeReport(String reportId) {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      _reports.removeAt(index);
      notifyListeners();
      save();
    }
  }

  /// Clear all logged reports for a bike.
  void clearReportsForBike(String bikeId) {
    _reports.removeWhere((r) => r.bikeId == bikeId);
    notifyListeners();
    save();
  }

  /// Reset the controller back to initial default sample reports.
  void reset() {
    _initializeDefaultReports();
    notifyListeners();
  }

  /// Reset to completely empty list (useful for testing zero-state).
  void clearAll() {
    _reports.clear();
    notifyListeners();
    save();
  }

  /// Load post-ride reports from persistent store.
  Future<void> load([LocalStore? store]) async {
    final localStore = store ?? LocalStore.instance;
    final isFirst = await localStore.isFirstRun();

    if (isFirst) {
      _initializeDefaultReports();
      await save(localStore);
      return;
    }

    try {
      final reportsJson =
          await localStore.readJson(LocalStore.keyPostRideReports);

      if (reportsJson == null || reportsJson is! List) {
        // Fall back to defaults without crashing
        _initializeDefaultReports();
        notifyListeners();
        return;
      }

      final schemaVer = await localStore.getSchemaVersion();
      if (schemaVer == null || schemaVer > LocalStore.currentSchemaVersion) {
        _initializeDefaultReports();
        notifyListeners();
        return;
      }

      final loadedReports = <PostRideReport>[];
      for (final item in reportsJson) {
        if (item is Map<String, dynamic>) {
          loadedReports.add(PostRideReport.fromJson(item));
        } else if (item is Map) {
          loadedReports.add(
              PostRideReport.fromJson(item.cast<String, dynamic>()));
        }
      }

      _reports.clear();
      _reports.addAll(loadedReports);
      notifyListeners();
    } catch (_) {
      // Fallback on corrupt data
      _initializeDefaultReports();
      notifyListeners();
    }
  }

  /// Persist post-ride reports to persistent store.
  Future<void> save([LocalStore? store]) async {
    final localStore = store ?? LocalStore.instance;
    try {
      await localStore.writeJson(
        LocalStore.keyPostRideReports,
        _reports.map((r) => r.toJson()).toList(),
      );
    } catch (_) {
      // Ignore background write errors
    }
  }

  void _initializeDefaultReports() {
    _reports.clear();
    final now = DateTime.now();

    // Default sample logs for BMW R 1250 GS (bike-bmw-1250)
    // 5 rides total: 3 include Off-road (60%), 2 include Mountain (40%)
    _reports.addAll([
      PostRideReport(
        id: 'rep-bmw-1',
        bikeId: 'bike-bmw-1250',
        date: now.subtract(const Duration(days: 2)),
        distanceKm: 215.0,
        terrainTags: const ['Off-road', 'Mountain'],
        notes: 'Babusar Pass ascent over rocky trail and loose scree.',
        flaggedIssues: 'High dust & silt on lower chain links',
      ),
      PostRideReport(
        id: 'rep-bmw-2',
        bikeId: 'bike-bmw-1250',
        date: now.subtract(const Duration(days: 6)),
        distanceKm: 340.0,
        terrainTags: const ['Highway'],
        notes: 'Expressway transit leg at steady 110 km/h cruising.',
      ),
      PostRideReport(
        id: 'rep-bmw-3',
        bikeId: 'bike-bmw-1250',
        date: now.subtract(const Duration(days: 11)),
        distanceKm: 185.0,
        terrainTags: const ['Off-road'],
        notes: 'River valley gravel track and stream ford crossings.',
        flaggedIssues: 'Chain tension felt slightly loose near camp',
      ),
      PostRideReport(
        id: 'rep-bmw-4',
        bikeId: 'bike-bmw-1250',
        date: now.subtract(const Duration(days: 17)),
        distanceKm: 85.0,
        terrainTags: const ['City'],
        notes: 'Urban stop-and-go commute in moderate ambient heat.',
      ),
      PostRideReport(
        id: 'rep-bmw-5',
        bikeId: 'bike-bmw-1250',
        date: now.subtract(const Duration(days: 24)),
        distanceKm: 260.0,
        terrainTags: const ['Mountain', 'Off-road'],
        notes: 'Alpine ridge loop with elevation climb from 1,200m to 3,100m.',
        flaggedIssues: 'Fine silt build-up around airbox snorkel',
      ),
    ]);
  }
}
