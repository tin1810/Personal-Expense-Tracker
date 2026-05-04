enum AppCurrency {
  usd,
  myr,
  thb,
  mmk;

  String get storageKey => name;

  /// Short symbol of currency
  String get symbol => switch (this) {
        AppCurrency.usd => r'$',
        AppCurrency.myr => 'RM',
        AppCurrency.thb => '฿',
        AppCurrency.mmk => 'K',
      };

  static AppCurrency parse(String key) {
    return AppCurrency.values.firstWhere(
      (v) => v.storageKey == key,
      orElse: () => AppCurrency.usd,
    );
  }
}
