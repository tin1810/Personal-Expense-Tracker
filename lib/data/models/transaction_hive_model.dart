/// Hive persistence model for [Transaction].
class TransactionHiveModel {
  TransactionHiveModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.dateMillis,
    required this.currencyCode,
    required this.kindKey,
    required this.categoryKey,
    required this.note,
  });

  final String id;
  final String title;
  final double amount;
  final int dateMillis;
  final String currencyCode;
  final String kindKey;
  final String categoryKey;
  final String note;
}
