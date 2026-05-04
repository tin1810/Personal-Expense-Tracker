enum TransactionKind {
  expense,
  income;

  String get storageKey => name;

  static TransactionKind parse(String key) {
    return TransactionKind.values.firstWhere(
      (v) => v.storageKey == key,
      orElse: () => TransactionKind.expense,
    );
  }
}
