import 'package:flutter/material.dart';

/// Brand and semantic colors used across the app.
/// Prefer [ColorScheme] from [ThemeData] where possible; these fill gaps for fixed accents.
abstract final class AppColors {
  AppColors._();

  /// Passed to [ColorScheme.fromSeed]; aligns with Material `Colors.teal`.
  static const Color seed = Color(0xFF009688);

  static const Color snackbarBackground = Color(0xFF323232);
}
