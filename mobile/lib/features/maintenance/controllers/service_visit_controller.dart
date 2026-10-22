import 'package:flutter/foundation.dart';

import '../../../core/data/app_repositories.dart';
import '../../../core/data/service_visit_repository.dart';
import '../domain/service_visit_model.dart';

/// Central state controller managing scheduled and historical workshop service visits.
/// Follows the singleton ChangeNotifier pattern established by ActiveBikeController,
/// TripBudgetController, and SettingsController.
class ServiceVisitController extends ChangeNotifier {
  ServiceVisitController({ServiceVisitRepository? repository})
      : _repository =
            repository ?? AppRepositories.instance.serviceVisitRepository;

  static ServiceVisitController instance = ServiceVisitController();

  ServiceVisitRepository _repository;

  @visibleForTesting
  set repository(ServiceVisitRepository repo) => _repository = repo;

  final List<ServiceVisit> _visits = [];

  List<ServiceVisit> get visits => List.unmodifiable(_visits);

  /// Returns the earliest upcoming planned service visit, or null if none.
  /// Past visits automatically move off this card.
  ServiceVisit? get nextPlannedVisit {
    final upcoming = _visits.where((v) => !v.isPast).toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return upcoming.first;
  }

  /// All upcoming visits sorted by earliest date.
  List<ServiceVisit> get upcomingVisits {
    final list = _visits.where((v) => !v.isPast).toList();
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return List.unmodifiable(list);
  }

  /// All past visits sorted by most recent first.
  List<ServiceVisit> get pastVisits {
    final list = _visits.where((v) => v.isPast).toList();
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return List.unmodifiable(list);
  }

  /// Add a newly scheduled service visit.
  Future<void> addVisit(ServiceVisit visit) async {
    _visits.add(visit);
    notifyListeners();
    await save();
  }

  /// Update an existing scheduled service visit.
  Future<void> updateVisit(ServiceVisit visit) async {
    final index = _visits.indexWhere((v) => v.id == visit.id);
    if (index != -1) {
      _visits[index] = visit;
      notifyListeners();
      await save();
    }
  }

  /// Remove a service visit by its ID.
  Future<void> deleteVisit(String id) async {
    final index = _visits.indexWhere((v) => v.id == id);
    if (index != -1) {
      _visits.removeAt(index);
      notifyListeners();
      await save();
    }
  }

  /// Reset in-memory state for testing.
  void resetForTesting() {
    _visits.clear();
    _repository = AppRepositories.instance.serviceVisitRepository;
    notifyListeners();
  }

  /// Load persisted service visits from storage.
  Future<void> load([ServiceVisitRepository? customRepo]) async {
    final repo = customRepo ?? _repository;
    _repository = repo;
    try {
      final loaded = await repo.loadServiceVisits();
      _visits.clear();
      _visits.addAll(loaded);
      notifyListeners();
    } catch (_) {}
  }

  /// Persist current visits list to storage.
  Future<void> save([ServiceVisitRepository? customRepo]) async {
    final repo = customRepo ?? _repository;
    try {
      await repo.saveServiceVisits(_visits);
    } catch (_) {}
  }
}
