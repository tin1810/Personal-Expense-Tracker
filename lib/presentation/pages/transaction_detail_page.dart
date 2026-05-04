import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:personal_expense_tracker_app/core/constants/app_sizes.dart';
import 'package:personal_expense_tracker_app/core/formatters/money_display.dart';
import 'package:personal_expense_tracker_app/core/theme/app_colors.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_category_registry.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_kind.dart';
import 'package:personal_expense_tracker_app/domain/repositories/transaction_repository.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_bloc.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_event.dart';
import 'package:personal_expense_tracker_app/presentation/pages/add_transaction_page.dart';

class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({required this.transaction, super.key});

  final Transaction transaction;

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await context.read<TransactionRepository>().deleteTransaction(transaction.id);
    if (!context.mounted) return;
    context.read<TransactionsBloc>().add(const TransactionsRefreshRequested());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final cat = TransactionCategoryRegistry.resolve(t.kind, t.categoryKey);
    final df = DateFormat.yMMMd().add_jm();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Theme.of(context).colorScheme.error,
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.spaceSm),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spaceMd),
              child: Row(
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: AppSizes.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          MoneyDisplay.signedAmount(t),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: t.kind == TransactionKind.expense
                                    ? Theme.of(context).colorScheme.error
                                    : AppColors.incomeAccent,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          _DetailRow(label: 'Category', value: '${cat.label} (${t.kind.name})'),
          _DetailRow(label: 'Date', value: df.format(t.date)),
          _DetailRow(label: 'Currency', value: t.currency.name.toUpperCase()),
          _DetailRow(label: 'Amount', value: MoneyDisplay.plainAmount(t)),
          _DetailRow(label: 'Remark', value: t.note?.isNotEmpty == true ? t.note! : '—'),
          const SizedBox(height: AppSizes.spaceLg),
          FilledButton(
            onPressed: () async {
              final saved = await Navigator.of(context).push<bool>(
                PageRouteBuilder<bool>(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      AddTransactionPage(transactionToEdit: t),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
              );
              if (!context.mounted) return;
              context.read<TransactionsBloc>().add(const TransactionsRefreshRequested());
              if (saved == true) Navigator.of(context).pop();
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
