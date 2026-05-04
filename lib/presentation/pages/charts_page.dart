import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker_app/core/constants/app_sizes.dart';
import 'package:personal_expense_tracker_app/core/theme/app_colors.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_category_registry.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_kind.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_bloc.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_event.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_state.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  TransactionKind _chartKind = TransactionKind.expense;

  Color _sliceColor(int index) {
    if (_chartKind == TransactionKind.expense) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => context.read<TransactionsBloc>().add(const TransactionsRefreshRequested()),
            icon: const Icon(Icons.refresh),
          ),
        ],
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
            return const Center(child: Text('Add transactions to see charts.'));
          }

          final agg = _aggregateByCategory(state.allTransactions, _chartKind);
          final entries = agg.entries.where((e) => e.value > 0).toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final total = entries.fold<double>(0, (s, e) => s + e.value);

          return Padding(
            padding: const EdgeInsets.all(AppSizes.spaceSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<TransactionKind>(
                  segments: const [
                    ButtonSegment(value: TransactionKind.expense, label: Text('Expense')),
                    ButtonSegment(value: TransactionKind.income, label: Text('Income')),
                  ],
                  selected: {_chartKind},
                  onSelectionChanged: (s) {
                    if (s.isEmpty) return;
                    setState(() => _chartKind = s.first);
                  },
                ),
                const SizedBox(height: AppSizes.spaceMd),
                if (entries.isEmpty || total <= 0)
                  const Expanded(child: Center(child: Text('No data for this type.')))
                else
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 220,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 52,
                              sections: [
                                for (var i = 0; i < entries.length; i++)
                                  PieChartSectionData(
                                    color: _sliceColor(i),
                                    value: entries[i].value,
                                    title: '${(entries[i].value / total * 100).toStringAsFixed(1)}%',
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
                          'Total: ${total.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.spaceSm),
                        Expanded(
                          child: ListView.builder(
                            itemCount: entries.length,
                            itemBuilder: (context, i) {
                              final e = entries[i];
                              final pct = (e.value / total * 100).toStringAsFixed(1);
                              final label =
                                  TransactionCategoryRegistry.resolve(_chartKind, e.key).label;
                              final color = _sliceColor(i);
                              return ListTile(
                                leading: CircleAvatar(backgroundColor: color, radius: 8),
                                title: Text(label),
                                trailing: Text('$pct% · ${e.value.toStringAsFixed(2)}'),
                              );
                            },
                          ),
                        ),
                      ],
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
