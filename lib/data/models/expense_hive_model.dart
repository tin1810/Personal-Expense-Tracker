/// Persistence model for Hive only (data layer).
class ExpenseHiveModel {
  ExpenseHiveModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.dateMillis,
    required this.categoryKey,
  });

  final String id;
  final String title;
  final double amount;
  final int dateMillis;
  final String categoryKey;
}
