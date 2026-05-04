import 'package:equatable/equatable.dart';
import 'package:personal_expense_tracker_app/domain/entities/app_currency.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_kind.dart';

sealed class AddTransactionEvent extends Equatable {
  const AddTransactionEvent();

  @override
  List<Object?> get props => [];
}

final class AddTransactionDigitPressed extends AddTransactionEvent {
  const AddTransactionDigitPressed(this.digit);

  final String digit;

  @override
  List<Object?> get props => [digit];
}

final class AddTransactionDoubleZeroPressed extends AddTransactionEvent {
  const AddTransactionDoubleZeroPressed();
}

final class AddTransactionDotPressed extends AddTransactionEvent {
  const AddTransactionDotPressed();
}

final class AddTransactionBackspacePressed extends AddTransactionEvent {
  const AddTransactionBackspacePressed();
}

final class AddTransactionClearPressed extends AddTransactionEvent {
  const AddTransactionClearPressed();
}

final class AddTransactionKindChanged extends AddTransactionEvent {
  const AddTransactionKindChanged(this.kind);

  final TransactionKind kind;

  @override
  List<Object?> get props => [kind];
}

final class AddTransactionCategorySelected extends AddTransactionEvent {
  const AddTransactionCategorySelected(this.categoryKey);

  final String categoryKey;

  @override
  List<Object?> get props => [categoryKey];
}

final class AddTransactionCurrencyChanged extends AddTransactionEvent {
  const AddTransactionCurrencyChanged(this.currency);

  final AppCurrency currency;

  @override
  List<Object?> get props => [currency];
}

final class AddTransactionDateChanged extends AddTransactionEvent {
  const AddTransactionDateChanged(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

final class AddTransactionExpenseGroupTabChanged extends AddTransactionEvent {
  const AddTransactionExpenseGroupTabChanged(this.groupId);

  final String groupId;

  @override
  List<Object?> get props => [groupId];
}

final class AddTransactionSubmitted extends AddTransactionEvent {
  const AddTransactionSubmitted({required this.title, required this.note});

  final String title;
  final String note;

  @override
  List<Object?> get props => [title, note];
}

final class AddTransactionReset extends AddTransactionEvent {
  const AddTransactionReset();
}

final class AddTransactionInitializeForEdit extends AddTransactionEvent {
  const AddTransactionInitializeForEdit(this.transaction);

  final Transaction transaction;

  @override
  List<Object?> get props => [transaction];
}
