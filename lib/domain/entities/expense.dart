import 'package:equatable/equatable.dart';
import 'package:personal_expense_tracker_app/domain/entities/expense_category.dart';

/// Domain entity for a single expense record.
class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;

  @override
  List<Object?> get props => [id, title, amount, date, category];
}
