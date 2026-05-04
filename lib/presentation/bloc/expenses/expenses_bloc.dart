import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker_app/domain/repositories/expense_repository.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/expenses/expenses_event.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/expenses/expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  ExpensesBloc({required ExpenseRepository repository})
    : _repository = repository,
      super(const ExpensesInitial()) {
    on<ExpensesRequested>(_onRequested);
    on<ExpensesRefreshRequested>(_onRefreshRequested);
    on<ExpensesSearchQueryChanged>(_onSearchQueryChanged);
    on<ExpensesCategoryFilterChanged>(_onCategoryFilterChanged);
  }

  final ExpenseRepository _repository;

  Future<void> _onRequested(
    ExpensesRequested event,
    Emitter<ExpensesState> emit,
  ) async {
    emit(const ExpensesLoading());
    try {
      final expenses = await _repository.getExpenses();
      if (expenses.isEmpty) {
        emit(const ExpensesEmpty());
      } else {
        emit(ExpensesLoaded(allExpenses: expenses));
      }
    } catch (e) {
      emit(ExpensesFailure('$e'));
    }
  }

  Future<void> _onRefreshRequested(
    ExpensesRefreshRequested event,
    Emitter<ExpensesState> emit,
  ) async {
    final prevQuery = switch (state) {
      ExpensesLoaded(:final searchQuery) => searchQuery,
      _ => '',
    };
    final prevCategory = switch (state) {
      ExpensesLoaded(:final categoryFilter) => categoryFilter,
      _ => null,
    };

    emit(const ExpensesLoading());
    try {
      final expenses = await _repository.getExpenses();
      if (expenses.isEmpty) {
        emit(const ExpensesEmpty());
      } else {
        emit(
          ExpensesLoaded(
            allExpenses: expenses,
            searchQuery: prevQuery,
            categoryFilter: prevCategory,
          ),
        );
      }
    } catch (e) {
      emit(ExpensesFailure('$e'));
    }
  }

  void _onSearchQueryChanged(
    ExpensesSearchQueryChanged event,
    Emitter<ExpensesState> emit,
  ) {
    final current = state;
    if (current is! ExpensesLoaded) return;
    emit(
      ExpensesLoaded(
        allExpenses: current.allExpenses,
        searchQuery: event.query,
        categoryFilter: current.categoryFilter,
      ),
    );
  }

  void _onCategoryFilterChanged(
    ExpensesCategoryFilterChanged event,
    Emitter<ExpensesState> emit,
  ) {
    final current = state;
    if (current is! ExpensesLoaded) return;
    emit(
      ExpensesLoaded(
        allExpenses: current.allExpenses,
        searchQuery: current.searchQuery,
        categoryFilter: event.category,
      ),
    );
  }
}
