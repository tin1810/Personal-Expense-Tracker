import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker_app/data/local/search_history_store.dart';
import 'package:personal_expense_tracker_app/main.dart';

import 'fake_transaction_repository.dart';

void main() {
  testWidgets('App shell shows Home navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      PersonalExpenseTrackerApp(
        transactionRepository: FakeTransactionRepository(),
        searchHistoryStore: MemorySearchHistoryStore(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
  });
}
