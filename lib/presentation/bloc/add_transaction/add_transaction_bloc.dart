import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_category_registry.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_kind.dart';
import 'package:personal_expense_tracker_app/domain/repositories/transaction_repository.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/add_transaction/add_transaction_event.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/add_transaction/add_transaction_state.dart';
import 'package:personal_expense_tracker_app/presentation/utils/amount_input_buffer.dart';

class AddTransactionBloc extends Bloc<AddTransactionEvent, AddTransactionState> {
  AddTransactionBloc({required TransactionRepository repository})
    : _repository = repository,
      super(
        AddTransactionEditing(
          categoryKey: TransactionCategoryRegistry.defaultCategoryKey(TransactionKind.expense),
          date: DateTime.now(),
        ),
      ) {
    on<AddTransactionDigitPressed>(_onDigit);
    on<AddTransactionDoubleZeroPressed>(_onDoubleZero);
    on<AddTransactionDotPressed>(_onDot);
    on<AddTransactionBackspacePressed>(_onBackspace);
    on<AddTransactionClearPressed>(_onClear);
    on<AddTransactionKindChanged>(_onKind);
    on<AddTransactionCategorySelected>(_onCategory);
    on<AddTransactionCurrencyChanged>(_onCurrency);
    on<AddTransactionDateChanged>(_onDate);
    on<AddTransactionExpenseGroupTabChanged>(_onExpenseTab);
    on<AddTransactionSubmitted>(_onSubmit);
    on<AddTransactionReset>(_onReset);
    on<AddTransactionInitializeForEdit>(_onInitializeForEdit);
  }

  final TransactionRepository _repository;

  void _onDigit(AddTransactionDigitPressed event, Emitter<AddTransactionState> emit) {
    if (state is! AddTransactionEditing) return;
    final e = state as AddTransactionEditing;
    final next = AmountInputBuffer.applyDigit(e.amountBuffer, event.digit);
    emit(e.copyWith(amountBuffer: next, clearValidationMessage: true));
  }

  void _onDoubleZero(AddTransactionDoubleZeroPressed event, Emitter<AddTransactionState> emit) {
    if (state is! AddTransactionEditing) return;
    final e = state as AddTransactionEditing;
    emit(e.copyWith(amountBuffer: AmountInputBuffer.applyDoubleZero(e.amountBuffer), clearValidationMessage: true));
  }

  void _onDot(AddTransactionDotPressed event, Emitter<AddTransactionState> emit) {
    if (state is! AddTransactionEditing) return;
    final e = state as AddTransactionEditing;
    emit(e.copyWith(amountBuffer: AmountInputBuffer.applyDot(e.amountBuffer), clearValidationMessage: true));
  }

  void _onBackspace(AddTransactionBackspacePressed event, Emitter<AddTransactionState> emit) {
    if (state is! AddTransactionEditing) return;
    final e = state as AddTransactionEditing;
    emit(e.copyWith(amountBuffer: AmountInputBuffer.applyBackspace(e.amountBuffer), clearValidationMessage: true));
  }

  void _onClear(AddTransactionClearPressed event, Emitter<AddTransactionState> emit) {
    if (state is! AddTransactionEditing) return;
    final e = state as AddTransactionEditing;
    emit(e.copyWith(amountBuffer: AmountInputBuffer.applyAc(), clearValidationMessage: true));
  }

  void _onKind(AddTransactionKindChanged event, Emitter<AddTransactionState> emit) {
    if (state is! AddTransactionEditing) return;
    final e = state as AddTransactionEditing;
    final nextKind = event.kind;
    emit(
      e.copyWith(
        kind: nextKind,
        categoryKey: TransactionCategoryRegistry.defaultCategoryKey(nextKind),
        clearValidationMessage: true,
      ),
    );
  }

  void _onCategory(AddTransactionCategorySelected event, Emitter<AddTransactionState> emit) {
    if (state is! AddTransactionEditing) return;
    final e = state as AddTransactionEditing;
    emit(e.copyWith(categoryKey: event.categoryKey, clearValidationMessage: true));
  }

  void _onCurrency(AddTransactionCurrencyChanged event, Emitter<AddTransactionState> emit) {
    if (state is! AddTransactionEditing) return;
    final e = state as AddTransactionEditing;
    emit(e.copyWith(currency: event.currency, clearValidationMessage: true));
  }

  void _onDate(AddTransactionDateChanged event, Emitter<AddTransactionState> emit) {
    if (state is! AddTransactionEditing) return;
    final e = state as AddTransactionEditing;
    emit(e.copyWith(date: event.date, clearValidationMessage: true));
  }

  void _onExpenseTab(AddTransactionExpenseGroupTabChanged event, Emitter<AddTransactionState> emit) {
    if (state is! AddTransactionEditing) return;
    final e = state as AddTransactionEditing;
    emit(e.copyWith(expenseGroupTabId: event.groupId, clearValidationMessage: true));
  }

  void _onInitializeForEdit(AddTransactionInitializeForEdit event, Emitter<AddTransactionState> emit) {
    final t = event.transaction;
    final tabId =
        t.kind == TransactionKind.expense ? TransactionCategoryRegistry.expenseGroupIdForCategoryKey(t.categoryKey) : 'shop';
    emit(
      AddTransactionEditing(
        editingTransactionId: t.id,
        amountBuffer: AmountInputBuffer.fromAmount(t.amount),
        kind: t.kind,
        categoryKey: t.categoryKey,
        currency: t.currency,
        date: t.date,
        expenseGroupTabId: tabId,
      ),
    );
  }

  Future<void> _onSubmit(AddTransactionSubmitted event, Emitter<AddTransactionState> emit) async {
    if (state is! AddTransactionEditing) return;
    final snapshot = state as AddTransactionEditing;
    final parsed = double.tryParse(snapshot.amountBuffer);
    if (parsed == null || parsed <= 0) {
      emit(snapshot.copyWith(validationMessage: 'Enter an amount greater than zero.'));
      return;
    }

    final display = TransactionCategoryRegistry.resolve(snapshot.kind, snapshot.categoryKey);
    final title = event.title.trim().isEmpty ? display.label : event.title.trim();

    emit(const AddTransactionSubmitting());
    try {
      final id = snapshot.editingTransactionId ?? DateTime.now().microsecondsSinceEpoch.toString();
      final txn = Transaction(
        id: id,
        title: title,
        amount: parsed,
        date: snapshot.date,
        kind: snapshot.kind,
        currency: snapshot.currency,
        categoryKey: snapshot.categoryKey,
        note: event.note.trim().isEmpty ? null : event.note.trim(),
      );
      await _repository.addTransaction(txn);
      emit(const AddTransactionSuccess());
    } catch (err) {
      emit(
        AddTransactionEditing(
          editingTransactionId: snapshot.editingTransactionId,
          amountBuffer: snapshot.amountBuffer,
          kind: snapshot.kind,
          categoryKey: snapshot.categoryKey,
          currency: snapshot.currency,
          date: snapshot.date,
          expenseGroupTabId: snapshot.expenseGroupTabId,
          validationMessage: 'Could not save: $err',
        ),
      );
    }
  }

  void _onReset(AddTransactionReset event, Emitter<AddTransactionState> emit) {
    emit(
      AddTransactionEditing(
        categoryKey: TransactionCategoryRegistry.defaultCategoryKey(TransactionKind.expense),
        date: DateTime.now(),
      ),
    );
  }
}
