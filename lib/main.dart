import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker_app/core/theme/app_colors.dart';
import 'package:personal_expense_tracker_app/data/local/search_history_store.dart';
import 'package:personal_expense_tracker_app/data/local/transaction_hive_setup.dart';
import 'package:personal_expense_tracker_app/domain/repositories/transaction_repository.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/add_transaction/add_transaction_bloc.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/transactions/transactions_bloc.dart';
import 'package:personal_expense_tracker_app/presentation/pages/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final transactionRepository = await createHiveTransactionRepository();
  final searchHistoryStore = await HiveSearchHistoryStore.open();
  runApp(
    PersonalExpenseTrackerApp(
      transactionRepository: transactionRepository,
      searchHistoryStore: searchHistoryStore,
    ),
  );
}

class PersonalExpenseTrackerApp extends StatelessWidget {
  const PersonalExpenseTrackerApp({
    required this.transactionRepository,
    required this.searchHistoryStore,
    super.key,
  });

  final TransactionRepository transactionRepository;
  final SearchHistoryStore searchHistoryStore;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TransactionRepository>.value(value: transactionRepository),
        RepositoryProvider<SearchHistoryStore>.value(value: searchHistoryStore),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TransactionsBloc>(
            create: (ctx) => TransactionsBloc(repository: ctx.read<TransactionRepository>()),
          ),
          BlocProvider<AddTransactionBloc>(
            create: (ctx) => AddTransactionBloc(repository: ctx.read<TransactionRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Personal Expense Tracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.seed),
            
            useMaterial3: true,
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: AppColors.snackbarBackground,
              contentTextStyle: TextStyle(color: Colors.white),
              behavior: SnackBarBehavior.floating,
            ),
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
