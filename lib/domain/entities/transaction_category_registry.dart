import 'package:personal_expense_tracker_app/domain/entities/transaction_kind.dart';

class ExpenseCategoryItem {
  const ExpenseCategoryItem({
    required this.categoryKey,
    required this.label,
    required this.emoji,
    required this.groupId,
  });

  /// Full key: `expense.<slug>`.
  final String categoryKey;
  final String label;
  final String emoji;
  final String groupId;
}

/// Income category tile.
class IncomeCategoryItem {
  const IncomeCategoryItem({
    required this.categoryKey,
    required this.label,
    required this.emoji,
  });

  final String categoryKey;
  final String label;
  final String emoji;
}

class CategoryDisplay {
  const CategoryDisplay({required this.emoji, required this.label});

  final String emoji;
  final String label;
}

/// Static registries
abstract final class TransactionCategoryRegistry {
  TransactionCategoryRegistry._();

  static const List<String> expenseGroupIds = ['shop', 'eat', 'traffic', 'play', 'life'];

  static String expenseGroupLabel(String groupId) => switch (groupId) {
        'shop' => 'Shop',
        'eat' => 'Eat',
        'traffic' => 'Traffic',
        'play' => 'Play',
        'life' => 'Life',
        _ => groupId,
      };

  static final List<ExpenseCategoryItem> expenseCategories = [
    // shop
    const ExpenseCategoryItem(categoryKey: 'expense.other_shop', label: 'Other shop', emoji: '🛒', groupId: 'shop'),
    const ExpenseCategoryItem(categoryKey: 'expense.toy', label: 'Toy', emoji: '🧸', groupId: 'shop'),
    const ExpenseCategoryItem(categoryKey: 'expense.bag', label: 'Bag', emoji: '👜', groupId: 'shop'),
    const ExpenseCategoryItem(categoryKey: 'expense.food_grocery', label: 'Food', emoji: '🥕', groupId: 'shop'),
    const ExpenseCategoryItem(categoryKey: 'expense.baby', label: 'Baby', emoji: '🍼', groupId: 'shop'),
    const ExpenseCategoryItem(categoryKey: 'expense.gift', label: 'Gift', emoji: '🎀', groupId: 'shop'),
    const ExpenseCategoryItem(categoryKey: 'expense.daily', label: 'Daily', emoji: '🪥', groupId: 'shop'),
    const ExpenseCategoryItem(categoryKey: 'expense.snacks', label: 'Snacks', emoji: '🥜', groupId: 'shop'),
    const ExpenseCategoryItem(categoryKey: 'expense.sports', label: 'Sports', emoji: '🎾', groupId: 'shop'),
    const ExpenseCategoryItem(categoryKey: 'expense.clothing', label: 'Clothing', emoji: '👕', groupId: 'shop'),
    const ExpenseCategoryItem(categoryKey: 'expense.electronics', label: 'Electronics', emoji: '💻', groupId: 'shop'),
    const ExpenseCategoryItem(categoryKey: 'expense.cosmetic', label: 'Cosmetic', emoji: '💄', groupId: 'shop'),
    // eat
    const ExpenseCategoryItem(categoryKey: 'expense.restaurant', label: 'Restaurant', emoji: '🍽️', groupId: 'eat'),
    const ExpenseCategoryItem(categoryKey: 'expense.coffee', label: 'Coffee', emoji: '☕', groupId: 'eat'),
    const ExpenseCategoryItem(categoryKey: 'expense.takeout', label: 'Takeout', emoji: '🥡', groupId: 'eat'),
    const ExpenseCategoryItem(categoryKey: 'expense.drinks', label: 'Drinks', emoji: '🧋', groupId: 'eat'),
    // traffic
    const ExpenseCategoryItem(categoryKey: 'expense.fuel', label: 'Fuel', emoji: '⛽', groupId: 'traffic'),
    const ExpenseCategoryItem(categoryKey: 'expense.taxi', label: 'Taxi', emoji: '🚕', groupId: 'traffic'),
    const ExpenseCategoryItem(categoryKey: 'expense.parking', label: 'Parking', emoji: '🅿️', groupId: 'traffic'),
    const ExpenseCategoryItem(categoryKey: 'expense.transit', label: 'Transit', emoji: '🚌', groupId: 'traffic'),
    // play
    const ExpenseCategoryItem(categoryKey: 'expense.games', label: 'Games', emoji: '🎮', groupId: 'play'),
    const ExpenseCategoryItem(categoryKey: 'expense.movies', label: 'Movies', emoji: '🎬', groupId: 'play'),
    const ExpenseCategoryItem(categoryKey: 'expense.music', label: 'Music', emoji: '🎵', groupId: 'play'),
    const ExpenseCategoryItem(categoryKey: 'expense.travel_fun', label: 'Travel', emoji: '✈️', groupId: 'play'),
    // life
    const ExpenseCategoryItem(categoryKey: 'expense.rent', label: 'Rent', emoji: '🏠', groupId: 'life'),
    const ExpenseCategoryItem(categoryKey: 'expense.utilities', label: 'Utilities', emoji: '💡', groupId: 'life'),
    const ExpenseCategoryItem(categoryKey: 'expense.health', label: 'Health', emoji: '⚕️', groupId: 'life'),
    const ExpenseCategoryItem(categoryKey: 'expense.education', label: 'Education', emoji: '📚', groupId: 'life'),
    const ExpenseCategoryItem(categoryKey: 'expense.pets', label: 'Pets', emoji: '🐾', groupId: 'life'),
    const ExpenseCategoryItem(categoryKey: 'expense.other_expense', label: 'Other', emoji: '📝', groupId: 'life'),
  ];

  static final List<IncomeCategoryItem> incomeCategories = [
    const IncomeCategoryItem(categoryKey: 'income.other_income', label: 'Other income', emoji: '💰'),
    const IncomeCategoryItem(categoryKey: 'income.bonus', label: 'Bonus', emoji: '🏆'),
    const IncomeCategoryItem(categoryKey: 'income.stock', label: 'Stock', emoji: '📈'),
    const IncomeCategoryItem(categoryKey: 'income.salary', label: 'Salary', emoji: '💼'),
    const IncomeCategoryItem(categoryKey: 'income.business', label: 'Business', emoji: '💵'),
    const IncomeCategoryItem(categoryKey: 'income.insurance', label: 'Insurance', emoji: '🛡️'),
    const IncomeCategoryItem(categoryKey: 'income.red_envelope', label: 'Red envelope', emoji: '🧧'),
  ];

  static List<ExpenseCategoryItem> expenseCategoriesForGroup(String groupId) =>
      expenseCategories.where((e) => e.groupId == groupId).toList(growable: false);

  
  static String expenseGroupIdForCategoryKey(String categoryKey) {
    for (final c in expenseCategories) {
      if (c.categoryKey == categoryKey) return c.groupId;
    }
    return expenseGroupIds.first;
  }

  static CategoryDisplay resolve(TransactionKind kind, String categoryKey) {
    if (kind == TransactionKind.income) {
      for (final c in incomeCategories) {
        if (c.categoryKey == categoryKey) {
          return CategoryDisplay(emoji: c.emoji, label: c.label);
        }
      }
    } else {
      for (final c in expenseCategories) {
        if (c.categoryKey == categoryKey) {
          return CategoryDisplay(emoji: c.emoji, label: c.label);
        }
      }
      // Legacy migrated keys
      final fallback = categoryKey.replaceFirst('expense.', '');
      return CategoryDisplay(emoji: '🧾', label: fallback);
    }
    return const CategoryDisplay(emoji: '🧾', label: 'Other');
  }

  static String defaultCategoryKey(TransactionKind kind) => switch (kind) {
        TransactionKind.expense => 'expense.other_expense',
        TransactionKind.income => 'income.other_income',
      };
}
