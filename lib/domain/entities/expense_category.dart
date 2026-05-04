/// Fixed expense categories persisted by [ExpenseCategory.storageKey].
enum ExpenseCategory {
  food,
  transport,
  shopping,
  bills,
  entertainment,
  health,
  other;

  /// Stable Hive / JSON key — do not rename lightly (migration required).
  String get storageKey => name;

  static ExpenseCategory parse(String key) {
    for (final v in ExpenseCategory.values) {
      if (v.storageKey == key) return v;
    }
    return ExpenseCategory.other;
  }
}

extension ExpenseCategoryUi on ExpenseCategory {
  String get label => switch (this) {
        ExpenseCategory.food => 'Food',
        ExpenseCategory.transport => 'Transport',
        ExpenseCategory.shopping => 'Shopping',
        ExpenseCategory.bills => 'Bills',
        ExpenseCategory.entertainment => 'Entertainment',
        ExpenseCategory.health => 'Health',
        ExpenseCategory.other => 'Other',
      };
}
