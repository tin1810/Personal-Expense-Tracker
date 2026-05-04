/// Layout and sizing tokens (padding, icons, radii, typography scale).
abstract final class AppSizes {
  AppSizes._();

  static const double spaceXs = 8;
  static const double spaceSm = 16;
  static const double spaceMd = 24;
  static const double spaceLg = 32;

  static const double iconEmptyState = 64;

  static const double radiusSm = 8;
  static const double radiusMd = 12;

  static const double screenPadding = spaceSm;

  static const double inlineProgressSize = 24;
  static const double inlineProgressStroke = 2;

  /// Minimum tap target comfort (Material guideline ~48).
  static const double minTapTarget = 48;
}
