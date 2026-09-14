import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos_flutter/models/goal_model.dart';
import 'package:lifeos_flutter/providers/goal_provider.dart';

void main() {
  group('GoalProvider Unit Tests', () {
    late GoalProvider provider;

    setUp(() {
      provider = GoalProvider(uid: 'test_user');
    });

    test('Initial sample goals are loaded correctly', () {
      expect(provider.allGoals.isNotEmpty, true);
      expect(provider.totalGoalsCount, 5);
      expect(provider.activeGoalsCount, 4);
      expect(provider.completedGoalsCount, 1);
    });

    test('Adding a new goal updates count and list', () {
      final initialCount = provider.totalGoalsCount;
      final newGoal = GoalModel(
        id: 'test_g1',
        title: 'Learn Unit Testing',
        description: 'Write robust Flutter unit tests',
        category: 'Learning',
        priority: 'High',
        targetDate: DateTime.now().add(const Duration(days: 10)),
        milestones: [
          MilestoneModel(id: 'm1', title: 'Write tests', isCompleted: false),
        ],
      );

      provider.addGoal(newGoal);

      expect(provider.totalGoalsCount, initialCount + 1);
      expect(provider.allGoals.first.title, 'Learn Unit Testing');
    });

    test('Toggling a milestone updates goal progress and completed count', () {
      final goal = provider.allGoals.firstWhere((g) => g.id == 'g_1');
      final initialProgress = goal.calculatedProgress;

      // Find an incomplete milestone in g_1
      final incompleteMilestone = goal.milestones.firstWhere((m) => !m.isCompleted);
      
      provider.toggleMilestone('g_1', incompleteMilestone.id);

      final updatedGoal = provider.allGoals.firstWhere((g) => g.id == 'g_1');
      expect(updatedGoal.calculatedProgress, greaterThan(initialProgress));
    });

    test('Filtering by category returns matching goals', () {
      provider.setCategoryFilter('Career');
      final filtered = provider.filteredGoals;

      expect(filtered.every((g) => g.category == 'Career'), true);
    });

    test('Filtering by status returns active or completed goals', () {
      provider.setStatusFilter('Completed');
      final completed = provider.filteredGoals;

      expect(completed.every((g) => g.isAchieved), true);
    });

    test('Deleting a goal removes it from state', () {
      final goalId = provider.allGoals.first.id;
      final initialCount = provider.totalGoalsCount;

      provider.deleteGoal(goalId);

      expect(provider.totalGoalsCount, initialCount - 1);
      expect(provider.allGoals.any((g) => g.id == goalId), false);
    });
  });
}
