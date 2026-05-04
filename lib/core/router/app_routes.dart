import 'package:flutter/material.dart';

abstract final class AppRoutes {
  AppRoutes._();

  /// bottom navigation (Home / Search / Charts).t s
  static const String shell = '/';

  
  static const String addTransaction = '/add-transaction';

  static const String transactionDetail = '/transaction-detail';
}

///  route animations
abstract final class AppRouteTransitions {
  AppRouteTransitions._();

  static PageRouteBuilder<T> fade<T>({
    required String routeName,
    Object? arguments,
    required Widget page,
  }) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: routeName, arguments: arguments),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}
