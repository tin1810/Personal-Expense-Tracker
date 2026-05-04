import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker_app/core/constants/app_sizes.dart';
import 'package:personal_expense_tracker_app/core/theme/app_text_styles.dart';
import 'package:personal_expense_tracker_app/core/widgets/reusable_widgets.dart';
import 'package:personal_expense_tracker_app/domain/entities/expense_category.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/expenses/expenses_bloc.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/expenses/expenses_event.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/expenses/expenses_state.dart';
import 'package:personal_expense_tracker_app/presentation/pages/add_expense_page.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ExpensesBloc>().add(const ExpensesRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddExpense() async {
    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => const AddExpensePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
    if (!mounted) return;
    context.read<ExpensesBloc>().add(const ExpensesRefreshRequested());
  }

  Widget _buildLoadedBody(BuildContext context, ExpensesLoaded state) {
    final filtered = state.filteredExpenses;
    final scheme = Theme.of(context).colorScheme;
    final animationKey = '${state.filteredTotal}_${filtered.length}_${state.searchQuery}_${state.categoryFilter?.storageKey ?? 'all'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const OfflineFirstBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.spaceSm, AppSizes.spaceSm, AppSizes.spaceSm, 0),
          child: AppOutlinedTextField(
            controller: _searchController,
            hintText: 'Search by title',
            prefixIcon: Icon(Icons.search, color: scheme.onSurfaceVariant),
            onChanged: (value) => context.read<ExpensesBloc>().add(ExpensesSearchQueryChanged(value)),
          ),
        ),
        const SizedBox(height: AppSizes.spaceXs),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSm),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: AppSizes.spaceXs),
                child: FilterChip(
                  label: const Text('All'),
                  selected: state.categoryFilter == null,
                  showCheckmark: false,
                  onSelected: (_) {
                    context.read<ExpensesBloc>().add(const ExpensesCategoryFilterChanged(null));
                  },
                ),
              ),
              ...ExpenseCategory.values.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSizes.spaceXs),
                  child: FilterChip(
                    label: Text(c.label),
                    selected: state.categoryFilter == c,
                    showCheckmark: false,
                    onSelected: (_) {
                      context.read<ExpensesBloc>().add(ExpensesCategoryFilterChanged(state.categoryFilter == c ? null : c));
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        ExpenseSummaryCard(total: state.filteredTotal, visibleCount: filtered.length, animationKey: animationKey),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: filtered.isEmpty
                ? Center(
                    key: const ValueKey<String>('no_matches'),
                    child: AppEmptyState(
                      icon: Icons.manage_search_outlined,
                      title: 'No matching expenses',
                      subtitle: state.allExpenses.isEmpty
                          ? null
                          : 'Try another search or category filter.',
                    ),
                  )
                : ListView.builder(
                    key: ValueKey<int>(filtered.length),
                    padding: const EdgeInsets.only(bottom: AppSizes.spaceLg),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final e = filtered[index];
                      final theme = Theme.of(context);
                      return ListTile(
                        key: ValueKey<String>(e.id),
                        title: Text(e.title, style: AppTextStyles.listTileTitle(theme.textTheme)),
                        subtitle: Text(
                          '${e.category.label} · ${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')} · ${e.amount.toStringAsFixed(2)}',
                          style: AppTextStyles.listTileSubtitle(theme.textTheme),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Expense Tracker')),
      body: BlocConsumer<ExpensesBloc, ExpensesState>(
        listener: (context, state) {
          if (state is ExpensesFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return switch (state) {
            ExpensesInitial() => const Center(child: Text('Getting ready…')),
            ExpensesLoading() => const Center(child: CircularProgressIndicator()),
            ExpensesEmpty() => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const OfflineFirstBanner(),
                const Expanded(
                  child: AppEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No expenses yet',
                    subtitle: 'Tap + to add your first expense.',
                  ),
                ),
              ],
            ),
            ExpensesLoaded() => _buildLoadedBody(context, state),
            ExpensesFailure() => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spaceSm),
                child: Text(state.message, style: AppTextStyles.errorBody(Theme.of(context).textTheme)),
              ),
            ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpense,
        tooltip: 'Add expense',
        child: const Icon(Icons.add),
      ),
    );
  }
}
