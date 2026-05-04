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
    this.selectedCalendarDay,
  });

  final List<Transaction> allTransactions;

  /// Year/month for the home list header and month navigation (day ignored).
  final DateTime focusedMonth;

  /// When set, list and header totals are restricted to this calendar date (must match [focusedMonth] year/month).
  final DateTime? selectedCalendarDay;

  List<Transaction> get transactionsInFocusedMonth {
    final y = focusedMonth.year;
    final m = focusedMonth.month;
    return allTransactions.where((t) => t.date.year == y && t.date.month == m).toList(growable: false);
  }

  /// Home list: visible month, optionally a single selected day.
  List<Transaction> get filteredTransactions {
    final inMonth = transactionsInFocusedMonth;
    final day = selectedCalendarDay;
    if (day == null) return inMonth;
    final normalized = DateTime(day.year, day.month, day.day);
    return inMonth
        .where((t) {
          final td = DateTime(t.date.year, t.date.month, t.date.day);
          return td == normalized;
        })
        .toList(growable: false);
  }

  double get monthExpenseTotal =>
      filteredTransactions.where((t) => t.kind == TransactionKind.expense).fold<double>(0, (s, t) => s + t.amount);

  double get monthIncomeTotal =>
      filteredTransactions.where((t) => t.kind == TransactionKind.income).fold<double>(0, (s, t) => s + t.amount);

  @override
  List<Object?> get props => [allTransactions, focusedMonth, selectedCalendarDay];
}

final class TransactionsFailure extends TransactionsState {
  const TransactionsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
