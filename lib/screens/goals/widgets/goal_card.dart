import 'package:flutter/material.dart';
import '../../../models/goal_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_card.dart';

class GoalCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleComplete,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'career':
        return AppColors.primary;
      case 'health':
        return const Color(0xFF4ADE80);
      case 'finance':
        return AppColors.secondary;
      case 'personal':
        return AppColors.tertiary;
      case 'learning':
        return const Color(0xFFF472B6);
      default:
        return AppColors.primary;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFF87171);
      case 'medium':
        return const Color(0xFFFBBF24);
      case 'low':
        return const Color(0xFF60A5FA);
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(goal.category);
    final priorityColor = _getPriorityColor(goal.priority);
    final daysRemaining = goal.daysRemaining;
    final progress = goal.calculatedProgress;
    final progressPercent = (progress * 100).toInt();

    return GlassCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: categoryColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      goal.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.flag, size: 10, color: priorityColor),
                        const SizedBox(width: 4),
                        Text(
                          goal.priority,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: priorityColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: AppColors.onSurfaceVariant),
                color: AppColors.surfaceContainerHigh,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  switch (value) {
                    case 'toggle':
                      onToggleComplete();
                      break;
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          goal.isAchieved ? Icons.undo : Icons.check_circle_outline,
                          size: 18,
                          color: goal.isAchieved ? AppColors.tertiary : const Color(0xFF4ADE80),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          goal.isAchieved ? 'Mark Active' : 'Mark Completed',
                          style: const TextStyle(fontSize: 13, color: AppColors.onSurface),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: AppColors.secondary),
                        SizedBox(width: 8),
                        Text('Edit Goal', style: TextStyle(fontSize: 13, color: AppColors.onSurface)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete Goal', style: TextStyle(fontSize: 13, color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onToggleComplete,
                borderRadius: BorderRadius.circular(20),
                child: Icon(
                  goal.isAchieved ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: goal.isAchieved ? const Color(0xFF4ADE80) : AppColors.outline,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: goal.isAchieved ? AppColors.onSurfaceVariant : AppColors.onSurface,
                        decoration: goal.isAchieved ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (goal.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        goal.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 14,
                    color: categoryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${goal.completedMilestonesCount}/${goal.totalMilestonesCount} Milestones',
                    style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: daysRemaining < 0
                        ? AppColors.error
                        : (daysRemaining <= 7 ? AppColors.tertiary : AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    daysRemaining < 0
                        ? 'Overdue (${daysRemaining.abs()}d)'
                        : (daysRemaining == 0 ? 'Due Today' : '$daysRemaining days left'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: daysRemaining <= 7 ? FontWeight.bold : FontWeight.normal,
                      color: daysRemaining < 0
                          ? AppColors.error
                          : (daysRemaining <= 7 ? AppColors.tertiary : AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      goal.isAchieved ? const Color(0xFF4ADE80) : categoryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$progressPercent%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: goal.isAchieved ? const Color(0xFF4ADE80) : categoryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

