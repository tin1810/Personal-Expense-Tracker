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
final class TransactionsFocusedMonthChanged extends TransactionsEvent {
  const TransactionsFocusedMonthChanged(this.month);

  final DateTime month;

  @override
  List<Object?> get props => [month];
}
