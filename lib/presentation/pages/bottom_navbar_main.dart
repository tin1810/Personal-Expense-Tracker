import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_bloc.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_event.dart';
import 'package:personal_expense_tracker_app/presentation/pages/charts_page.dart';
import 'package:personal_expense_tracker_app/presentation/pages/transaction_search_page.dart';
import 'package:personal_expense_tracker_app/presentation/pages/transactions_list_page.dart';

class BottomNavbarMain extends StatefulWidget {
  const BottomNavbarMain({super.key});

  @override
  State<BottomNavbarMain> createState() => _BottomNavbarMainState();
}

class _BottomNavbarMainState extends State<BottomNavbarMain> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TransactionsBloc>().add(const TransactionsRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          TransactionsListPage(),
          TransactionSearchPage(),
          ChartsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart_rounded),
            label: 'Charts',
          ),
        ],
      ),
    );
  }
}
