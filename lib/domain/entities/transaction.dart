import 'package:equatable/equatable.dart';
import 'package:personal_expense_tracker_app/domain/entities/app_currency.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_kind.dart';

/// Ledger entry (expense or income). 
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.kind,
    required this.currency,
    required this.categoryKey,
    this.note,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionKind kind;
  final AppCurrency currency;
  final String categoryKey;
  final String? note;

  @override
  List<Object?> get props => [id, title, amount, date, kind, currency, categoryKey, note];
}
