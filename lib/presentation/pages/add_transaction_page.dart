import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker_app/core/constants/app_sizes.dart';
import 'package:personal_expense_tracker_app/core/widgets/reusable_widgets.dart';
import 'package:personal_expense_tracker_app/domain/entities/app_currency.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_category_registry.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_kind.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/add_transaction/add_transaction_bloc.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/add_transaction/add_transaction_event.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/add_transaction/add_transaction_state.dart';
import 'package:personal_expense_tracker_app/presentation/widgets/transaction_keypad.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key, this.transactionToEdit});

  final Transaction? transactionToEdit;

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _title = TextEditingController();
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    final edit = widget.transactionToEdit;
    if (edit != null) {
      _title.text = edit.title;
      _note.text = edit.note ?? '';
      context.read<AddTransactionBloc>().add(AddTransactionInitializeForEdit(edit));
    } else {
      context.read<AddTransactionBloc>().add(const AddTransactionReset());
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(BuildContext context, String label) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    );
  }

  Future<void> _pickCurrency(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppCurrency.values.map((c) {
              return ListTile(
                leading: Text(c.symbol, style: Theme.of(sheetCtx).textTheme.titleLarge),
                title: Text(c.name.toUpperCase()),
                onTap: () {
                  context.read<AddTransactionBloc>().add(AddTransactionCurrencyChanged(c));
                  Navigator.pop(sheetCtx);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && context.mounted) {
      context.read<AddTransactionBloc>().add(AddTransactionDateChanged(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocConsumer<AddTransactionBloc, AddTransactionState>(
          listener: (context, state) {
            if (state is AddTransactionSuccess) {
              Navigator.of(context).pop(widget.transactionToEdit != null);
            }
          },
          builder: (context, state) {
            if (state is AddTransactionSubmitting) {
              return ColoredBox(
                color: scheme.surface,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            if (state is! AddTransactionEditing) {
              return ColoredBox(color: scheme.surface);
            }
            final e = state;
            final bloc = context.read<AddTransactionBloc>();
            final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

            final grid = e.kind == TransactionKind.expense
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSizes.spaceSm),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: TransactionCategoryRegistry.expenseCategoriesForGroup(e.expenseGroupTabId).length,
                    itemBuilder: (ctx, i) {
                      final item = TransactionCategoryRegistry.expenseCategoriesForGroup(e.expenseGroupTabId)[i];
                      final selected = e.categoryKey == item.categoryKey;
                      return _CategoryTile(
                        emoji: item.emoji,
                        label: item.label,
                        selected: selected,
                        onTap: () => bloc.add(AddTransactionCategorySelected(item.categoryKey)),
                      );
                    },
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSizes.spaceSm),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: TransactionCategoryRegistry.incomeCategories.length,
                    itemBuilder: (ctx, i) {
                      final item = TransactionCategoryRegistry.incomeCategories[i];
                      final selected = e.categoryKey == item.categoryKey;
                      return _CategoryTile(
                        emoji: item.emoji,
                        label: item.label,
                        selected: selected,
                        onTap: () => bloc.add(AddTransactionCategorySelected(item.categoryKey)),
                      );
                    },
                  );

            return ColoredBox(
              color: scheme.surface,
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(bottom: keyboardInset + AppSizes.spaceSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSm),
                      child: Row(
                        children: [
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                          if (widget.transactionToEdit != null) ...[
                            Text(
                              'Edit transaction',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                          ] else
                            const Spacer(),
                          TextButton.icon(
                            onPressed: () => _pickDate(context, e.date),
                            icon: const Icon(Icons.calendar_today_outlined, size: 18),
                            label: Text(
                              '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (e.kind == TransactionKind.expense)
                      SizedBox(
                        height: 44,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSm),
                          children: TransactionCategoryRegistry.expenseGroupIds.map((g) {
                            final sel = e.expenseGroupTabId == g;
                            return Padding(
                              padding: const EdgeInsets.only(right: AppSizes.spaceXs),
                              child: ChoiceChip(
                                label: Text(TransactionCategoryRegistry.expenseGroupLabel(g)),
                                selected: sel,
                                showCheckmark: false,
                                onSelected: (_) => bloc.add(AddTransactionExpenseGroupTabChanged(g)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    grid,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _title,
                            decoration: _fieldDecoration(context, 'Title (optional)'),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const AppGap.sm(),
                          TextField(
                            controller: _note,
                            decoration: _fieldDecoration(context, 'Note'),
                            maxLines: 2,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const AppGap.sm(),
                          if (e.validationMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSizes.spaceXs),
                              child: Text(
                                e.validationMessage!,
                                style: TextStyle(color: scheme.error),
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${e.currency.symbol} ${e.amountBuffer}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () => _pickCurrency(context),
                                child: Text(e.currency.name.toUpperCase()),
                              ),
                            ],
                          ),
                          const AppGap.sm(),
                          SegmentedButton<TransactionKind>(
                            segments: const [
                              ButtonSegment(value: TransactionKind.expense, label: Text('Expense')),
                              ButtonSegment(value: TransactionKind.income, label: Text('Income')),
                            ],
                            selected: {e.kind},
                            onSelectionChanged: (s) {
                              if (s.isEmpty) return;
                              bloc.add(AddTransactionKindChanged(s.first));
                            },
                          ),
                        ],
                      ),
                    ),
                    ColoredBox(
                      color: scheme.surface,
                      child: TransactionKeypad(
                        onOk: () => bloc.add(AddTransactionSubmitted(title: _title.text, note: _note.text)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLow,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              width: 1,
              color: selected ? scheme.primary : scheme.outline.withValues(alpha: 0.35),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 2),
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: selected ? FontWeight.bold : FontWeight.w400,
                          height: 1.15,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
