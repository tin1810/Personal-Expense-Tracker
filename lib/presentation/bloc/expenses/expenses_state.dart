import 'package:equatable/equatable.dart';
import 'package:personal_expense_tracker_app/domain/entities/expense.dart';
import 'package:personal_expense_tracker_app/domain/entities/expense_category.dart';

sealed class ExpensesState extends Equatable {
  const ExpensesState();

  @override
  List<Object?> get props => [];
}

final class ExpensesInitial extends ExpensesState {
  const ExpensesInitial();
}

final class ExpensesLoading extends ExpensesState {
  const ExpensesLoading();
}

final class ExpensesLoaded extends ExpensesState {
  const ExpensesLoaded({
    required this.allExpenses,
    this.searchQuery = '',
    this.categoryFilter,
  });

  final List<Expense> allExpenses;
  final String searchQuery;

  /// When non-null, only this category is shown (before search).
  final ExpenseCategory? categoryFilter;

  List<Expense> get filteredExpenses {
    Iterable<Expense> items = allExpenses;
    if (categoryFilter != null) {
      items = items.where((e) => e.category == categoryFilter);
    }
    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((e) => e.title.toLowerCase().contains(q));
    }
    return items.toList(growable: false);
  }

  double get filteredTotal =>
      filteredExpenses.fold<double>(0, (sum, e) => sum + e.amount);

  @override
  List<Object?> get props => [allExpenses, searchQuery, categoryFilter];
}

final class ExpensesEmpty extends ExpensesState {
  const ExpensesEmpty();
}

final class ExpensesFailure extends ExpensesState {
  const ExpensesFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
