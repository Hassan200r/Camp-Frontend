import '../../features/maintenance/domain/expense_model.dart';
import '../../features/maintenance/domain/trip_budget_model.dart';
import '../storage/local_store.dart';
import 'finance_repository.dart';

class FinanceRepositoryLocal implements FinanceRepository {
  FinanceRepositoryLocal([LocalStore? store]) : _explicitStore = store;

  final LocalStore? _explicitStore;
  LocalStore get _store => _explicitStore ?? LocalStore.instance;

  @override
  Future<bool> isFirstRun() => _store.isFirstRun();

  @override
  Future<void> markFirstRunCompleted() => _store.markFirstRunCompleted();

  @override
  Future<TripBudget?> loadBudget() async {
    final isFirst = await _store.isFirstRun();
    if (!isFirst) {
      final schemaVer = await _store.getSchemaVersion();
      if (schemaVer == null || schemaVer > LocalStore.currentSchemaVersion) {
        throw const FormatException('Incompatible schema version');
      }
    }

    final json = await _store.readJson(LocalStore.keyTripBudget);
    if (json == null) {
      return null;
    }
    if (json is! Map) {
      if (!isFirst) {
        throw const FormatException('Corrupted trip budget data');
      }
      return null;
    }
    final map = json is Map<String, dynamic> ? json : json.cast<String, dynamic>();
    if (map['tripName'] == null || (map['capAmount'] != null && map['capAmount'] is! num)) {
      throw const FormatException('Corrupted trip budget data');
    }

    final budget = TripBudget.fromJson(map);
    final hasGeneratedId = (map['id'] == null || (map['id'] as String).isEmpty);
    final hasMissingDates = map['createdAt'] == null || map['updatedAt'] == null;
    if (hasGeneratedId || hasMissingDates) {
      await saveBudget(budget);
    }
    return budget;
  }

  @override
  Future<void> saveBudget(TripBudget? budget) async {
    if (budget == null) {
      await deleteBudget();
      return;
    }

    final updated = budget.copyWith(
      id: budget.effectiveId,
      createdAt: budget.effectiveCreatedAt,
      updatedAt: DateTime.now().toUtc(),
    );
    await _store.writeJson(LocalStore.keyTripBudget, updated.toJson());
  }

  @override
  Future<void> deleteBudget() async {
    await _store.writeJson(LocalStore.keyTripBudget, null);
  }

  @override
  Future<List<Expense>> loadExpenses() async {
    final isFirst = await _store.isFirstRun();
    if (!isFirst) {
      final schemaVer = await _store.getSchemaVersion();
      if (schemaVer == null || schemaVer > LocalStore.currentSchemaVersion) {
        throw const FormatException('Incompatible schema version');
      }
    }

    final json = await _store.readJson(LocalStore.keyTripExpenses);
    if (json == null || json is! List) {
      if (!isFirst) {
        throw const FormatException('Corrupted expenses data');
      }
      return [];
    }

    bool needsMigration = false;
    final expenses = <Expense>[];

    for (int i = 0; i < json.length; i++) {
      final raw = json[i];
      if (raw is Map) {
        final map = raw is Map<String, dynamic> ? raw : raw.cast<String, dynamic>();
        final expense = Expense.fromJson(map);
        if (expense.id.isEmpty || map['id'] == null || (map['id'] as String).isEmpty) {
          needsMigration = true;
          expenses.add(expense.copyWith(id: 'expense_${DateTime.now().millisecondsSinceEpoch}_$i'));
        } else {
          if (map['createdAt'] == null || map['updatedAt'] == null) {
            needsMigration = true;
          }
          expenses.add(expense);
        }
      }
    }

    if (needsMigration) {
      await saveExpenses(expenses);
    }

    return expenses;
  }

  @override
  Future<void> saveExpenses(List<Expense> expenses) async {
    final now = DateTime.now().toUtc();
    final updated = expenses.map((e) {
      return e.copyWith(
        id: e.effectiveId,
        createdAt: e.effectiveCreatedAt,
        updatedAt: now,
      );
    }).toList();

    await _store.writeJson(
      LocalStore.keyTripExpenses,
      updated.map((e) => e.toJson()).toList(),
    );
  }

  @override
  Future<void> deleteExpense(String id) async {
    final current = await loadExpenses();
    final filtered = current.where((e) => e.effectiveId != id).toList();
    await saveExpenses(filtered);
  }

  @override
  Future<void> clear() async {
    await _store.writeJson(LocalStore.keyTripBudget, null);
    await _store.writeJson(LocalStore.keyTripExpenses, null);
  }

  @override
  Future<void> flush() async {
    await _store.flush();
  }
}

FinanceRepository resolveFinanceRepository(dynamic source, [FinanceRepository? fallback]) {
  if (source is FinanceRepository) return source;
  if (source is LocalStore) return FinanceRepositoryLocal(source);
  return fallback ?? FinanceRepositoryLocal();
}
