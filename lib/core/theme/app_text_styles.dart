import 'package:flutter/material.dart';

/// Text styles derived from [TextTheme] so typography stays consistent with [ThemeData].
abstract final class AppTextStyles {
  AppTextStyles._();

  static TextStyle emptyStateTitle(TextTheme textTheme) =>
      textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600);

  static TextStyle emptyStateBody(TextTheme textTheme) => textTheme.bodyMedium!;

  static TextStyle errorBody(TextTheme textTheme) => textTheme.bodyLarge!;

  static TextStyle listTileTitle(TextTheme textTheme) => textTheme.titleMedium!;

  static TextStyle listTileSubtitle(TextTheme textTheme) => textTheme.bodySmall!;
}
