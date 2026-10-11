import 'package:flutter/foundation.dart';

import '../../../core/storage/local_store.dart';
import '../domain/expense_model.dart';
import '../domain/trip_budget_model.dart';

/// Central state controller managing trip budget cap, allocations, and expense ledger.
/// Follows the singleton ChangeNotifier pattern established by ActiveBikeController,
/// SettingsController, and PostRideReportController.
class TripBudgetController extends ChangeNotifier {
  TripBudgetController._() {
    _initializeDefaults();
  }

  static final TripBudgetController instance = TripBudgetController._();

  TripBudget _budget = TripBudget.defaultSampleBudget;
  final List<Expense> _expenses = [];

  TripBudget get budget => _budget;
  List<Expense> get expenses => List.unmodifiable(_expenses);

  void _initializeDefaults() {
    _budget = TripBudget.defaultSampleBudget;
    _expenses.clear();
    _expenses.addAll(Expense.defaultSampleExpenses);
  }

  /// Update the trip budget.
  void setBudget(TripBudget budget) {
    _budget = budget;
    notifyListeners();
    save();
  }

  /// Add a new expense line item to the ledger.
  void addExpense(Expense expense) {
    _expenses.insert(0, expense);
    _budget = _budget.copyWith(
      allocatedSoFar: _budget.allocatedSoFar + expense.amount,
    );
    notifyListeners();
    save();
  }

  /// Remove/delete the current trip and clear expenses ledger.
  void deleteTrip() {
    _budget = const TripBudget(
      tripName: 'New Expedition',
      capAmount: 0.0,
      allocatedSoFar: 0.0,
    );
    _expenses.clear();
    notifyListeners();
    save();
  }

  /// Reset to default sample values.
  void reset() {
    _initializeDefaults();
    notifyListeners();
  }

  /// Reset in-memory budget and expenses for testing.
  void resetForTesting() {
    _budget = const TripBudget(
      tripName: '',
      capAmount: 0.0,
      allocatedSoFar: 0.0,
    );
    _expenses.clear();
    notifyListeners();
  }

  /// Load budget and expenses from persistent store.
  Future<void> load([LocalStore? store]) async {
    final localStore = store ?? LocalStore.instance;
    final isFirst = await localStore.isFirstRun();

    if (isFirst) {
      _initializeDefaults();
      await save(localStore);
      return;
    }

    try {
      final budgetJson = await localStore.readJson(LocalStore.keyTripBudget);
      final expensesJson =
          await localStore.readJson(LocalStore.keyTripExpenses);

      if (budgetJson == null || expensesJson == null) {
        // Fall back to defaults without crashing
        _initializeDefaults();
        return;
      }

      final schemaVer = await localStore.getSchemaVersion();
      if (schemaVer == null || schemaVer > LocalStore.currentSchemaVersion) {
        _initializeDefaults();
        return;
      }

      if (budgetJson is Map<String, dynamic>) {
        _budget = TripBudget.fromJson(budgetJson);
      } else if (budgetJson is Map) {
        _budget = TripBudget.fromJson(budgetJson.cast<String, dynamic>());
      } else {
        _initializeDefaults();
        return;
      }

      if (expensesJson is List) {
        _expenses.clear();
        for (final item in expensesJson) {
          if (item is Map<String, dynamic>) {
            _expenses.add(Expense.fromJson(item));
          } else if (item is Map) {
            _expenses.add(Expense.fromJson(item.cast<String, dynamic>()));
          }
        }
      } else {
        _initializeDefaults();
        return;
      }

      notifyListeners();
    } catch (_) {
      // Fallback on corrupt or invalid data
      _initializeDefaults();
      notifyListeners();
    }
  }

  /// Persist budget and expenses to persistent store.
  Future<void> save([LocalStore? store]) async {
    final localStore = store ?? LocalStore.instance;
    try {
      await localStore.writeJson(LocalStore.keyTripBudget, _budget.toJson());
      await localStore.writeJson(
        LocalStore.keyTripExpenses,
        _expenses.map((e) => e.toJson()).toList(),
      );
    } catch (_) {
      // Ignore storage errors in quiet background saves
    }
  }
}
