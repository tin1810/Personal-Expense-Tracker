import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker_app/data/local/search_history_store.dart';
import 'package:personal_expense_tracker_app/main.dart';

import 'fake_transaction_repository.dart';

/// Drives splash timings so [BottomNavbarMain] is shown (matches [SplashScreen] sequence).
Future<void> pumpPastSplash(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1700));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Splash shows title before navigation completes', (WidgetTester tester) async {
    await tester.pumpWidget(
      PersonalExpenseTrackerApp(
        transactionRepository: FakeTransactionRepository(),
        searchHistoryStore: MemorySearchHistoryStore(),
      ),
    );
    await tester.pump();

    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.text('Know where it goes'), findsOneWidget);
  });

  testWidgets('Bottom navbar shows Home tab after splash', (WidgetTester tester) async {
    await tester.pumpWidget(
      PersonalExpenseTrackerApp(
        transactionRepository: FakeTransactionRepository(),
        searchHistoryStore: MemorySearchHistoryStore(),
      ),
    );
    await pumpPastSplash(tester);

    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
  });

  testWidgets('Bottom navbar switches to Search tab', (WidgetTester tester) async {
    await tester.pumpWidget(
      PersonalExpenseTrackerApp(
        transactionRepository: FakeTransactionRepository(),
        searchHistoryStore: MemorySearchHistoryStore(),
      ),
    );
    await pumpPastSplash(tester);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Search title'), findsOneWidget);
  });
}
