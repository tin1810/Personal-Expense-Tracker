import 'package:flutter/material.dart';
import 'package:personal_expense_tracker_app/core/router/app_routes.dart';
import 'package:personal_expense_tracker_app/domain/entities/transaction.dart';
import 'package:personal_expense_tracker_app/presentation/pages/add_transaction_page.dart';
import 'package:personal_expense_tracker_app/presentation/pages/transaction_detail_page.dart';

abstract final class AppNavigator {
  AppNavigator._();

  static Future<void> pushAddTransaction(BuildContext context) {
    return Navigator.of(context).push<void>(
      AppRouteTransitions.fade<void>(
        routeName: AppRoutes.addTransaction,
        page: const AddTransactionPage(),
      ),
    );
  }

  static Future<void> pushTransactionDetail(BuildContext context, Transaction transaction) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(
          name: AppRoutes.transactionDetail,
          arguments: transaction.id,
        ),
        builder: (_) => TransactionDetailPage(transaction: transaction),
      ),
    );
  }
}
