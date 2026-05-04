import 'package:personal_expense_tracker_app/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions();

  Future<void> addTransaction(Transaction transaction);

  Future<void> deleteTransaction(String id);
}
