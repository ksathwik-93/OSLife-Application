import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lifeos_flutter/screens/ai/ai_assistant_screen.dart';
import 'package:lifeos_flutter/providers/ai_chat_provider.dart';
import 'package:lifeos_flutter/providers/task_provider.dart';
import 'package:lifeos_flutter/providers/calendar_provider.dart';
import 'package:lifeos_flutter/providers/expense_provider.dart';
import 'package:lifeos_flutter/providers/note_provider.dart';
import 'package:lifeos_flutter/providers/goal_provider.dart';
import 'package:lifeos_flutter/providers/study_provider.dart';
import 'package:lifeos_flutter/services/local_ai_engine.dart';
import 'package:lifeos_flutter/models/task_model.dart';
import 'package:lifeos_flutter/models/expense_model.dart';
import 'package:lifeos_flutter/models/goal_model.dart';
import 'package:lifeos_flutter/models/study_model.dart';

void main() {
  group('LocalAIEngine Unit Tests', () {
    test('Intelligently answers the 5 required prompt queries based on local context', () {
      final contextData = LifeOSContextData(
        tasks: [
          TaskModel(
            id: 't_1',
            title: 'Complete Project Architecture',
            category: 'Work',
            dueDate: DateTime.now().add(const Duration(days: 1)),
            isCompleted: false,
            priority: 'High',
          ),
        ],
        transactions: [
          ExpenseModel(
            id: 'tx_1',
            title: 'Groceries',
            amount: 85.00,
            category: 'Food',
            date: DateTime.now(),
            paymentMethod: 'Card',
            isIncome: false,
          ),
        ],
        goals: [
          GoalModel(
            id: 'g_1',
            title: 'Launch LifeOS',
            description: 'Finish all modules',
            category: 'Career',
            priority: 'High',
            startDate: DateTime.now(),
            targetDate: DateTime.now().add(const Duration(days: 30)),
            milestones: [
              MilestoneModel(id: 'm_1', title: 'Complete AI Module', isCompleted: true),
              MilestoneModel(id: 'm_2', title: 'Run Integration Suite', isCompleted: false),
            ],
          ),
        ],
        studySubjects: [
          SubjectModel(
            id: 's_1',
            name: 'Artificial Intelligence',
            code: 'CS480',
            color: Colors.purple,
            instructor: 'Dr. Vance',
            targetHoursPerWeek: 8.0,
            completedHoursThisWeek: 4.0,
          ),
        ],
        studyExams: [
          ExamModel(
            id: 'e_1',
            subjectId: 's_1',
            subjectName: 'Artificial Intelligence',
            title: 'AI Midterm',
            examDate: DateTime.now().add(const Duration(days: 2)),
            location: 'Hall A',
            weightPercentage: 25,
            isCompleted: false,
          ),
        ],
      );

      // 1. What should I do today?
      final respToday = LocalAIEngine.generateResponse('What should I do today?', contextData);
      expect(respToday, contains('Daily OSLife Briefing'));
      expect(respToday, contains('Complete Project Architecture'));

      // 2. Show my pending tasks
      final respTasks = LocalAIEngine.generateResponse('Show my pending tasks', contextData);
      expect(respTasks, contains('Complete Project Architecture'));
      expect(respTasks, contains('High Priority'));

      // 3. How much did I spend this month?
      final respSpend = LocalAIEngine.generateResponse('How much did I spend this month?', contextData);
      expect(respSpend, contains('Total Expenses'));
      expect(respSpend, contains('85.00'));

      // 4. What are my current goals?
      final respGoals = LocalAIEngine.generateResponse('What are my current goals?', contextData);
      expect(respGoals, contains('Launch LifeOS'));
      expect(respGoals, contains('1 of 2 completed'));

      // 5. Help me plan my study time
      final respStudy = LocalAIEngine.generateResponse('Help me plan my study time', contextData);
      expect(respStudy, contains('AI Midterm'));
      expect(respStudy, contains('Weekly Study Hours'));
    });
  });

  group('AIAssistantScreen Widget Tests', () {
    testWidgets('renders header, prompt chips, and input bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AIChatProvider()),
            ChangeNotifierProvider(create: (_) => TaskProvider(uid: 'test_user')),
            ChangeNotifierProvider(create: (_) => CalendarProvider(uid: 'test_user')),
            ChangeNotifierProvider(create: (_) => ExpenseProvider(uid: 'test_user')),
            ChangeNotifierProvider(create: (_) => NoteProvider(uid: 'test_user')),
            ChangeNotifierProvider(create: (_) => GoalProvider(uid: 'test_user')),
            ChangeNotifierProvider(create: (_) => StudyProvider(uid: 'test_user')),
          ],
          child: const MaterialApp(
            home: AIAssistantScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Header verification
      expect(find.text('AI Assistant'), findsOneWidget);
      expect(find.text('LOCAL SYNC ACTIVE'), findsOneWidget);

      // Prompt chips verification
      expect(find.text('What should I do today?'), findsOneWidget);
      expect(find.text('Show my pending tasks'), findsOneWidget);
      expect(find.text('How much did I spend this month?'), findsOneWidget);

      // Input field verification
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });
  });
}
