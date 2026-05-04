import 'package:personal_expense_tracker_app/domain/entities/expense.dart';
import 'package:personal_expense_tracker_app/domain/repositories/expense_repository.dart';

/// In-memory repo for widget/unit tests (no Hive on disk).
class FakeExpenseRepository implements ExpenseRepository {
  final List<Expense> _expenses = [];

  @override
  Future<List<Expense>> getExpenses() async => List<Expense>.unmodifiable(_expenses);

  @override
  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
  }
}
