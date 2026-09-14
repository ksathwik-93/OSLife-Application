import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final String _uid;

  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  TaskProvider({required String uid}) : _uid = uid {
    loadTasks();
  }

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    // For new users (empty scope), do NOT load sample data — start clean.
    if (HiveService.isUserBoxEmpty(HiveService.tasksBoxName, _uid)) {
      _tasks = [];
    } else {
      _tasks = HiveService.getUserItems(
        HiveService.tasksBoxName,
        _uid,
        (map) => TaskModel.fromMap(map),
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
      HiveService.saveUserItem(HiveService.tasksBoxName, _uid, _tasks[index].id, _tasks[index].toMap());
      notifyListeners();
    }
  }

  void addTask(String title, String category, String priority, {DateTime? dueDate, int? reminderMinutesBefore}) {
    final newTask = TaskModel(
      id: 't_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      dueDate: dueDate ?? DateTime.now(),
      isCompleted: false,
      priority: priority,
      reminderMinutesBefore: reminderMinutesBefore,
    );
    _tasks.insert(0, newTask);
    HiveService.saveUserItem(HiveService.tasksBoxName, _uid, newTask.id, newTask.toMap());
    _scheduleTaskReminder(newTask);
    notifyListeners();
  }

  void updateTask(String id, String title, String category, String priority, DateTime dueDate, {int? reminderMinutesBefore}) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      LocalNotificationService.cancelReminder(LocalNotificationService.notificationIdFor(id));
      _tasks[index] = _tasks[index].copyWith(
        title: title,
        category: category,
        priority: priority,
        dueDate: dueDate,
        reminderMinutesBefore: reminderMinutesBefore,
      );
      HiveService.saveUserItem(HiveService.tasksBoxName, _uid, _tasks[index].id, _tasks[index].toMap());
      _scheduleTaskReminder(_tasks[index]);
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    LocalNotificationService.cancelReminder(LocalNotificationService.notificationIdFor(id));
    _tasks.removeWhere((t) => t.id == id);
    HiveService.deleteUserItem(HiveService.tasksBoxName, _uid, id);
    notifyListeners();
  }

  void _scheduleTaskReminder(TaskModel task) {
    final mins = task.reminderMinutesBefore;
    if (mins == null) return;
    final reminderTime = task.dueDate.subtract(Duration(minutes: mins));
    LocalNotificationService.scheduleReminder(
      LocalNotificationService.notificationIdFor(task.id),
      '📋 Task Reminder: ${task.title}',
      'Due ${_formatRelative(mins)} — Category: ${task.category} (${task.priority} Priority)',
      reminderTime,
    );
  }

  String _formatRelative(int minutes) {
    if (minutes < 60) return 'in $minutes min';
    if (minutes < 1440) return 'in ${minutes ~/ 60}h';
    if (minutes < 10080) return 'in ${minutes ~/ 1440} day(s)';
    return 'in ${minutes ~/ 10080} week(s)';
  }
}
