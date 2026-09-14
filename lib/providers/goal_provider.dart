import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

class GoalProvider extends ChangeNotifier {
  final String _uid;
  List<GoalModel> _goals = [];

  GoalProvider({required String uid}) : _uid = uid {
    _loadInitialData();
  }

  void _loadInitialData() {
    // New users start with empty goals — no sample data.
    if (HiveService.isUserBoxEmpty(HiveService.goalsBoxName, _uid)) {
      _goals = [];
    } else {
      _goals = HiveService.getUserItems(
        HiveService.goalsBoxName,
        _uid,
        (map) => GoalModel.fromMap(map),
      );
    }
  }

  String _selectedCategory = 'All';
  String _selectedStatus = 'All'; // 'All', 'Active', 'Completed'
  String _searchQuery = '';

  List<GoalModel> get allGoals => List.unmodifiable(_goals);
  String get selectedCategory => _selectedCategory;
  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;

  static const List<String> categories = [
    'All',
    'Career',
    'Health',
    'Finance',
    'Personal',
    'Learning',
  ];

  List<GoalModel> get filteredGoals {
    return _goals.where((goal) {
      // Category filter
      if (_selectedCategory != 'All' && goal.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }
      // Status filter
      if (_selectedStatus == 'Active' && goal.isAchieved) {
        return false;
      }
      if (_selectedStatus == 'Completed' && !goal.isAchieved) {
        return false;
      }
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = goal.title.toLowerCase().contains(query);
        final matchesDesc = goal.description.toLowerCase().contains(query);
        final matchesCategory = goal.category.toLowerCase().contains(query);
        return matchesTitle || matchesDesc || matchesCategory;
      }
      return true;
    }).toList();
  }

  // Statistics
  int get totalGoalsCount => _goals.length;
  int get completedGoalsCount => _goals.where((g) => g.isAchieved).length;
  int get activeGoalsCount => _goals.where((g) => !g.isAchieved).length;

  double get overallProgress {
    if (_goals.isEmpty) return 0.0;
    final totalProgress = _goals.fold<double>(0.0, (sum, g) => sum + g.calculatedProgress);
    return totalProgress / _goals.length;
  }

  Map<String, int> get categoryCounts {
    final map = <String, int>{};
    for (final cat in categories) {
      if (cat == 'All') {
        map[cat] = _goals.length;
      } else {
        map[cat] = _goals.where((g) => g.category.toLowerCase() == cat.toLowerCase()).length;
      }
    }
    return map;
  }

  // Filter setters
  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Actions
  void addGoal(GoalModel goal) {
    _goals.insert(0, goal);
    HiveService.saveUserItem(HiveService.goalsBoxName, _uid, goal.id, goal.toMap());
    _scheduleGoalReminder(goal);
    notifyListeners();
  }

  void updateGoal(GoalModel updatedGoal) {
    final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      LocalNotificationService.cancelReminder(LocalNotificationService.notificationIdFor(updatedGoal.id));
      _goals[index] = updatedGoal;
      HiveService.saveUserItem(HiveService.goalsBoxName, _uid, updatedGoal.id, updatedGoal.toMap());
      _scheduleGoalReminder(updatedGoal);
      notifyListeners();
    }
  }

  void deleteGoal(String id) {
    LocalNotificationService.cancelReminder(LocalNotificationService.notificationIdFor(id));
    _goals.removeWhere((g) => g.id == id);
    HiveService.deleteUserItem(HiveService.goalsBoxName, _uid, id);
    notifyListeners();
  }

  void toggleGoalCompletion(String id) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final goal = _goals[index];
      final newStatus = !goal.isCompleted;

      List<MilestoneModel> updatedMilestones = goal.milestones;
      if (newStatus) {
        updatedMilestones = goal.milestones.map((m) => m.copyWith(isCompleted: true)).toList();
      }

      _goals[index] = goal.copyWith(
        isCompleted: newStatus,
        progress: newStatus ? 1.0 : (updatedMilestones.isNotEmpty ? updatedMilestones.where((m) => m.isCompleted).length / updatedMilestones.length : 0.0),
        milestones: updatedMilestones,
      );
      HiveService.saveUserItem(HiveService.goalsBoxName, _uid, _goals[index].id, _goals[index].toMap());
      notifyListeners();
    }
  }

  void toggleMilestone(String goalId, String milestoneId) {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      final updatedMilestones = goal.milestones.map((m) {
        if (m.id == milestoneId) {
          return m.copyWith(isCompleted: !m.isCompleted);
        }
        return m;
      }).toList();

      final completedCount = updatedMilestones.where((m) => m.isCompleted).length;
      final newProgress = updatedMilestones.isNotEmpty ? completedCount / updatedMilestones.length : goal.progress;
      final isAllDone = updatedMilestones.isNotEmpty && completedCount == updatedMilestones.length;

      _goals[goalIndex] = goal.copyWith(
        milestones: updatedMilestones,
        progress: newProgress,
        isCompleted: isAllDone,
      );
      HiveService.saveUserItem(HiveService.goalsBoxName, _uid, _goals[goalIndex].id, _goals[goalIndex].toMap());
      notifyListeners();
    }
  }

  void addMilestone(String goalId, String title) {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      final newMilestone = MilestoneModel(
        id: 'm_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        isCompleted: false,
      );
      final updatedMilestones = List<MilestoneModel>.from(goal.milestones)..add(newMilestone);
      final completedCount = updatedMilestones.where((m) => m.isCompleted).length;

      _goals[goalIndex] = goal.copyWith(
        milestones: updatedMilestones,
        progress: completedCount / updatedMilestones.length,
        isCompleted: completedCount == updatedMilestones.length,
      );
      HiveService.saveUserItem(HiveService.goalsBoxName, _uid, _goals[goalIndex].id, _goals[goalIndex].toMap());
      notifyListeners();
    }
  }

  void deleteMilestone(String goalId, String milestoneId) {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      final updatedMilestones = goal.milestones.where((m) => m.id != milestoneId).toList();
      final completedCount = updatedMilestones.where((m) => m.isCompleted).length;
      final newProgress = updatedMilestones.isNotEmpty ? completedCount / updatedMilestones.length : 0.0;

      _goals[goalIndex] = goal.copyWith(
        milestones: updatedMilestones,
        progress: newProgress,
        isCompleted: updatedMilestones.isNotEmpty && completedCount == updatedMilestones.length,
      );
      HiveService.saveUserItem(HiveService.goalsBoxName, _uid, _goals[goalIndex].id, _goals[goalIndex].toMap());
      notifyListeners();
    }
  }

  void _scheduleGoalReminder(GoalModel goal) {
    final mins = goal.reminderMinutesBefore;
    if (mins == null) return;
    final reminderTime = goal.targetDate.subtract(Duration(minutes: mins));
    LocalNotificationService.scheduleReminder(
      LocalNotificationService.notificationIdFor(goal.id),
      '🎯 Goal Deadline Reminder: ${goal.title}',
      'Target deadline ${_formatRelative(mins)} — ${goal.category} (${goal.priority} Priority)',
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
