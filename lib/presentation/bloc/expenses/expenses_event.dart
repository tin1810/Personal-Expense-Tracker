import 'package:equatable/equatable.dart';
import 'package:personal_expense_tracker_app/domain/entities/expense_category.dart';

sealed class ExpensesEvent extends Equatable {
  const ExpensesEvent();

  @override
  List<Object?> get props => [];
}

final class ExpensesRequested extends ExpensesEvent {
  const ExpensesRequested();
}

final class ExpensesRefreshRequested extends ExpensesEvent {
  const ExpensesRefreshRequested();
}

final class ExpensesSearchQueryChanged extends ExpensesEvent {
  const ExpensesSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class ExpensesCategoryFilterChanged extends ExpensesEvent {
  const ExpensesCategoryFilterChanged(this.category);

  /// `null` means show all categories.
  final ExpenseCategory? category;

  @override
  List<Object?> get props => [category];
}
