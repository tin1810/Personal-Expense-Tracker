import 'package:personal_expense_tracker_app/domain/entities/expense.dart';

/// Contract for expense persistence; implementations live in the data layer.
abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses();

  Future<void> addExpense(Expense expense);
}
