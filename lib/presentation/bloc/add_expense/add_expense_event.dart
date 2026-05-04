import 'package:equatable/equatable.dart';
import 'package:personal_expense_tracker_app/domain/entities/expense_category.dart';

sealed class AddExpenseEvent extends Equatable {
  const AddExpenseEvent();

  @override
  List<Object?> get props => [];
}

final class AddExpenseSubmitted extends AddExpenseEvent {
  const AddExpenseSubmitted({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;

  @override
  List<Object?> get props => [title, amount, date, category];
}

final class AddExpenseReset extends AddExpenseEvent {
  const AddExpenseReset();
}
