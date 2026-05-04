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
    on<TransactionsCalendarDaySelected>(_onCalendarDaySelected);
    on<TransactionsDayFilterCleared>(_onDayFilterCleared);
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
          selectedCalendarDay: null,
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
    DateTime prevMonth = _currentMonthStart();
    DateTime? prevDay;
    final snapshot = state;
    if (snapshot is TransactionsLoaded) {
      prevMonth = snapshot.focusedMonth;
      final d = snapshot.selectedCalendarDay;
      if (d != null && d.year == snapshot.focusedMonth.year && d.month == snapshot.focusedMonth.month) {
        prevDay = DateTime(d.year, d.month, d.day);
      }
    }

    emit(const TransactionsLoading());
    try {
      final list = await _repository.getTransactions();
      emit(
        TransactionsLoaded(
          allTransactions: list,
          focusedMonth: _monthStart(prevMonth),
          selectedCalendarDay: prevDay,
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
        selectedCalendarDay: null,
      ),
    );
  }

  void _onCalendarDaySelected(
    TransactionsCalendarDaySelected event,
    Emitter<TransactionsState> emit,
  ) {
    final current = state;
    if (current is! TransactionsLoaded) return;
    final d = event.day;
    final normalized = DateTime(d.year, d.month, d.day);
    emit(
      TransactionsLoaded(
        allTransactions: current.allTransactions,
        focusedMonth: DateTime(normalized.year, normalized.month),
        selectedCalendarDay: normalized,
      ),
    );
  }

  void _onDayFilterCleared(
    TransactionsDayFilterCleared event,
    Emitter<TransactionsState> emit,
  ) {
    final current = state;
    if (current is! TransactionsLoaded) return;
    emit(
      TransactionsLoaded(
        allTransactions: current.allTransactions,
        focusedMonth: current.focusedMonth,
        selectedCalendarDay: null,
      ),
    );
  }
}
