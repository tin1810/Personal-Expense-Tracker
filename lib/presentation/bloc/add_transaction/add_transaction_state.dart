import 'package:equatable/equatable.dart';
import 'package:personal_expense_tracker_app/domain/entities/app_currency.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_kind.dart';
import 'package:personal_expense_tracker_app/presentation/utils/amount_input_buffer.dart';

sealed class AddTransactionState extends Equatable {
  const AddTransactionState();

  @override
  List<Object?> get props => [];
}

final class AddTransactionEditing extends AddTransactionState {
  const AddTransactionEditing({
    this.amountBuffer = AmountInputBuffer.initial,
    this.kind = TransactionKind.expense,
    required this.categoryKey,
    this.currency = AppCurrency.usd,
    required this.date,
    this.validationMessage,
    this.expenseGroupTabId = 'shop',
    this.editingTransactionId,
  });

  final String amountBuffer;
  final TransactionKind kind;
  final String categoryKey;
  final AppCurrency currency;
  final DateTime date;
  final String? validationMessage;
  final String expenseGroupTabId;

  final String? editingTransactionId;

  AddTransactionEditing copyWith({
    String? amountBuffer,
    TransactionKind? kind,
    String? categoryKey,
    AppCurrency? currency,
    DateTime? date,
    String? validationMessage,
    bool clearValidationMessage = false,
    String? expenseGroupTabId,
    String? editingTransactionId,
    bool clearEditingTransactionId = false,
  }) {
    return AddTransactionEditing(
      amountBuffer: amountBuffer ?? this.amountBuffer,
      kind: kind ?? this.kind,
      categoryKey: categoryKey ?? this.categoryKey,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      expenseGroupTabId: expenseGroupTabId ?? this.expenseGroupTabId,
      editingTransactionId:
          clearEditingTransactionId ? null : (editingTransactionId ?? this.editingTransactionId),
      validationMessage: clearValidationMessage ? null : (validationMessage ?? this.validationMessage),
    );
  }

  @override
  List<Object?> get props => [
        amountBuffer,
        kind,
        categoryKey,
        currency,
        date,
        validationMessage,
        expenseGroupTabId,
        editingTransactionId,
      ];
}

final class AddTransactionSubmitting extends AddTransactionState {
  const AddTransactionSubmitting();
}

final class AddTransactionSuccess extends AddTransactionState {
  const AddTransactionSuccess();
}
