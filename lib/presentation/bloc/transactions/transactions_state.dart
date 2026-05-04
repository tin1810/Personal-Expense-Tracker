import 'package:equatable/equatable.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_kind.dart';

sealed class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

final class TransactionsInitial extends TransactionsState {
  const TransactionsInitial();
}

final class TransactionsLoading extends TransactionsState {
  const TransactionsLoading();
}

final class TransactionsLoaded extends TransactionsState {
  const TransactionsLoaded({
    required this.allTransactions,
    required this.focusedMonth,
  });

  final List<Transaction> allTransactions;

  /// Year/month for the home list and header totals (day ignored).
  final DateTime focusedMonth;

  List<Transaction> get transactionsInFocusedMonth {
    final y = focusedMonth.year;
    final m = focusedMonth.month;
    return allTransactions.where((t) => t.date.year == y && t.date.month == m).toList(growable: false);
  }

  /// Home list: visible month only (filters live on the Search tab).
  List<Transaction> get filteredTransactions => transactionsInFocusedMonth;

  double get monthExpenseTotal =>
      transactionsInFocusedMonth.where((t) => t.kind == TransactionKind.expense).fold<double>(0, (s, t) => s + t.amount);

  double get monthIncomeTotal =>
      transactionsInFocusedMonth.where((t) => t.kind == TransactionKind.income).fold<double>(0, (s, t) => s + t.amount);

  @override
  List<Object?> get props => [allTransactions, focusedMonth];
}

final class TransactionsFailure extends TransactionsState {
  const TransactionsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
