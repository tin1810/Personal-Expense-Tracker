import 'package:personal_expense_tracker_app/data/models/expense_hive_model.dart';
import 'package:personal_expense_tracker_app/domain/entities/expense.dart';
import 'package:personal_expense_tracker_app/domain/entities/expense_category.dart';

Expense expenseHiveToEntity(ExpenseHiveModel model) {
  return Expense(
    id: model.id,
    title: model.title,
    amount: model.amount,
    date: DateTime.fromMillisecondsSinceEpoch(model.dateMillis),
    category: ExpenseCategory.parse(model.categoryKey),
  );
}

ExpenseHiveModel expenseEntityToHive(Expense entity) {
  return ExpenseHiveModel(
    id: entity.id,
    title: entity.title,
    amount: entity.amount,
    dateMillis: entity.date.millisecondsSinceEpoch,
    categoryKey: entity.category.storageKey,
  );
}
