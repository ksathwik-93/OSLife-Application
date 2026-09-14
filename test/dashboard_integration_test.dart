import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lifeos_flutter/screens/dashboard/home_dashboard_screen.dart';
import 'package:lifeos_flutter/providers/auth_provider.dart';
import 'package:lifeos_flutter/providers/task_provider.dart';
import 'package:lifeos_flutter/providers/calendar_provider.dart';
import 'package:lifeos_flutter/providers/expense_provider.dart';
import 'package:lifeos_flutter/providers/note_provider.dart';
import 'package:lifeos_flutter/providers/goal_provider.dart';
import 'package:lifeos_flutter/providers/study_provider.dart';
import 'package:lifeos_flutter/providers/theme_provider.dart';

void main() {
  testWidgets('HomeDashboardScreen renders cleanly with all connected providers', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider(uid: 'test_user')),
          ChangeNotifierProvider(create: (_) => CalendarProvider(uid: 'test_user')),
          ChangeNotifierProvider(create: (_) => ExpenseProvider(uid: 'test_user')),
          ChangeNotifierProvider(create: (_) => NoteProvider(uid: 'test_user')),
          ChangeNotifierProvider(create: (_) => GoalProvider(uid: 'test_user')),
          ChangeNotifierProvider(create: (_) => StudyProvider(uid: 'test_user')),
        ],
        child: const MaterialApp(
          home: HomeDashboardScreen(),
        ),
      ),
    );

    // Trigger frame and allow timers to settle
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // Verify key titles and card headers are rendered
    expect(find.text('OSLife'), findsOneWidget);
    expect(find.text("Today's Tasks"), findsOneWidget);
    expect(find.text('Calendar Preview'), findsOneWidget);
    expect(find.text('Expense Summary'), findsOneWidget);
    expect(find.text('Goals Progress'), findsOneWidget);
    expect(find.text('Study Progress'), findsOneWidget);
  });
}
