import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.event,
    this.onEdit,
    this.onDelete,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return AppColors.primaryContainer;
      case 'personal':
        return AppColors.secondaryContainer;
      case 'team':
      case 'meeting':
        return AppColors.tertiary;
      case 'tech':
        return const Color(0xFF10B981);
      case 'health':
        return const Color(0xFF14B8A6);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(event.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: catColor.withValues(alpha: 0.3), width: 1.2),
      ),
      child: Row(
        children: [
          // Date Badge Block
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: catColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  DateFormatter.getMonthAbbr(event.startTime).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  DateFormatter.getDayNum(event.startTime),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: catColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: catColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${DateFormatter.formatTime(event.startTime)} - ${DateFormatter.formatTime(event.endTime)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                if (event.location.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Action Buttons
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.onSurfaceVariant),
              onPressed: onEdit,
              tooltip: 'Edit Event',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(6),
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
              onPressed: onDelete,
              tooltip: 'Delete Event',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(6),
            ),
        ],
      ),
    );
  }
}
