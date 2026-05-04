import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker_app/domain/repositories/transaction_repository.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_event.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc({required TransactionRepository repository})
    : _repository = repository,
      super(const TransactionsInitial()) {
    on<TransactionsRequested>(_onRequested);
    on<TransactionsRefreshRequested>(_onRefreshRequested);
    on<TransactionsFocusedMonthChanged>(_onFocusedMonthChanged);
  }

  final TransactionRepository _repository;

  DateTime _monthStart(DateTime d) => DateTime(d.year, d.month);

  DateTime _currentMonthStart() {
    final n = DateTime.now();
    return DateTime(n.year, n.month);
  }

  Future<void> _onRequested(
    TransactionsRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(const TransactionsLoading());
    try {
      final list = await _repository.getTransactions();
      emit(
        TransactionsLoaded(
          allTransactions: list,
          focusedMonth: _currentMonthStart(),
        ),
      );
    } catch (e) {
      emit(TransactionsFailure('$e'));
    }
  }

  Future<void> _onRefreshRequested(
    TransactionsRefreshRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    final prevMonth = switch (state) {
      TransactionsLoaded(:final focusedMonth) => focusedMonth,
      _ => _currentMonthStart(),
    };

    emit(const TransactionsLoading());
    try {
      final list = await _repository.getTransactions();
      emit(
        TransactionsLoaded(
          allTransactions: list,
          focusedMonth: prevMonth,
        ),
      );
    } catch (e) {
      emit(TransactionsFailure('$e'));
    }
  }

  void _onFocusedMonthChanged(
    TransactionsFocusedMonthChanged event,
    Emitter<TransactionsState> emit,
  ) {
    final current = state;
    if (current is! TransactionsLoaded) return;
    emit(
      TransactionsLoaded(
        allTransactions: current.allTransactions,
        focusedMonth: _monthStart(event.month),
      ),
    );
  }
}
