import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/goal_model.dart';
import '../../../providers/goal_provider.dart';
import '../../../theme/app_colors.dart';

class GoalDetailDialog extends StatefulWidget {
  final GoalModel goal;
  final VoidCallback onEdit;

  const GoalDetailDialog({
    super.key,
    required this.goal,
    required this.onEdit,
  });

  @override
  State<GoalDetailDialog> createState() => _GoalDetailDialogState();
}

class _GoalDetailDialogState extends State<GoalDetailDialog> {
  final TextEditingController _milestoneController = TextEditingController();

  @override
  void dispose() {
    _milestoneController.dispose();
    super.dispose();
  }

  void _addMilestone(GoalProvider provider) {
    final text = _milestoneController.text.trim();
    if (text.isNotEmpty) {
      provider.addMilestone(widget.goal.id, text);
      _milestoneController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, child) {
        // Fetch fresh state of the goal from provider
        final currentGoal = provider.allGoals.firstWhere(
          (g) => g.id == widget.goal.id,
          orElse: () => widget.goal,
        );

        final progress = currentGoal.calculatedProgress;
        final progressPercent = (progress * 100).toInt();
        final formattedTargetDate = DateFormat('MMM dd, yyyy').format(currentGoal.targetDate);
        final formattedStartDate = DateFormat('MMM dd, yyyy').format(currentGoal.startDate);

        return Dialog(
          backgroundColor: AppColors.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        currentGoal.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  currentGoal.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                if (currentGoal.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    currentGoal.description,
                    style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 16),

                // Meta Cards (Start Date, Target Date, Days Left)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetaItem('Started', formattedStartDate, Icons.calendar_today_outlined),
                      Container(height: 24, width: 1, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                      _buildMetaItem('Target Date', formattedTargetDate, Icons.flag_outlined),
                      Container(height: 24, width: 1, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                      _buildMetaItem(
                        'Time Left',
                        currentGoal.daysRemaining < 0
                            ? '${currentGoal.daysRemaining.abs()}d Overdue'
                            : '${currentGoal.daysRemaining} days',
                        Icons.hourglass_empty,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PROGRESS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '$progressPercent%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      currentGoal.isAchieved ? const Color(0xFF4ADE80) : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Milestones Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MILESTONES (${currentGoal.completedMilestonesCount}/${currentGoal.totalMilestonesCount})',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Add Milestone Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _milestoneController,
                        style: const TextStyle(fontSize: 13, color: AppColors.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Add new milestone...',
                          hintStyle: const TextStyle(fontSize: 13, color: AppColors.outline),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          filled: true,
                          fillColor: AppColors.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _addMilestone(provider),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.add, color: AppColors.onPrimaryContainer),
                      onPressed: () => _addMilestone(provider),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Milestone List
                Expanded(
                  child: currentGoal.milestones.isEmpty
                      ? const Center(
                          child: Text(
                            'No milestones added yet.',
                            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: currentGoal.milestones.length,
                          itemBuilder: (context, index) {
                            final milestone = currentGoal.milestones[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                              ),
                              child: ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                leading: Checkbox(
                                  value: milestone.isCompleted,
                                  activeColor: const Color(0xFF4ADE80),
                                  checkColor: Colors.black,
                                  onChanged: (_) {
                                    provider.toggleMilestone(currentGoal.id, milestone.id);
                                  },
                                ),
                                title: Text(
                                  milestone.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: milestone.isCompleted ? AppColors.onSurfaceVariant : AppColors.onSurface,
                                    decoration: milestone.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.outline),
                                  onPressed: () {
                                    provider.deleteMilestone(currentGoal.id, milestone.id);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        provider.deleteGoal(currentGoal.id);
                      },
                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                      label: const Text('Delete', style: TextStyle(color: AppColors.error)),
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onEdit();
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: AppColors.onPrimaryContainer,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetaItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

