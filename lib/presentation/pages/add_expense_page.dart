import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker_app/core/constants/app_sizes.dart';
import 'package:personal_expense_tracker_app/core/widgets/reusable_widgets.dart';
import 'package:personal_expense_tracker_app/domain/entities/expense_category.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/add_expense/add_expense_bloc.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/add_expense/add_expense_event.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/add_expense/add_expense_state.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  ExpenseCategory _category = ExpenseCategory.other;

  @override
  void initState() {
    super.initState();
    context.read<AddExpenseBloc>().add(const AddExpenseReset());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amountParsed = double.tryParse(_amountController.text.trim());
    if (title.isEmpty || amountParsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title and valid amount.')),
      );
      return;
    }
    context.read<AddExpenseBloc>().add(
      AddExpenseSubmitted(
        title: title,
        amount: amountParsed,
        date: _selectedDate,
        category: _category,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add expense')),
      body: BlocConsumer<AddExpenseBloc, AddExpenseState>(
        listener: (context, state) {
          if (state is AddExpenseSuccess) {
            Navigator.of(context).pop();
          }
          if (state is AddExpenseFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final submitting = state is AddExpenseSubmitting;
          return AbsorbPointer(
            absorbing: submitting,
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              children: [
                AppOutlinedTextField(
                  controller: _titleController,
                  label: 'Title',
                  textCapitalization: TextCapitalization.sentences,
                ),
                const AppGap.md(),
                AppOutlinedTextField(
                  controller: _amountController,
                  label: 'Amount',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const AppGap.md(),
                Text('Category', style: Theme.of(context).textTheme.titleSmall),
                const AppGap.sm(),
                Wrap(
                  spacing: AppSizes.spaceXs,
                  runSpacing: AppSizes.spaceXs,
                  children: ExpenseCategory.values.map((c) {
                    return ChoiceChip(
                      label: Text(c.label),
                      selected: _category == c,
                      showCheckmark: false,
                      onSelected: submitting ? null : (_) => setState(() => _category = c),
                    );
                  }).toList(),
                ),
                const AppGap.md(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(
                    '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                  trailing: TextButton(onPressed: submitting ? null : _pickDate, child: const Text('Change')),
                ),
                const AppGap.lg(),
                FilledButton(
                  onPressed: submitting ? null : _submit,
                  child: submitting
                      ? const SizedBox(
                          height: AppSizes.inlineProgressSize,
                          width: AppSizes.inlineProgressSize,
                          child: CircularProgressIndicator(strokeWidth: AppSizes.inlineProgressStroke),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
