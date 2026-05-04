import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker_app/domain/entities/expense.dart';
import 'package:personal_expense_tracker_app/domain/repositories/expense_repository.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/add_expense/add_expense_event.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/add_expense/add_expense_state.dart';

class AddExpenseBloc extends Bloc<AddExpenseEvent, AddExpenseState> {
  AddExpenseBloc({required ExpenseRepository repository})
    : _repository = repository,
      super(const AddExpenseInitial()) {
    on<AddExpenseSubmitted>(_onSubmitted);
    on<AddExpenseReset>(_onReset);
  }

  final ExpenseRepository _repository;

  Future<void> _onSubmitted(
    AddExpenseSubmitted event,
    Emitter<AddExpenseState> emit,
  ) async {
    emit(const AddExpenseSubmitting());
    try {
      final expense = Expense(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: event.title,
        amount: event.amount,
        date: event.date,
        category: event.category,
      );
      await _repository.addExpense(expense);
      emit(const AddExpenseSuccess());
    } catch (e) {
      emit(AddExpenseFailure('$e'));
    }
  }

  void _onReset(AddExpenseReset event, Emitter<AddExpenseState> emit) {
    emit(const AddExpenseInitial());
  }
}
