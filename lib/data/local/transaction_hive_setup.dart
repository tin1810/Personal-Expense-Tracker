import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_expense_tracker_app/data/mappers/transaction_mapper.dart';
import 'package:personal_expense_tracker_app/data/models/expense_hive_model.dart';
import 'package:personal_expense_tracker_app/data/models/expense_hive_model_adapter.dart';
import 'package:personal_expense_tracker_app/data/models/transaction_hive_model.dart';
import 'package:personal_expense_tracker_app/data/models/transaction_hive_model_adapter.dart';
import 'package:personal_expense_tracker_app/data/repositories/transaction_repository_impl.dart';
import 'package:personal_expense_tracker_app/domain/entities/app_currency.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_kind.dart';

const String _transactionsBoxName = 'transactions_v1';
const String _legacyExpensesBoxName = 'expenses_v2';

/// Initializes Hive, registers adapters
Future<TransactionRepositoryImpl> createHiveTransactionRepository() async {
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(expenseHiveTypeId)) {
    Hive.registerAdapter(ExpenseHiveModelAdapter());
  }
  if (!Hive.isAdapterRegistered(transactionHiveTypeId)) {
    Hive.registerAdapter(TransactionHiveModelAdapter());
  }

  final txBox = await Hive.openBox<TransactionHiveModel>(_transactionsBoxName);
  await _migrateLegacyExpenseBoxIfNeeded(txBox);
  return TransactionRepositoryImpl(box: txBox);
}

Future<void> _migrateLegacyExpenseBoxIfNeeded(Box<TransactionHiveModel> txBox) async {
  final exists = await Hive.boxExists(_legacyExpensesBoxName);
  if (!exists) return;

  final legacy = await Hive.openBox<ExpenseHiveModel>(_legacyExpensesBoxName);
  try {
    for (final key in legacy.keys) {
      final raw = legacy.get(key);
      if (raw == null) continue;
      final id = raw.id;
      if (txBox.containsKey(id)) continue;

      final migrated = Transaction(
        id: raw.id,
        title: raw.title,
        amount: raw.amount,
        date: DateTime.fromMillisecondsSinceEpoch(raw.dateMillis),
        kind: TransactionKind.expense,
        currency: AppCurrency.usd,
        categoryKey: 'expense.${raw.categoryKey}',
        note: null,
      );
      await txBox.put(id, transactionEntityToHive(migrated));
    }
  } finally {
    await legacy.close();
  }
}
