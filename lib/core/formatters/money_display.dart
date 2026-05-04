import 'package:personal_expense_tracker_app/domain/entities/transaction.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_kind.dart';

abstract final class MoneyDisplay {
  MoneyDisplay._();

  static String signedAmount(Transaction t) {
    final sign = t.kind == TransactionKind.expense ? '-' : '+';
    return '$sign${t.currency.symbol} ${t.amount.toStringAsFixed(2)}';
  }

  static String plainAmount(Transaction t) => '${t.currency.symbol} ${t.amount.toStringAsFixed(2)}';
}
