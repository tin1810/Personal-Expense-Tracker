import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker_app/main.dart';

import 'fake_expense_repository.dart';

void main() {
  testWidgets('App shows expense tracker title', (WidgetTester tester) async {
    await tester.pumpWidget(
      PersonalExpenseTrackerApp(expenseRepository: FakeExpenseRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Personal Expense Tracker'), findsOneWidget);
  });
}
