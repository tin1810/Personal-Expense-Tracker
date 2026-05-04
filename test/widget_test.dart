import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker_app/data/local/search_history_store.dart';
import 'package:personal_expense_tracker_app/main.dart';

import 'fake_transaction_repository.dart';

void main() {
  testWidgets('Bottom navbar shows Home tab', (WidgetTester tester) async {
    await tester.pumpWidget(
      PersonalExpenseTrackerApp(
        transactionRepository: FakeTransactionRepository(),
        searchHistoryStore: MemorySearchHistoryStore(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
  });
}
