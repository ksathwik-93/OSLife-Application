import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/goal_model.dart';
import '../../../providers/goal_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/reminder_dropdown.dart';

class AddEditGoalDialog extends StatefulWidget {
  final GoalModel? goal;

  const AddEditGoalDialog({super.key, this.goal});

  @override
  State<AddEditGoalDialog> createState() => _AddEditGoalDialogState();
}

class _AddEditGoalDialogState extends State<AddEditGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  late String _selectedPriority;
  late DateTime _targetDate;
  final List<TextEditingController> _milestoneControllers = [];
  int? _selectedReminder;

  bool get isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    _titleController = TextEditingController(text: g?.title ?? '');
    _descriptionController = TextEditingController(text: g?.description ?? '');
    _selectedCategory = g?.category ?? 'Career';
    _selectedPriority = g?.priority ?? 'Medium';
    _targetDate = g?.targetDate ?? DateTime.now().add(const Duration(days: 30));
    _selectedReminder = g?.reminderMinutesBefore;

    if (g != null && g.milestones.isNotEmpty) {
      for (final m in g.milestones) {
        _milestoneControllers.add(TextEditingController(text: m.title));
      }
    } else {
      _milestoneControllers.add(TextEditingController(text: 'Initial Setup & Research'));
      _milestoneControllers.add(TextEditingController(text: 'Execution & Monitoring'));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final c in _milestoneControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addMilestoneField() {
    setState(() {
      _milestoneControllers.add(TextEditingController());
    });
  }

  void _removeMilestoneField(int index) {
    setState(() {
      _milestoneControllers[index].dispose();
      _milestoneControllers.removeAt(index);
    });
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surfaceContainerLow,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<GoalProvider>(context, listen: false);

      final milestones = _milestoneControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .map((t) => MilestoneModel(
                id: 'm_${DateTime.now().millisecondsSinceEpoch}_${t.hashCode}',
                title: t,
                isCompleted: false,
              ))
          .toList();

      if (isEditing) {
        // Keep existing completion status for unchanged milestones
        final existingMilestones = widget.goal!.milestones;
        final updatedMilestones = _milestoneControllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .map((t) {
          final existing = existingMilestones.firstWhere(
            (em) => em.title.toLowerCase() == t.toLowerCase(),
            orElse: () => MilestoneModel(
              id: 'm_${DateTime.now().millisecondsSinceEpoch}_${t.hashCode}',
              title: t,
              isCompleted: false,
            ),
          );
          return existing.copyWith(title: t);
        }).toList();

        final updated = widget.goal!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          priority: _selectedPriority,
          targetDate: _targetDate,
          milestones: updatedMilestones,
          reminderMinutesBefore: _selectedReminder,
        );
        provider.updateGoal(updated);
      } else {
        final newGoal = GoalModel(
          id: 'g_${DateTime.now().millisecondsSinceEpoch}',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          priority: _selectedPriority,
          targetDate: _targetDate,
          startDate: DateTime.now(),
          milestones: milestones,
          reminderMinutesBefore: _selectedReminder,
        );
        provider.addGoal(newGoal);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = GoalProvider.categories.where((c) => c != 'All').toList();
    final formattedDate = DateFormat('MMM dd, yyyy').format(_targetDate);

    return Dialog(
      backgroundColor: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 540),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Goal' : 'Create New Goal',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.onSurface),
                  decoration: _buildInputDecoration('Goal Title *', Icons.flag_outlined),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a goal title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  style: const TextStyle(color: AppColors.onSurface),
                  decoration: _buildInputDecoration('Description (optional)', Icons.notes),
                ),
                const SizedBox(height: 14),

                // Category & Priority Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _selectedCategory,
                        dropdownColor: AppColors.surfaceContainerHigh,
                        style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                        decoration: _buildInputDecoration('Category', Icons.category_outlined),
                        items: categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCategory = val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _selectedPriority,
                        dropdownColor: AppColors.surfaceContainerHigh,
                        style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                        decoration: _buildInputDecoration('Priority', Icons.priority_high),
                        items: ['High', 'Medium', 'Low'].map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedPriority = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Target Date Picker
                InkWell(
                  onTap: _pickTargetDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.event_outlined, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Target Deadline',
                                  style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                                ),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down, color: AppColors.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Reminder Selector
                ReminderDropdown(
                  value: _selectedReminder,
                  onChanged: (v) => setState(() => _selectedReminder = v),
                  label: 'Remind me before deadline',
                ),
                const SizedBox(height: 20),

                // Milestones section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MILESTONES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: AppColors.primary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addMilestoneField,
                      icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                      label: const Text('Add Step', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ...List.generate(_milestoneControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _milestoneControllers[index],
                            style: const TextStyle(fontSize: 13, color: AppColors.onSurface),
                            decoration: InputDecoration(
                              hintText: 'Step ${index + 1} milestone...',
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
                          ),
                        ),
                        if (_milestoneControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 20, color: AppColors.error),
                            onPressed: () => _removeMilestoneField(index),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: AppColors.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveForm,
                      icon: Icon(isEditing ? Icons.check : Icons.add_task, size: 18),
                      label: Text(isEditing ? 'Save Changes' : 'Create Goal'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: AppColors.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

