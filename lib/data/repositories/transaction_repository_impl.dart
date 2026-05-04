import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_expense_tracker_app/data/mappers/transaction_mapper.dart';
import 'package:personal_expense_tracker_app/data/models/transaction_hive_model.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction.dart';
import 'package:personal_expense_tracker_app/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({required Box<TransactionHiveModel> box}) : _box = box;

  final Box<TransactionHiveModel> _box;

  @override
  Future<List<Transaction>> getTransactions() async {
    final list = _box.values.map(transactionHiveToEntity).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return List<Transaction>.unmodifiable(list);
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    await _box.put(transaction.id, transactionEntityToHive(transaction));
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
  }

  /// Aggregates totals by category key for charts (same kind filter applied by caller).
  Map<String, double> sumByCategoryKey(List<Transaction> transactions) {
    final map = <String, double>{};
    for (final t in transactions) {
      map[t.categoryKey] = (map[t.categoryKey] ?? 0) + t.amount;
    }
    return map;
  }
}
