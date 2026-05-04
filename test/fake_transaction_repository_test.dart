import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker_app/domain/entities/app_currency.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_kind.dart';

import 'fake_transaction_repository.dart';

void main() {
  test('FakeTransactionRepository adds and returns transactions', () async {
    final repo = FakeTransactionRepository();
    final txn = Transaction(
      id: 'a1',
      title: 'Coffee',
      amount: 4.50,
      date: DateTime(2026, 1, 15),
      kind: TransactionKind.expense,
      currency: AppCurrency.usd,
      categoryKey: 'food',
    );

    await repo.addTransaction(txn);
    final list = await repo.getTransactions();

    expect(list, hasLength(1));
    expect(list.single.title, 'Coffee');
    expect(list.single.amount, 4.50);
  });

  test('FakeTransactionRepository replaces when same id', () async {
    final repo = FakeTransactionRepository();
    final base = Transaction(
      id: 'x',
      title: 'Old',
      amount: 1,
      date: DateTime(2026, 2, 1),
      kind: TransactionKind.expense,
      currency: AppCurrency.usd,
      categoryKey: 'food',
    );
    await repo.addTransaction(base);
    await repo.addTransaction(
      Transaction(
        id: 'x',
        title: 'New',
        amount: 2,
        date: DateTime(2026, 2, 1),
        kind: TransactionKind.expense,
        currency: AppCurrency.usd,
        categoryKey: 'food',
      ),
    );

    final list = await repo.getTransactions();
    expect(list, hasLength(1));
    expect(list.single.title, 'New');
    expect(list.single.amount, 2);
  });

  test('FakeTransactionRepository delete removes id', () async {
    final repo = FakeTransactionRepository();
    await repo.addTransaction(
      Transaction(
        id: 'del',
        title: 'T',
        amount: 1,
        date: DateTime(2026, 3, 1),
        kind: TransactionKind.expense,
        currency: AppCurrency.usd,
        categoryKey: 'food',
      ),
    );
    await repo.deleteTransaction('del');
    expect(await repo.getTransactions(), isEmpty);
  });
}
