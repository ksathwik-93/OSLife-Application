import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/goal_model.dart';
import '../../providers/goal_provider.dart';
import '../../theme/app_colors.dart';
import 'widgets/goals_statistics_section.dart';
import 'widgets/goal_card.dart';
import 'widgets/goal_detail_dialog.dart';
import 'widgets/add_edit_goal_dialog.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEditGoalDialog(),
    );
  }

  void _openEditGoalDialog(BuildContext context, GoalModel goal) {
    showDialog(
      context: context,
      builder: (context) => AddEditGoalDialog(goal: goal),
    );
  }

  void _openGoalDetailDialog(BuildContext context, GoalModel goal) {
    showDialog(
      context: context,
      builder: (context) => GoalDetailDialog(
        goal: goal,
        onEdit: () => _openEditGoalDialog(context, goal),
      ),
    );
  }

  void _confirmDeleteGoal(BuildContext context, GoalProvider provider, GoalModel goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLow,
        title: const Text('Delete Goal?', style: TextStyle(color: AppColors.onSurface)),
        content: Text(
          'Are you sure you want to delete "${goal.title}"? This cannot be undone.',
          style: const TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorContainer,
              foregroundColor: AppColors.onErrorContainer,
            ),
            onPressed: () {
              provider.deleteGoal(goal.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, child) {
        final filteredGoals = provider.filteredGoals;
        final screenWidth = MediaQuery.of(context).size.width;
        final isWideScreen = screenWidth >= 768;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceContainerLow,
            elevation: 0,
            title: const Text(
              'Goals & Milestones',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
            actions: [
              IconButton(
                tooltip: 'Add Goal',
                onPressed: () => _openAddGoalDialog(context),
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openAddGoalDialog(context),
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: AppColors.onPrimaryContainer,
            icon: const Icon(Icons.add),
            label: const Text('New Goal', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Summary Card
                GoalsStatisticsSection(
                  totalGoals: provider.totalGoalsCount,
                  activeGoals: provider.activeGoalsCount,
                  completedGoals: provider.completedGoalsCount,
                  overallProgress: provider.overallProgress,
                ),
                const SizedBox(height: 20),

                // Search & Filter Header
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
                        onChanged: (val) => provider.setSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: 'Search goals or categories...',
                          hintStyle: const TextStyle(fontSize: 13, color: AppColors.outline),
                          prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18, color: AppColors.onSurfaceVariant),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.setSearchQuery('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Status Filter Tabs (All / Active / Completed)
                Row(
                  children: ['All', 'Active', 'Completed'].map((status) {
                    final isSelected = provider.selectedStatus == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            provider.setStatusFilter(status);
                          }
                        },
                        selectedColor: AppColors.primaryContainer,
                        backgroundColor: AppColors.surfaceContainerLow,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Category Chips
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: GoalProvider.categories.length,
                    itemBuilder: (context, index) {
                      final category = GoalProvider.categories[index];
                      final isSelected = provider.selectedCategory == category;
                      final count = provider.categoryCounts[category] ?? 0;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          showCheckmark: false,
                          label: Text('$category ($count)'),
                          selected: isSelected,
                          onSelected: (selected) {
                            provider.setCategoryFilter(category);
                          },
                          selectedColor: AppColors.primary.withValues(alpha: 0.25),
                          backgroundColor: AppColors.surfaceContainerLow,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // Goals List / Grid
                if (filteredGoals.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flag_circle_outlined, size: 56, color: AppColors.outline),
                        const SizedBox(height: 12),
                        const Text(
                          'No goals found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          provider.searchQuery.isNotEmpty
                              ? 'No goals matched "${provider.searchQuery}"'
                              : 'Create your first goal to start tracking progress!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: AppColors.onPrimaryContainer,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _openAddGoalDialog(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Goal'),
                        ),
                      ],
                    ),
                  )
                else if (isWideScreen)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: filteredGoals.length,
                    itemBuilder: (context, index) {
                      final goal = filteredGoals[index];
                      return GoalCard(
                        goal: goal,
                        onTap: () => _openGoalDetailDialog(context, goal),
                        onEdit: () => _openEditGoalDialog(context, goal),
                        onDelete: () => _confirmDeleteGoal(context, provider, goal),
                        onToggleComplete: () => provider.toggleGoalCompletion(goal.id),
                      );
                    },
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredGoals.length,
                    itemBuilder: (context, index) {
                      final goal = filteredGoals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GoalCard(
                          goal: goal,
                          onTap: () => _openGoalDetailDialog(context, goal),
                          onEdit: () => _openEditGoalDialog(context, goal),
                          onDelete: () => _confirmDeleteGoal(context, provider, goal),
                          onToggleComplete: () => provider.toggleGoalCompletion(goal.id),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 80), // Bottom padding for FAB
              ],
            ),
          ),
        );
      },
    );
  }
}

