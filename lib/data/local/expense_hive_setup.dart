import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_expense_tracker_app/data/models/expense_hive_model.dart';
import 'package:personal_expense_tracker_app/data/models/expense_hive_model_adapter.dart';
import 'package:personal_expense_tracker_app/data/repositories/expense_repository_impl.dart';

/// New box name after schema added [ExpenseHiveModel.categoryKey] (avoids corrupt reads from legacy rows).
const String _expenseBoxName = 'expenses_v2';

/// Initializes Hive (Flutter), registers adapters, opens the expense box.
Future<ExpenseRepositoryImpl> createHiveExpenseRepository() async {
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(expenseHiveTypeId)) {
    Hive.registerAdapter(ExpenseHiveModelAdapter());
  }

  final box = await Hive.openBox<ExpenseHiveModel>(_expenseBoxName);
  return ExpenseRepositoryImpl(box: box);
}
