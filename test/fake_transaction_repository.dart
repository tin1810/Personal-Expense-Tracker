import 'package:personal_expense_tracker_app/domain/entities/transaction.dart';
import 'package:personal_expense_tracker_app/domain/repositories/transaction_repository.dart';

/// In-memory repo for tests (no Hive).
class FakeTransactionRepository implements TransactionRepository {
  final List<Transaction> _items = [];

  @override
  Future<List<Transaction>> getTransactions() async => List<Transaction>.unmodifiable(_items);

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final i = _items.indexWhere((e) => e.id == transaction.id);
    if (i >= 0) {
      _items[i] = transaction;
    } else {
      _items.add(transaction);
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _items.removeWhere((e) => e.id == id);
  }
}
