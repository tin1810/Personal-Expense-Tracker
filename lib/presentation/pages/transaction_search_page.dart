import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:personal_expense_tracker_app/core/constants/app_sizes.dart';
import 'package:personal_expense_tracker_app/core/formatters/money_display.dart';
import 'package:personal_expense_tracker_app/core/theme/app_colors.dart';
import 'package:personal_expense_tracker_app/core/theme/app_text_styles.dart';
import 'package:personal_expense_tracker_app/data/local/search_history_store.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_category_registry.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_kind.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_bloc.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_event.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_state.dart';
import 'package:personal_expense_tracker_app/presentation/pages/transaction_detail_page.dart';

class _DaySection {
  _DaySection({required this.date, required this.transactions});

  final DateTime date;
  final List<Transaction> transactions;
}

/// Bottom-nav tab: search all transactions — styled like the Home screen.
class TransactionSearchPage extends StatefulWidget {
  const TransactionSearchPage({super.key});

  @override
  State<TransactionSearchPage> createState() => _TransactionSearchPageState();
}

class _TransactionSearchPageState extends State<TransactionSearchPage> {
  late final TextEditingController _controller;
  TransactionKind? _kindFilter;
  String? _categoryKeyFilter;
  final DateFormat _dateFmt = DateFormat.yMMMd();
  final DateFormat _dayHeaderFmt = DateFormat.yMMMMd();

  void _rememberSearch(String raw) {
    context.read<SearchHistoryStore>().prepend(raw);
    setState(() {});
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

  List<Transaction> _computeGlobalResults(List<Transaction> all) {
    Iterable<Transaction> items = all;
    if (_kindFilter != null) {
      items = items.where((t) => t.kind == _kindFilter);
    }
    if (_categoryKeyFilter != null) {
      items = items.where((t) => t.categoryKey == _categoryKeyFilter);
    }
    final q = _controller.text.trim().toLowerCase();
    if (q.isEmpty) return [];
    final list = items.where((t) => _transactionMatchesQuery(t, q)).toList(growable: false)
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  bool _transactionMatchesQuery(Transaction t, String q) {
    if (t.title.toLowerCase().contains(q)) return true;
    if ((t.note ?? '').toLowerCase().contains(q)) return true;
    final cat = TransactionCategoryRegistry.resolve(t.kind, t.categoryKey).label.toLowerCase();
    return cat.contains(q);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Color _avatarBackground(Transaction t) {
    if (t.kind == TransactionKind.income) {
      return AppColors.incomeAccent.withValues(alpha: 0.38);
    }
    const warm = [Color(0xFFFF9800), Color(0xFFFF7043), Color(0xFFF4511E)];
    return warm[t.categoryKey.hashCode.abs() % warm.length];
  }

  Widget _chipThemeWrap({required Widget child}) {
    final scheme = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.28)),
          backgroundColor: scheme.surfaceContainerHighest,
          selectedColor: AppColors.homeHeaderBlue.withValues(alpha: 0.22),
          deleteIconColor: scheme.onSurfaceVariant,
          labelStyle: Theme.of(context).textTheme.labelLarge,
          secondaryLabelStyle: Theme.of(context).textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      ),
      child: child,
    );
  }

  Widget _kindChip(String label, TransactionKind? kind, TransactionKind? selected) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.spaceXs),
      child: FilterChip(
        label: Text(label),
        selected: selected == kind,
        showCheckmark: false,
        onSelected: (_) => setState(() {
          _kindFilter = kind;
          _categoryKeyFilter = null;
        }),
      ),
    );
  }

  Widget _categoryRow() {
    final kindFilter = _kindFilter;
    if (kindFilter == null) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSizes.spaceXs),
        child: Row(
          children: [
            Icon(Icons.category_outlined, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Choose Expense or Income to filter by category.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    final chips = <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: AppSizes.spaceXs),
        child: FilterChip(
          label: const Text('All'),
          selected: _categoryKeyFilter == null,
          showCheckmark: false,
          onSelected: (_) => setState(() => _categoryKeyFilter = null),
        ),
      ),
    ];

    if (kindFilter == TransactionKind.expense) {
      for (final item in TransactionCategoryRegistry.expenseCategories.take(20)) {
        chips.add(
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.spaceXs),
            child: FilterChip(
              label: Text(item.label, overflow: TextOverflow.ellipsis),
              selected: _categoryKeyFilter == item.categoryKey,
              showCheckmark: false,
              onSelected: (_) => setState(() {
                _categoryKeyFilter = _categoryKeyFilter == item.categoryKey ? null : item.categoryKey;
              }),
            ),
          ),
        );
      }
    } else {
      for (final item in TransactionCategoryRegistry.incomeCategories) {
        chips.add(
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.spaceXs),
            child: FilterChip(
              label: Text(item.label, overflow: TextOverflow.ellipsis),
              selected: _categoryKeyFilter == item.categoryKey,
              showCheckmark: false,
              onSelected: (_) => setState(() {
                _categoryKeyFilter = _categoryKeyFilter == item.categoryKey ? null : item.categoryKey;
              }),
            ),
          ),
        );
      }
    }

    return SizedBox(
      height: 42,
      child: ListView(scrollDirection: Axis.horizontal, children: chips),
    );
  }

  Widget _searchHeaderField() {
    return Material(
      elevation: 6,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(28),
      color: Colors.white,
      child: TextField(
        controller: _controller,
        style: Theme.of(context).textTheme.bodyLarge,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search title, notes, categories…',
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8)),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.homeHeaderBlue, size: 26),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear',
                  icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  onPressed: () => _controller.clear(),
                ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        ),
        onSubmitted: (value) {
          if (value.trim().isEmpty) return;
          _rememberSearch(value);
        },
      ),
    );
  }

  Widget _blueHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.spaceSm, 4, AppSizes.spaceSm, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find any transaction, any month',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              _circleHeaderBtn(
                icon: Icons.refresh_rounded,
                onTap: () => context.read<TransactionsBloc>().add(const TransactionsRefreshRequested()),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _searchHeaderField(),
        ],
      ),
    );
  }

  Widget _sheetSectionTitle(String title, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: AppColors.homeHeaderBlue),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _historySection() {
    final store = context.read<SearchHistoryStore>();
    final items = store.read();
    final scheme = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.spaceMd, AppSizes.spaceLg, AppSizes.spaceMd, AppSizes.spaceMd),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.homeHeaderBlue.withValues(alpha: 0.15),
              child: Icon(Icons.manage_search_rounded, size: 40, color: AppColors.homeHeaderBlue),
            ),
            const SizedBox(height: AppSizes.spaceMd),
            Text(
              'Start searching',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.spaceXs),
            Text(
              'Matches roll across title, notes, and category names. Recent searches show up here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.spaceSm, AppSizes.spaceSm, AppSizes.spaceSm, AppSizes.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sheetSectionTitle('Recent searches', icon: Icons.history_rounded),
              const Spacer(),
              TextButton(
                onPressed: () {
                  store.clear();
                  setState(() {});
                },
                child: Text('Clear all', style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSm),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final term in items)
                Material(
                  elevation: 0,
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      _controller.text = term;
                      _controller.selection = TextSelection.collapsed(offset: term.length);
                      _rememberSearch(term);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 4, top: 8, bottom: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded, size: 18, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Text(term, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded, size: 18, color: scheme.onSurfaceVariant),
                            onPressed: () {
                              store.remove(term);
                              setState(() {});
                            },
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultsList(BuildContext context, List<Transaction> allTransactions, String q) {
    final results = _computeGlobalResults(allTransactions);
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(Icons.search_off_rounded, size: 36, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSizes.spaceMd),
              Text(
                'No matches',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.spaceXs),
              Text(
                'Nothing found for "$q". Try another keyword or adjust filters.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final sections = _groupByDay(results);

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceLg),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.spaceSm, 4, AppSizes.spaceSm, AppSizes.spaceXs),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.homeHeaderBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.homeHeaderBlue),
                  const SizedBox(width: 8),
                  Text(
                    '${results.length} ${results.length == 1 ? 'result' : 'results'}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.homeHeaderBlue,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        for (final section in sections) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSm, vertical: 10),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _dayHeaderFmt.format(section.date),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
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
                  title: Text(cat.label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: t.title.trim().isEmpty || t.title == cat.label
                      ? Text(
                          '${_dateFmt.format(t.date)} · ${t.kind.name}',
                          style: AppTextStyles.listTileSubtitle(theme.textTheme),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(t.title, style: AppTextStyles.listTileSubtitle(theme.textTheme)),
                            Text(
                              '${_dateFmt.format(t.date)} · ${t.kind.name}',
                              style: AppTextStyles.listTileSubtitle(theme.textTheme),
                            ),
                          ],
                        ),
                  isThreeLine: t.title.trim().isNotEmpty && t.title != cat.label,
                  trailing: Text(
                    signed,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => Navigator.of(ctx).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => TransactionDetailPage(transaction: t),
                        ),
                      ),
                );
              },
            ),
          ],
        ],
      ],
    );
  }

  Widget _filtersPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.spaceSm, AppSizes.spaceMd, AppSizes.spaceSm, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sheetSectionTitle('Filters', icon: Icons.tune_rounded),
          const SizedBox(height: AppSizes.spaceSm),
          Text(
            'Type',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSizes.spaceXs),
          _chipThemeWrap(
            child: SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _kindChip('All', null, _kindFilter),
                  _kindChip('Expense', TransactionKind.expense, _kindFilter),
                  _kindChip('Income', TransactionKind.income, _kindFilter),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          Text(
            'Category',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSizes.spaceXs),
          _chipThemeWrap(child: _categoryRow()),
          const SizedBox(height: AppSizes.spaceSm),
          Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
        ],
      ),
    );
  }

  Widget _buildSheet(BuildContext context, List<Transaction> allTransactions) {
    final q = _controller.text.trim();

    return Material(
      elevation: 8,
      shadowColor: Colors.black26,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSizes.spaceSm),
          _filtersPanel(),
          Expanded(
            child: q.isEmpty ? SingleChildScrollView(child: _historySection()) : _resultsList(context, allTransactions, q),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedBody(BuildContext context, TransactionsLoaded loaded) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(color: AppColors.homeHeaderBlue),
          child: _blueHeader(),
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -18),
            child: _buildSheet(context, loaded.allTransactions),
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
            TransactionsInitial() => const SafeArea(child: SizedBox.expand()),
            TransactionsLoading() => const SafeArea(
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
            TransactionsLoaded() => SafeArea(bottom: false, child: _buildLoadedBody(context, state)),
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
    );
  }
}
