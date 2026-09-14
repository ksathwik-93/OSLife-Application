import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lifeos_flutter/providers/global_search_provider.dart';
import 'package:lifeos_flutter/providers/task_provider.dart';
import 'package:lifeos_flutter/providers/note_provider.dart';
import 'package:lifeos_flutter/providers/calendar_provider.dart';
import 'package:lifeos_flutter/providers/expense_provider.dart';
import 'package:lifeos_flutter/providers/goal_provider.dart';
import 'package:lifeos_flutter/providers/study_provider.dart';
import 'package:lifeos_flutter/providers/theme_provider.dart';
import 'package:lifeos_flutter/providers/auth_provider.dart';
import 'package:lifeos_flutter/screens/search/global_search_screen.dart';

void main() {
  group('GlobalSearchProvider Unit Tests', () {
    late GlobalSearchProvider searchProvider;
    late TaskProvider taskProvider;
    late NoteProvider noteProvider;
    late CalendarProvider calendarProvider;
    late ExpenseProvider expenseProvider;
    late GoalProvider goalProvider;
    late StudyProvider studyProvider;

    setUp(() {
      searchProvider = GlobalSearchProvider();
      taskProvider = TaskProvider(uid: 'test_user');
      noteProvider = NoteProvider(uid: 'test_user');
      calendarProvider = CalendarProvider(uid: 'test_user');
      expenseProvider = ExpenseProvider(uid: 'test_user');
      goalProvider = GoalProvider(uid: 'test_user');
      studyProvider = StudyProvider(uid: 'test_user');
    });

    test('Search returns matching items across multiple modules', () {
      searchProvider.setQuery('AI');

      final results = searchProvider.performSearch(
        taskProvider: taskProvider,
        noteProvider: noteProvider,
        calendarProvider: calendarProvider,
        expenseProvider: expenseProvider,
        goalProvider: goalProvider,
        studyProvider: studyProvider,
      );

      expect(results.isNotEmpty, true);

      final grouped = searchProvider.getGroupedResults(results);
      expect(grouped.isNotEmpty, true);
    });

    test('Filtering by module category restricts search results', () {
      searchProvider.setQuery('Design');
      searchProvider.setCategoryFilter('Tasks');

      final results = searchProvider.performSearch(
        taskProvider: taskProvider,
        noteProvider: noteProvider,
        calendarProvider: calendarProvider,
        expenseProvider: expenseProvider,
        goalProvider: goalProvider,
        studyProvider: studyProvider,
      );

      expect(results.every((r) => r.route == '/tasks'), true);
    });
  });

  testWidgets('GlobalSearchScreen renders search input and filters correctly', (WidgetTester tester) async {
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
          ChangeNotifierProvider(create: (_) => GlobalSearchProvider()),
        ],
        child: const MaterialApp(
          home: GlobalSearchScreen(initialQuery: 'Meeting'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(TextField), findsOneWidget);
  });
}
