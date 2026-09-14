import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/study_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_card.dart';

class AssignmentList extends StatelessWidget {
  final List<AssignmentModel> assignments;
  final Function(String id) onToggle;
  final Function(AssignmentModel assignment) onEdit;
  final Function(String id) onDelete;
  final VoidCallback onAddAssignment;

  const AssignmentList({
    super.key,
    required this.assignments,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onAddAssignment,
  });

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ASSIGNMENTS & PROJECTS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: AppColors.secondary,
              ),
            ),
            TextButton.icon(
              onPressed: onAddAssignment,
              icon: const Icon(Icons.add, size: 16, color: AppColors.secondary),
              label: const Text('Add Assignment', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (assignments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
            ),
            child: const Column(
              children: [
                Icon(Icons.assignment_turned_in, size: 48, color: AppColors.outline),
                SizedBox(height: 12),
                Text(
                  'No assignments pending!',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                SizedBox(height: 4),
                Text(
                  'Great job! All caught up on coursework assignments.',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final item = assignments[index];
              final priorityColor = _getPriorityColor(item.priority);
              final daysRemaining = item.daysRemaining;
              final formattedDate = DateFormat('MMM dd, yyyy').format(item.dueDate);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: item.isCompleted,
                        activeColor: const Color(0xFF4ADE80),
                        checkColor: Colors.black,
                        onChanged: (_) => onToggle(item.id),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.subjectName,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: priorityColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.priority,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: priorityColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: item.isCompleted ? AppColors.onSurfaceVariant : AppColors.onSurface,
                                decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.event,
                                  size: 13,
                                  color: daysRemaining < 0
                                      ? AppColors.error
                                      : (daysRemaining <= 3 ? AppColors.tertiary : AppColors.onSurfaceVariant),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Due $formattedDate (${daysRemaining < 0 ? '${daysRemaining.abs()}d overdue' : '$daysRemaining days left'})',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: daysRemaining < 0
                                        ? AppColors.error
                                        : (daysRemaining <= 3 ? AppColors.tertiary : AppColors.onSurfaceVariant),
                                    fontWeight: daysRemaining <= 3 ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20, color: AppColors.onSurfaceVariant),
                        color: AppColors.surfaceContainerHigh,
                        onSelected: (val) {
                          if (val == 'edit') {
                            onEdit(item);
                          } else if (val == 'delete') {
                            onDelete(item.id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit', style: TextStyle(color: AppColors.onSurface)),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
