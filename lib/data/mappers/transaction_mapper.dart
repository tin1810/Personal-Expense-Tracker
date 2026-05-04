import 'package:personal_expense_tracker_app/data/models/transaction_hive_model.dart';
import 'package:personal_expense_tracker_app/domain/entities/app_currency.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction_kind.dart';

Transaction transactionHiveToEntity(TransactionHiveModel model) {
  return Transaction(
    id: model.id,
    title: model.title,
    amount: model.amount,
    date: DateTime.fromMillisecondsSinceEpoch(model.dateMillis),
    kind: TransactionKind.parse(model.kindKey),
    currency: AppCurrency.parse(model.currencyCode),
    categoryKey: model.categoryKey,
    note: model.note.isEmpty ? null : model.note,
  );
}

TransactionHiveModel transactionEntityToHive(Transaction entity) {
  return TransactionHiveModel(
    id: entity.id,
    title: entity.title,
    amount: entity.amount,
    dateMillis: entity.date.millisecondsSinceEpoch,
    currencyCode: entity.currency.storageKey,
    kindKey: entity.kind.storageKey,
    categoryKey: entity.categoryKey,
    note: entity.note ?? '',
  );
}
