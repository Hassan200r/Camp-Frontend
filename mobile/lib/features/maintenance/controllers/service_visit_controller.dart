import 'package:flutter/material.dart';

import '../../../core/data/app_repositories.dart';
import '../../../core/data/service_visit_repository.dart';
import '../../../core/widgets/app_messenger.dart';
import '../../garage/controllers/active_bike_controller.dart';
import '../domain/expense_model.dart';
import '../domain/service_visit_model.dart';
import 'trip_budget_controller.dart';

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

  /// All past visits sorted by active bike first, then most recent first.
  List<ServiceVisit> get pastVisits {
    final activeId = ActiveBikeController.instance.activeBike?.id;
    final list = _visits.where((v) => v.isPast).toList();
    list.sort((a, b) {
      if (activeId != null && activeId.isNotEmpty) {
        final aActive = a.bikeId != null && a.bikeId == activeId;
        final bActive = b.bikeId != null && b.bikeId == activeId;
        if (aActive && !bActive) return -1;
        if (!aActive && bActive) return 1;
      }
      return b.dateTime.compareTo(a.dateTime);
    });
    return List.unmodifiable(list);
  }

  /// Add a newly scheduled service visit.
  Future<void> addVisit(ServiceVisit visit, [BuildContext? context]) async {
    final previous = List<ServiceVisit>.from(_visits);
    _visits.add(visit);
    notifyListeners();
    try {
      await _repository.saveServiceVisits(_visits);
    } catch (e) {
      _visits.clear();
      _visits.addAll(previous);
      notifyListeners();
      if (context != null && context.mounted) {
        showSaveErrorSnackBar(context);
      } else {
        showSaveErrorSnackBar();
      }
      rethrow;
    }
  }

  /// Update an existing scheduled service visit.
  Future<void> updateVisit(ServiceVisit visit, [BuildContext? context]) async {
    final index = _visits.indexWhere((v) => v.id == visit.id);
    if (index == -1) return;
    final previous = List<ServiceVisit>.from(_visits);
    _visits[index] = visit;
    notifyListeners();
    try {
      await _repository.saveServiceVisits(_visits);
    } catch (e) {
      _visits.clear();
      _visits.addAll(previous);
      notifyListeners();
      if (context != null && context.mounted) {
        showSaveErrorSnackBar(context);
      } else {
        showSaveErrorSnackBar();
      }
      rethrow;
    }
  }

  /// Remove a service visit by its ID.
  Future<void> deleteVisit(String id, [BuildContext? context]) async {
    final index = _visits.indexWhere((v) => v.id == id);
    if (index == -1) return;
    final visit = _visits[index];
    final previous = List<ServiceVisit>.from(_visits);
    _visits.removeAt(index);
    notifyListeners();
    try {
      await _repository.saveServiceVisits(_visits);
      if (visit.expenseId != null && visit.expenseId!.isNotEmpty) {
        final expExists = TripBudgetController.instance.expenses
            .any((Expense e) => e.id == visit.expenseId);
        if (expExists) {
          TripBudgetController.instance.deleteExpense(visit.expenseId!);
        }
      }
    } catch (e) {
      _visits.clear();
      _visits.addAll(previous);
      notifyListeners();
      if (context != null && context.mounted) {
        showSaveErrorSnackBar(context);
      } else {
        showSaveErrorSnackBar();
      }
      rethrow;
    }
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
    await repo.saveServiceVisits(_visits);
  }
}
