import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// A dropdown for selecting a reminder interval before an event/deadline.
/// Returns null if "No Reminder" is selected, otherwise returns minutes.
class ReminderDropdown extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;
  final String label;

  const ReminderDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Remind me',
  });

  static const List<_ReminderOption> _options = [
    _ReminderOption(null, 'No Reminder'),
    _ReminderOption(5, '5 minutes before'),
    _ReminderOption(10, '10 minutes before'),
    _ReminderOption(15, '15 minutes before'),
    _ReminderOption(30, '30 minutes before'),
    _ReminderOption(60, '1 hour before'),
    _ReminderOption(120, '2 hours before'),
    _ReminderOption(1440, '1 day before'),
    _ReminderOption(2880, '2 days before'),
    _ReminderOption(10080, '1 week before'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.notifications_outlined, size: 15, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value != null
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : AppColors.outlineVariant.withValues(alpha: 0.4),
              width: value != null ? 1.5 : 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surfaceContainerHigh,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              borderRadius: BorderRadius.circular(12),
              icon: Icon(
                Icons.expand_more_rounded,
                color: value != null ? AppColors.primary : AppColors.onSurfaceVariant,
                size: 20,
              ),
              items: _options.map((opt) {
                return DropdownMenuItem<int?>(
                  value: opt.minutes,
                  child: Row(
                    children: [
                      Icon(
                        opt.minutes == null
                            ? Icons.notifications_off_outlined
                            : Icons.alarm_rounded,
                        size: 16,
                        color: opt.minutes == null
                            ? AppColors.onSurfaceVariant.withValues(alpha: 0.5)
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        opt.label,
                        style: TextStyle(
                          fontSize: 13,
                          color: opt.minutes == null
                              ? AppColors.onSurfaceVariant
                              : AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReminderOption {
  final int? minutes;
  final String label;
  const _ReminderOption(this.minutes, this.label);
}
