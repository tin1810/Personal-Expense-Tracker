import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_expense_tracker_app/data/mappers/expense_mapper.dart';
import 'package:personal_expense_tracker_app/data/models/expense_hive_model.dart';
import 'package:personal_expense_tracker_app/domain/entities/expense.dart';
import 'package:personal_expense_tracker_app/domain/repositories/expense_repository.dart';

/// Persists expenses with Hive ([Box] keyed by expense id).
class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl({required Box<ExpenseHiveModel> box}) : _box = box;

  final Box<ExpenseHiveModel> _box;

  @override
  Future<List<Expense>> getExpenses() async {
    final entities = _box.values.map(expenseHiveToEntity).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return List<Expense>.unmodifiable(entities);
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await _box.put(expense.id, expenseEntityToHive(expense));
  }
}
