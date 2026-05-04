import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:personal_expense_tracker_app/core/constants/app_sizes.dart';
import 'package:personal_expense_tracker_app/core/formatters/money_display.dart';
import 'package:personal_expense_tracker_app/core/router/app_navigator.dart';
import 'package:personal_expense_tracker_app/core/theme/app_colors.dart';
import 'package:personal_expense_tracker_app/core/theme/app_text_styles.dart';
import 'package:personal_expense_tracker_app/core/widgets/reusable_widgets.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_category_registry.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_kind.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_bloc.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_event.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_state.dart';

class TransactionsListPage extends StatefulWidget {
  const TransactionsListPage({super.key});

  @override
  State<TransactionsListPage> createState() => _TransactionsListPageState();
}

class _DaySection {
  _DaySection({required this.date, required this.transactions});

  final DateTime date;
  final List<Transaction> transactions;
}

class _TransactionsListPageState extends State<TransactionsListPage> {
  bool _balanceVisible = true;

  Future<void> _openAdd() async {
    await AppNavigator.pushAddTransaction(context);
    if (!mounted) return;
    context.read<TransactionsBloc>().add(const TransactionsRefreshRequested());
  }

  String _fmtMoney(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(2);
  }

  List<_DaySection> _groupByDay(List<Transaction> txs) {
    final byDay = <DateTime, List<Transaction>>{};
    for (final t in txs) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      byDay.putIfAbsent(d, () => []).add(t);
    }
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final d in days)
        _DaySection(
          date: d,
          transactions: (byDay[d]!..sort((a, b) => b.date.compareTo(a.date))),
        ),
    ];
  }

  Color _avatarBackground(Transaction t) {
    if (t.kind == TransactionKind.income) {
      return AppColors.incomeAccent.withValues(alpha: 0.38);
    }
    const warm = [Color(0xFFFF9800), Color(0xFFFF7043), Color(0xFFF4511E)];
    return warm[t.categoryKey.hashCode.abs() % warm.length];
  }

  DateTime _datePickerInitialDay(TransactionsLoaded state) {
    final picked = state.selectedCalendarDay;
    if (picked != null) {
      return DateTime(picked.year, picked.month, picked.day);
    }
    final focused = state.focusedMonth;
    final now = DateTime.now();
    if (now.year == focused.year && now.month == focused.month) {
      return DateTime(now.year, now.month, now.day);
    }
    return DateTime(focused.year, focused.month, 1);
  }

  Future<void> _pickMonth(TransactionsLoaded state) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _datePickerInitialDay(state),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      context.read<TransactionsBloc>().add(TransactionsCalendarDaySelected(picked));
    }
  }

  void _shiftMonth(TransactionsLoaded state, int delta) {
    final m = state.focusedMonth;
    context.read<TransactionsBloc>().add(TransactionsFocusedMonthChanged(DateTime(m.year, m.month + delta)));
  }

  Widget _circleHeaderBtn({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withValues(alpha: 0.22),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _homeHeader(BuildContext context, TransactionsLoaded state) {
    final expense = state.monthExpenseTotal;
    final income = state.monthIncomeTotal;
    final balance = income - expense;
    final monthFmt = DateFormat.yMMMM();
    final dayFmt = DateFormat.yMMMMd();
    final periodLabel =
        state.selectedCalendarDay != null ? dayFmt.format(state.selectedCalendarDay!) : monthFmt.format(state.focusedMonth);

    final balanceText = !_balanceVisible
        ? '••••'
        : (balance >= 0 ? _fmtMoney(balance) : '-${_fmtMoney(balance.abs())}');

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.spaceSm, 8, AppSizes.spaceSm, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Material(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => _pickMonth(state),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      periodLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              if (state.selectedCalendarDay != null) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Show whole month',
                  child: _circleHeaderBtn(
                    icon: Icons.calendar_view_month_rounded,
                    onTap: () => context.read<TransactionsBloc>().add(const TransactionsDayFilterCleared()),
                  ),
                ),
              ],
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _circleHeaderBtn(icon: Icons.chevron_left, onTap: () => _shiftMonth(state, -1)),
                    const SizedBox(width: 8),
                    _circleHeaderBtn(icon: Icons.chevron_right, onTap: () => _shiftMonth(state, 1)),
                  ],
                ),
              ),
          
          
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Balance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              IconButton(
                onPressed: () => setState(() => _balanceVisible = !_balanceVisible),
                icon: Icon(
                  _balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 22,
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
          Text(
            balanceText,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            !_balanceVisible ? 'Expense: ••••  ·  Income: ••••' : 'Expense: -${_fmtMoney(expense)}  ·  Income: ${_fmtMoney(income)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

 
  Widget _transactionList(BuildContext context, TransactionsLoaded state) {
    final filtered = state.filteredTransactions;
    if (filtered.isEmpty) {
      return LayoutBuilder(
        builder: (ctx, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spaceLg),
                  child: AppEmptyState(
                    icon: state.allTransactions.isEmpty ? Icons.receipt_long_outlined : Icons.manage_search_outlined,
                    title: state.allTransactions.isEmpty
                        ? 'No transactions yet'
                        : (state.selectedCalendarDay != null ? 'No transactions on this day' : 'No transactions this month'),
                    subtitle: state.allTransactions.isEmpty
                        ? 'Tap + to add expense or income.'
                        : (state.selectedCalendarDay != null
                            ? 'Try another date or open the month view.'
                            : 'Try another month.'),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    final sections = _groupByDay(filtered);
    final dayHeaderFmt = DateFormat.yMMMMd();

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceLg),
      children: [
        for (final section in sections) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSm, vertical: 10),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(child: Text(dayHeaderFmt.format(section.date), style: const TextStyle(fontWeight: FontWeight.w600))),
                Builder(
                  builder: (ctx) {
                    final exp = section.transactions.where((t) => t.kind == TransactionKind.expense).fold<double>(0, (s, t) => s + t.amount);
                    final inc = section.transactions.where((t) => t.kind == TransactionKind.income).fold<double>(0, (s, t) => s + t.amount);
                    return Text(
                      'Expense: -${_fmtMoney(exp)} · Income: ${_fmtMoney(inc)}',
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    );
                  },
                ),
              ],
            ),
          ),
          for (final t in section.transactions) ...[
            Builder(
              builder: (ctx) {
                final theme = Theme.of(ctx);
                final cat = TransactionCategoryRegistry.resolve(t.kind, t.categoryKey);
                final signed = MoneyDisplay.signedAmount(t);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSm),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: _avatarBackground(t),
                    child: Text(cat.emoji, style: const TextStyle(fontSize: 20)),
                  ),
                  title: Text(
                    cat.label,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: t.title.trim().isEmpty || t.title == cat.label
                      ? null
                      : Text(t.title, style: AppTextStyles.listTileSubtitle(theme.textTheme)),
                  trailing: Text(
                    signed,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => AppNavigator.pushTransactionDetail(ctx, t),
                );
              },
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildHomeBody(BuildContext context, TransactionsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(color: AppColors.homeHeaderBlue),
          child: _homeHeader(context, state),
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -18),
            child: Material(
              elevation: 8,
              shadowColor: Colors.black26,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              clipBehavior: Clip.antiAlias,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  const SizedBox(height: AppSizes.spaceSm),
                  Expanded(child: _transactionList(context, state)),
                ],
              ),
            ),
          ),
        ),
     
     
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeHeaderBlue,
      body: BlocConsumer<TransactionsBloc, TransactionsState>(
        listener: (context, state) {
          if (state is TransactionsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return switch (state) {
            TransactionsInitial() => const Center(child: SizedBox()),
            TransactionsLoading() => const Center(child: CircularProgressIndicator(color: Colors.white)),
            TransactionsLoaded() => SafeArea(bottom: false, child: _buildHomeBody(context, state)),
            TransactionsFailure() => SafeArea(
              child: ColoredBox(
                color: Colors.white,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.spaceSm),
                    child: Text(state.message, style: AppTextStyles.errorBody(Theme.of(context).textTheme)),
                  ),
                ),
              ),
            ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}

