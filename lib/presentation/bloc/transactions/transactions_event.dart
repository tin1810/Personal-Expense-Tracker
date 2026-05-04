import 'package:equatable/equatable.dart';

sealed class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

final class TransactionsRequested extends TransactionsEvent {
  const TransactionsRequested();
}

final class TransactionsRefreshRequested extends TransactionsEvent {
  const TransactionsRefreshRequested();
}

/// Calendar month shown on the home screen ([month] may be any day — bloc normalizes to month start).
/// Clears any selected calendar day so the list shows the whole month.
final class TransactionsFocusedMonthChanged extends TransactionsEvent {
  const TransactionsFocusedMonthChanged(this.month);

  final DateTime month;

  @override
  List<Object?> get props => [month];
}

/// User picked a specific date on the home calendar — list and totals narrow to that day within its month.
final class TransactionsCalendarDaySelected extends TransactionsEvent {
  const TransactionsCalendarDaySelected(this.day);

  final DateTime day;

  @override
  List<Object?> get props => [day];
}

/// Show all transactions in [focusedMonth] again (undo single-day filter).
final class TransactionsDayFilterCleared extends TransactionsEvent {
  const TransactionsDayFilterCleared();
}
