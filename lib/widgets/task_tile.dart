import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme/app_colors.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final ValueChanged<bool?> onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    if (task.priority == 'High') {
      priorityColor = const Color(0xFFEF4444);
    } else if (task.priority == 'Medium') {
      priorityColor = AppColors.primary;
    } else {
      priorityColor = AppColors.secondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            onChanged: onToggle,
            activeColor: AppColors.primaryContainer,
            checkColor: AppColors.onPrimaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: task.isCompleted ? AppColors.onSurfaceVariant : AppColors.onSurface,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.priority.toUpperCase(),
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: priorityColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      task.category,
                      style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.onSurfaceVariant),
              onPressed: onEdit,
              tooltip: 'Edit Task',
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
              onPressed: onDelete,
              tooltip: 'Delete Task',
            ),
        ],
      ),
    );
  }
}
