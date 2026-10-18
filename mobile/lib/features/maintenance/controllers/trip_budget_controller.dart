import 'package:flutter/foundation.dart';

import '../../../core/data/app_repositories.dart';
import '../../../core/data/finance_repository.dart';
import '../../../core/data/finance_repository_local.dart';
import '../domain/expense_model.dart';
import '../domain/trip_budget_model.dart';

/// Central state controller managing trip budget cap, allocations, and expense ledger.
/// Follows the singleton ChangeNotifier pattern established by ActiveBikeController,
/// SettingsController, and PostRideReportController.
class TripBudgetController extends ChangeNotifier {
  TripBudgetController({FinanceRepository? repository})
      : _repository = repository ?? AppRepositories.instance.financeRepository {
    _initializeDefaults();
  }

  static TripBudgetController instance = TripBudgetController();

  FinanceRepository _repository;

  @visibleForTesting
  set repository(FinanceRepository repo) => _repository = repo;

  TripBudget _budget = TripBudget.defaultSampleBudget;
  final List<Expense> _expenses = [];

  TripBudget get budget => _budget;
  List<Expense> get expenses => List.unmodifiable(_expenses);

  void _initializeDefaults() {
    if (kDebugMode) {
      _budget = TripBudget.defaultSampleBudget;
      _expenses.clear();
      _expenses.addAll(Expense.defaultSampleExpenses);
      _budget = _budget.copyWith(
        allocatedSoFar: _expenses.fold<double>(0.0, (s, e) => s + e.amount),
      );
    } else {
      _budget = const TripBudget(
        tripName: 'Trip Budget',
        capAmount: 0.0,
        allocatedSoFar: 0.0,
      );
      _expenses.clear();
    }
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
      allocatedSoFar: _expenses.fold<double>(0.0, (s, e) => s + e.amount),
    );
    notifyListeners();
    save();
  }

  /// Update an existing expense in the ledger.
  void updateExpense(Expense expense) {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      _budget = _budget.copyWith(
        allocatedSoFar: _expenses.fold<double>(0.0, (s, e) => s + e.amount),
      );
      notifyListeners();
      save();
    }
  }

  /// Remove an expense from the ledger by ID.
  void deleteExpense(String id) {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      _expenses.removeAt(index);
      _budget = _budget.copyWith(
        allocatedSoFar: _expenses.fold<double>(0.0, (s, e) => s + e.amount),
      );
      notifyListeners();
      save();
    }
  }

  /// Insert an expense at a specific index (e.g. for Undo operations).
  void insertExpense(int index, Expense expense) {
    final safeIndex = index.clamp(0, _expenses.length);
    _expenses.insert(safeIndex, expense);
    _budget = _budget.copyWith(
      allocatedSoFar: _expenses.fold<double>(0.0, (s, e) => s + e.amount),
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
    _repository = AppRepositories.instance.financeRepository;
    notifyListeners();
  }

  /// Await completion of all pending storage writes.
  Future<void> flush() => _repository.flush();

  /// Load budget and expenses from repository.
  Future<void> load([dynamic source]) async {
    final repo = resolveFinanceRepository(source, _repository);
    if (source != null) {
      _repository = repo;
    }
    final isFirst = await repo.isFirstRun();

    if (isFirst) {
      _initializeDefaults();
      await save(repo);
      return;
    }

    try {
      final loadedBudget = await repo.loadBudget();
      final loadedExpenses = await repo.loadExpenses();

      if (loadedBudget == null) {
        _initializeDefaults();
        return;
      }

      _budget = loadedBudget;
      _expenses.clear();
      _expenses.addAll(loadedExpenses);
      _budget = _budget.copyWith(
        allocatedSoFar: _expenses.fold<double>(0.0, (s, e) => s + e.amount),
      );
      notifyListeners();
    } catch (_) {
      // Fallback on corrupt or invalid data
      _initializeDefaults();
      notifyListeners();
    }
  }

  /// Persist budget and expenses to repository.
  Future<void> save([dynamic source]) async {
    final repo = resolveFinanceRepository(source, _repository);
    try {
      await repo.saveBudget(_budget);
      await repo.saveExpenses(_expenses);
    } catch (_) {
      // Ignore storage errors in quiet background saves
    }
  }
}
