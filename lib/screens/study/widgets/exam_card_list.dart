import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/study_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_card.dart';

class ExamCardList extends StatelessWidget {
  final List<ExamModel> exams;
  final Function(String id) onToggle;
  final Function(ExamModel exam) onEdit;
  final Function(String id) onDelete;
  final VoidCallback onAddExam;

  const ExamCardList({
    super.key,
    required this.exams,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onAddExam,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'EXAMS & ASSESSMENTS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: AppColors.primary,
              ),
            ),
            TextButton.icon(
              onPressed: onAddExam,
              icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
              label: const Text('Add Exam', style: TextStyle(color: AppColors.primary, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (exams.isEmpty)
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
                  'No upcoming exams scheduled',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                SizedBox(height: 4),
                Text(
                  'Add exams to receive countdown alerts and study reminders.',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              final daysRemaining = exam.daysRemaining;
              final formattedDate = DateFormat('EEE, MMM dd, yyyy').format(exam.examDate);

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              exam.subjectName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: daysRemaining <= 3
                                      ? AppColors.errorContainer.withValues(alpha: 0.5)
                                      : AppColors.tertiaryContainer.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  daysRemaining == 0
                                      ? 'Exam Today!'
                                      : (daysRemaining < 0
                                          ? 'Completed / Past'
                                          : '$daysRemaining Days Left'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: daysRemaining <= 3 ? AppColors.error : AppColors.tertiary,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 20, color: AppColors.onSurfaceVariant),
                                color: AppColors.surfaceContainerHigh,
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    onEdit(exam);
                                  } else if (val == 'delete') {
                                    onDelete(exam.id);
                                  } else if (val == 'toggle') {
                                    onToggle(exam.id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'toggle',
                                    child: Text(
                                      exam.isCompleted ? 'Mark Active' : 'Mark Completed',
                                      style: const TextStyle(color: AppColors.onSurface),
                                    ),
                                  ),
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
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: exam.isCompleted,
                            activeColor: const Color(0xFF4ADE80),
                            checkColor: Colors.black,
                            onChanged: (_) => onToggle(exam.id),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exam.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: exam.isCompleted ? AppColors.onSurfaceVariant : AppColors.onSurface,
                                    decoration: exam.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.event, size: 14, color: AppColors.secondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                                    ),
                                    const SizedBox(width: 14),
                                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(
                                      exam.location,
                                      style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Grade Weight: ${exam.weightPercentage}%',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            const Text(
                              'Preparation Recommended',
                              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
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
