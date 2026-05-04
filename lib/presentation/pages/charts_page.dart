import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:personal_expense_tracker_app/core/constants/app_sizes.dart';
import 'package:personal_expense_tracker_app/core/theme/app_colors.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_category_registry.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_kind.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_bloc.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_state.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  TransactionKind _chartKind = TransactionKind.expense;

  late DateTime _chartsMonthYear;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _chartsMonthYear = DateTime(n.year, n.month);
  }

  List<Transaction> _transactionsInChartsMonth(List<Transaction> all) {
    final y = _chartsMonthYear.year;
    final m = _chartsMonthYear.month;
    return all.where((t) => t.date.year == y && t.date.month == m).toList(growable: false);
  }

  Future<void> _pickChartsMonthYear(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_chartsMonthYear.year, _chartsMonthYear.month, 15),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select month',
    );
    if (picked != null && mounted) {
      setState(() => _chartsMonthYear = DateTime(picked.year, picked.month));
    }
  }

  void _shiftChartsMonth(int monthDelta) {
    setState(() {
      _chartsMonthYear = DateTime(_chartsMonthYear.year, _chartsMonthYear.month + monthDelta);
    });
  }

  Widget _chartsMonthFilterBar(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = DateFormat.yMMMM().format(_chartsMonthYear);

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceXs, vertical: AppSizes.spaceXxs),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Previous month',
              onPressed: () => _shiftChartsMonth(-1),
              icon: const Icon(Icons.chevron_left_rounded),
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                onTap: () => _pickChartsMonthYear(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 20, color: scheme.primary),
                      const SizedBox(width: AppSizes.spaceXs),
                      Text(
                        label,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: () => _shiftChartsMonth(1),
              icon: const Icon(Icons.chevron_right_rounded),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _kindSegmentedControl() {
    return SegmentedButton<TransactionKind>(
      segments: const [
        ButtonSegment(value: TransactionKind.expense, label: Text('Expense')),
        ButtonSegment(value: TransactionKind.income, label: Text('Income')),
      ],
      selected: {_chartKind},
      onSelectionChanged: (s) {
        if (s.isEmpty) return;
        setState(() => _chartKind = s.first);
      },
    );
  }

  /// Expense/Income tabs + monthly calendar
  Widget _tabsAndMonthOnlyBody(BuildContext context, {required String emptyMessage}) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _kindSegmentedControl(),
          const SizedBox(height: AppSizes.spaceMd),
          _chartsMonthFilterBar(context),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spaceMd),
                child: Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _sliceColor(TransactionKind kind, int index) {
    if (kind == TransactionKind.expense) {
      return Colors.primaries[index % Colors.primaries.length];
    }
    final palette = AppColors.incomeChartPalette;
    return palette[index % palette.length];
  }

  Map<String, double> _aggregateByCategory(List<Transaction> list, TransactionKind kind) {
    final map = <String, double>{};
    for (final t in list.where((e) => e.kind == kind)) {
      map[t.categoryKey] = (map[t.categoryKey] ?? 0) + t.amount;
    }
    return map;
  }

  List<({String categoryKey, double value})> _orderedCategoriesForKind(List<Transaction> monthTx, TransactionKind kind) {
    final agg = _aggregateByCategory(monthTx, kind);
    final keys = switch (kind) {
      TransactionKind.expense => TransactionCategoryRegistry.expenseCategories.map((e) => e.categoryKey).toList(),
      TransactionKind.income => TransactionCategoryRegistry.incomeCategories.map((e) => e.categoryKey).toList(),
    };
    final rows = <({String categoryKey, double value})>[
      for (final k in keys) (categoryKey: k, value: agg[k] ?? 0),
    ];
    final sum = rows.fold<double>(0, (s, r) => s + r.value);
    if (sum > 0) {
      rows.sort((a, b) => b.value.compareTo(a.value));
    } else {
      rows.sort(
        (a, b) => TransactionCategoryRegistry.resolve(kind, a.categoryKey).label.compareTo(
              TransactionCategoryRegistry.resolve(kind, b.categoryKey).label,
            ),
      );
    }
    return rows;
  }

  Widget _categoryListTile({
    required TransactionKind kind,
    required String categoryKey,
    required double value,
    required double chartTotal,
    required int colorIndex,
  }) {
    final cat = TransactionCategoryRegistry.resolve(kind, categoryKey);
    final color = _sliceColor(kind, colorIndex);
    final trailing = chartTotal > 0
        ? '${(value / chartTotal * 100).toStringAsFixed(1)}% · ${value.toStringAsFixed(2)}'
        : value.toStringAsFixed(2);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceXs),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.35),
        radius: 20,
        child: Text(cat.emoji, style: const TextStyle(fontSize: 18)),
      ),
      title: Text(cat.label),
      trailing: Text(trailing, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts'),
      
      ),
      body: BlocBuilder<TransactionsBloc, TransactionsState>(
        builder: (context, state) {
          if (state is TransactionsLoading || state is TransactionsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TransactionsFailure) {
            return Center(child: Text(state.message));
          }
          if (state is! TransactionsLoaded) {
            return const SizedBox.shrink();
          }

          if (state.allTransactions.isEmpty) {
            return _tabsAndMonthOnlyBody(context, emptyMessage: 'Nothing found.');
          }

          final monthTx = _transactionsInChartsMonth(state.allTransactions);
          final expenseMonthTotal =
              monthTx.where((t) => t.kind == TransactionKind.expense).fold<double>(0, (s, t) => s + t.amount);
          final incomeMonthTotal =
              monthTx.where((t) => t.kind == TransactionKind.income).fold<double>(0, (s, t) => s + t.amount);
          final noExpenseNoIncome = expenseMonthTotal <= 0 && incomeMonthTotal <= 0;

          if (noExpenseNoIncome) {
            return _tabsAndMonthOnlyBody(context, emptyMessage: 'Nothing found for this month.');
          }

          final pieRows =
              _orderedCategoriesForKind(monthTx, _chartKind).where((r) => r.value > 0).toList(growable: false);
          final chartTotal = pieRows.fold<double>(0, (s, r) => s + r.value);

          if (pieRows.isEmpty || chartTotal <= 0) {
            final label = _chartKind == TransactionKind.expense ? 'expense' : 'income';
            return _tabsAndMonthOnlyBody(
              context,
              emptyMessage: 'Nothing found for $label this month.',
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppSizes.spaceSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _kindSegmentedControl(),
                const SizedBox(height: AppSizes.spaceMd),
                _chartsMonthFilterBar(context),
                const SizedBox(height: AppSizes.spaceMd),
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 52,
                      sections: [
                        for (var i = 0; i < pieRows.length; i++)
                          PieChartSectionData(
                            color: _sliceColor(_chartKind, i),
                            value: pieRows[i].value,
                            title: '${(pieRows[i].value / chartTotal * 100).toStringAsFixed(1)}%',
                            radius: 58,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Text(
                  'Total: ${chartTotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spaceSm),
                Text(
                  _chartKind == TransactionKind.expense ? 'Expense categories' : 'Income categories',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.spaceXs),
                Expanded(
                  child: ListView.builder(
                    itemCount: pieRows.length,
                    itemBuilder: (context, i) {
                      final r = pieRows[i];
                      return _categoryListTile(
                        kind: _chartKind,
                        categoryKey: r.categoryKey,
                        value: r.value,
                        chartTotal: chartTotal,
                        colorIndex: i,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
