import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker_app/core/theme/app_colors.dart';
import 'package:personal_expense_tracker_app/data/local/expense_hive_setup.dart';
import 'package:personal_expense_tracker_app/domain/repositories/expense_repository.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/add_expense/add_expense_bloc.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/expenses/expenses_bloc.dart';
import 'package:personal_expense_tracker_app/presentation/pages/expense_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final expenseRepository = await createHiveExpenseRepository();
  runApp(PersonalExpenseTrackerApp(expenseRepository: expenseRepository));
}

class PersonalExpenseTrackerApp extends StatelessWidget {
  const PersonalExpenseTrackerApp({required this.expenseRepository, super.key});

  final ExpenseRepository expenseRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ExpenseRepository>(
      create: (_) => expenseRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ExpensesBloc>(
            create: (ctx) => ExpensesBloc(repository: ctx.read<ExpenseRepository>()),
          ),
          BlocProvider<AddExpenseBloc>(
            create: (ctx) => AddExpenseBloc(repository: ctx.read<ExpenseRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Personal Expense Tracker',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.seed),
            useMaterial3: true,
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: AppColors.snackbarBackground,
              contentTextStyle: TextStyle(color: Colors.white),
              behavior: SnackBarBehavior.floating,
            ),
          ),
          home: const ExpenseListPage(),
        ),
      ),
    );
  }
}
