import '../models/task_model.dart';
import '../models/event_model.dart';
import '../models/expense_model.dart';
import '../models/note_model.dart';
import '../models/goal_model.dart';

/// Prepared interface for Cloud Firestore & Database synchronization.
abstract class FirestoreService {
  Future<List<TaskModel>> fetchTasks();
  Future<void> saveTask(TaskModel task);
  Future<List<EventModel>> fetchEvents();
  Future<List<ExpenseModel>> fetchExpenses();
  Future<List<NoteModel>> fetchNotes();
  Future<List<GoalModel>> fetchGoals();
}

class MockFirestoreService implements FirestoreService {
  @override
  Future<List<TaskModel>> fetchTasks() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      TaskModel(id: 't1', title: 'Review morning reports', category: 'Work', dueDate: DateTime.now(), isCompleted: true, priority: 'Medium'),
      TaskModel(id: 't2', title: 'Design System updates', category: 'Design', dueDate: DateTime.now(), isCompleted: false, priority: 'High'),
      TaskModel(id: 't3', title: 'Team sync at 2 PM', category: 'Meeting', dueDate: DateTime.now(), isCompleted: false, priority: 'High'),
      TaskModel(id: 't4', title: 'Gym session', category: 'Health', dueDate: DateTime.now(), isCompleted: false, priority: 'Low'),
    ];
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<List<EventModel>> fetchEvents() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    return [
      EventModel(id: 'e1', title: 'Product Strategy Meeting', location: 'Conference Room B', startTime: now.add(const Duration(hours: 2)), endTime: now.add(const Duration(hours: 3, minutes: 30)), category: 'Work'),
      EventModel(id: 'e2', title: 'Dentist Appointment', location: 'Medical Center, Suite 4', startTime: now.add(const Duration(days: 1, hours: 4)), endTime: now.add(const Duration(days: 1, hours: 5)), category: 'Personal'),
      EventModel(id: 'e3', title: 'Neural AI Architecture Review', location: 'Virtual Zoom Room', startTime: now.add(const Duration(days: 2, hours: 1)), endTime: now.add(const Duration(days: 2, hours: 2, minutes: 30)), category: 'Tech'),
    ];
  }

  @override
  Future<List<ExpenseModel>> fetchExpenses() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    return [
      ExpenseModel(id: 'ex1', title: 'Coffee & Breakfast', amount: 14.50, category: 'Food', date: now),
      ExpenseModel(id: 'ex2', title: 'Cloud Infrastructure Subscription', amount: 89.99, category: 'Software', date: now.subtract(const Duration(days: 1))),
      ExpenseModel(id: 'ex3', title: 'Grocery Supermarket', amount: 142.30, category: 'Supplies', date: now.subtract(const Duration(days: 2))),
      ExpenseModel(id: 'ex4', title: 'Ergonomic Chair Upgrade', amount: 450.00, category: 'Equipment', date: now.subtract(const Duration(days: 4))),
    ];
  }

  @override
  Future<List<NoteModel>> fetchNotes() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    return [
      NoteModel(id: 'n1', title: 'Q4 Growth Strategy', content: 'Key Objective: Increase user retention by 15% through gamified onboarding. Review API docs.', tag: 'Strategy', updatedAt: now, isPinned: true),
      NoteModel(id: 'n2', title: 'Flutter Clean Architecture', content: 'Use Provider + Repository pattern for state management and decoupled API services.', tag: 'Engineering', updatedAt: now.subtract(const Duration(days: 1))),
      NoteModel(id: 'n3', title: 'Book Highlights: Deep Work', content: 'High-value creative work requires uninterrupted focus blocks of at least 90 minutes.', tag: 'Reading', updatedAt: now.subtract(const Duration(days: 3))),
    ];
  }

  @override
  Future<List<GoalModel>> fetchGoals() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final target = DateTime.now().add(const Duration(days: 60));
    return [
      GoalModel(id: 'g1', title: 'Master Production Flutter', description: 'Complete 5 complex end-to-end applications with tests.', progress: 0.75, targetDate: target, category: 'Career'),
      GoalModel(id: 'g2', title: 'Run Half Marathon', description: 'Train 4 days a week with incremental long runs.', progress: 0.50, targetDate: target, category: 'Health'),
      GoalModel(id: 'g3', title: 'Emergency Fund Savings', description: 'Accumulate 6 months of living expenses in high-yield account.', progress: 0.90, targetDate: target, category: 'Finance'),
    ];
  }
}
