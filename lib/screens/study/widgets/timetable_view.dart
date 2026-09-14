import 'package:flutter/material.dart';
import '../../../models/study_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_card.dart';

class TimetableView extends StatefulWidget {
  final List<TimetableSlotModel> timetable;
  final Function(String id) onDeleteSlot;
  final VoidCallback onAddSlot;

  const TimetableView({
    super.key,
    required this.timetable,
    required this.onDeleteSlot,
    required this.onAddSlot,
  });

  @override
  State<TimetableView> createState() => _TimetableViewState();
}

class _TimetableViewState extends State<TimetableView> {
  int _selectedDay = 1; // 1 = Monday

  final List<Map<String, dynamic>> _days = [
    {'day': 1, 'name': 'Mon'},
    {'day': 2, 'name': 'Tue'},
    {'day': 3, 'name': 'Wed'},
    {'day': 4, 'name': 'Thu'},
    {'day': 5, 'name': 'Fri'},
    {'day': 6, 'name': 'Sat'},
    {'day': 7, 'name': 'Sun'},
  ];

  @override
  Widget build(BuildContext context) {
    final slotsForDay = widget.timetable.where((t) => t.dayOfWeek == _selectedDay).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day selector tabs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'WEEKLY SCHEDULE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: AppColors.primary,
              ),
            ),
            TextButton.icon(
              onPressed: widget.onAddSlot,
              icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
              label: const Text('Add Class', style: TextStyle(color: AppColors.primary, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Day Chips
        Row(
          children: _days.map((d) {
            final dayNum = d['day'] as int;
            final dayName = d['name'] as String;
            final isSelected = _selectedDay == dayNum;
            final hasClasses = widget.timetable.any((t) => t.dayOfWeek == dayNum);

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: ChoiceChip(
                  label: Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedDay = dayNum);
                    }
                  },
                  selectedColor: AppColors.primaryContainer,
                  backgroundColor: AppColors.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : (hasClasses ? AppColors.outlineVariant.withValues(alpha: 0.4) : Colors.transparent),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Slot cards
        if (slotsForDay.isEmpty)
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
                Icon(Icons.event_available, size: 48, color: AppColors.outline),
                SizedBox(height: 12),
                Text(
                  'No classes scheduled for this day',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                SizedBox(height: 4),
                Text(
                  'Use the "Add Class" button above to insert a timetable slot.',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slotsForDay.length,
            itemBuilder: (context, index) {
              final slot = slotsForDay[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 50,
                        decoration: BoxDecoration(
                          color: slot.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slot.subjectName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: slot.color),
                                const SizedBox(width: 4),
                                Text(
                                  '${slot.startTime} - ${slot.endTime}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: slot.color,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  slot.room,
                                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                        onPressed: () => widget.onDeleteSlot(slot.id),
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
