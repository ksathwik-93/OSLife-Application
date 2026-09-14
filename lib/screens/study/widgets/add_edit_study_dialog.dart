import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/study_model.dart';
import '../../../providers/study_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/reminder_dropdown.dart';

enum StudyDialogMode {
  logSession,
  addAssignment,
  addExam,
  addClassSlot,
}

class AddEditStudyDialog extends StatefulWidget {
  final StudyDialogMode initialMode;
  final AssignmentModel? editAssignment;
  final ExamModel? editExam;

  const AddEditStudyDialog({
    super.key,
    this.initialMode = StudyDialogMode.logSession,
    this.editAssignment,
    this.editExam,
  });

  @override
  State<AddEditStudyDialog> createState() => _AddEditStudyDialogState();
}

class _AddEditStudyDialogState extends State<AddEditStudyDialog> {
  final _formKey = GlobalKey<FormState>();
  late StudyDialogMode _mode;

  // Common Subject Selection
  late String _selectedSubjectId;

  // Session Fields
  final TextEditingController _topicController = TextEditingController();
  int _durationMinutes = 60;

  // Assignment Fields
  final TextEditingController _assignmentTitleController = TextEditingController();
  late DateTime _assignmentDueDate;
  String _assignmentPriority = 'Medium';

  // Exam Fields
  final TextEditingController _examTitleController = TextEditingController();
  final TextEditingController _examLocationController = TextEditingController();
  late DateTime _examDate;
  int _examWeight = 20;

  // Timetable Slot Fields
  int _slotDayOfWeek = 1; // Mon
  final TextEditingController _slotStartTimeController = TextEditingController(text: '09:00 AM');
  final TextEditingController _slotEndTimeController = TextEditingController(text: '10:30 AM');
  final TextEditingController _slotRoomController = TextEditingController(text: 'Hall A101');

  // Reminder
  int? _assignmentReminder;
  int? _examReminder;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    if (widget.editAssignment != null) {
      _mode = StudyDialogMode.addAssignment;
      _assignmentTitleController.text = widget.editAssignment!.title;
      _assignmentDueDate = widget.editAssignment!.dueDate;
      _assignmentPriority = widget.editAssignment!.priority;
      _selectedSubjectId = widget.editAssignment!.subjectId;
      _assignmentReminder = widget.editAssignment!.reminderMinutesBefore;
    } else if (widget.editExam != null) {
      _mode = StudyDialogMode.addExam;
      _examTitleController.text = widget.editExam!.title;
      _examLocationController.text = widget.editExam!.location;
      _examDate = widget.editExam!.examDate;
      _examWeight = widget.editExam!.weightPercentage;
      _selectedSubjectId = widget.editExam!.subjectId;
      _examReminder = widget.editExam!.reminderMinutesBefore;
    } else {
      _assignmentDueDate = DateTime.now().add(const Duration(days: 3));
      _examDate = DateTime.now().add(const Duration(days: 7));
      _selectedSubjectId = '';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedSubjectId.isEmpty) {
      final provider = Provider.of<StudyProvider>(context, listen: false);
      if (provider.subjects.isNotEmpty) {
        _selectedSubjectId = provider.subjects.first.id;
      }
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    _assignmentTitleController.dispose();
    _examTitleController.dispose();
    _examLocationController.dispose();
    _slotStartTimeController.dispose();
    _slotEndTimeController.dispose();
    _slotRoomController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isAssignment) async {
    final initial = isAssignment ? _assignmentDueDate : _examDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.secondary,
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
        if (isAssignment) {
          _assignmentDueDate = picked;
        } else {
          _examDate = picked;
        }
      });
    }
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<StudyProvider>(context, listen: false);
    final subject = provider.subjects.firstWhere(
      (s) => s.id == _selectedSubjectId,
      orElse: () => provider.subjects.first,
    );

    switch (_mode) {
      case StudyDialogMode.logSession:
        provider.logStudySession(
          subjectId: subject.id,
          topic: _topicController.text.trim().isEmpty ? 'General Study' : _topicController.text.trim(),
          durationMinutes: _durationMinutes,
        );
        break;

      case StudyDialogMode.addAssignment:
        if (widget.editAssignment != null) {
          final updated = widget.editAssignment!.copyWith(
            subjectId: subject.id,
            subjectName: subject.name,
            title: _assignmentTitleController.text.trim(),
            dueDate: _assignmentDueDate,
            priority: _assignmentPriority,
            reminderMinutesBefore: _assignmentReminder,
          );
          provider.updateAssignment(updated);
        } else {
          final newAssignment = AssignmentModel(
            id: 'asgn_${DateTime.now().millisecondsSinceEpoch}',
            subjectId: subject.id,
            subjectName: subject.name,
            title: _assignmentTitleController.text.trim(),
            dueDate: _assignmentDueDate,
            priority: _assignmentPriority,
            reminderMinutesBefore: _assignmentReminder,
          );
          provider.addAssignment(newAssignment);
        }
        break;

      case StudyDialogMode.addExam:
        if (widget.editExam != null) {
          final updated = widget.editExam!.copyWith(
            subjectId: subject.id,
            subjectName: subject.name,
            title: _examTitleController.text.trim(),
            location: _examLocationController.text.trim(),
            examDate: _examDate,
            weightPercentage: _examWeight,
            reminderMinutesBefore: _examReminder,
          );
          provider.updateExam(updated);
        } else {
          final newExam = ExamModel(
            id: 'exam_${DateTime.now().millisecondsSinceEpoch}',
            subjectId: subject.id,
            subjectName: subject.name,
            title: _examTitleController.text.trim(),
            location: _examLocationController.text.trim(),
            examDate: _examDate,
            weightPercentage: _examWeight,
            reminderMinutesBefore: _examReminder,
          );
          provider.addExam(newExam);
        }
        break;

      case StudyDialogMode.addClassSlot:
        final newSlot = TimetableSlotModel(
          id: 'slot_${DateTime.now().millisecondsSinceEpoch}',
          subjectId: subject.id,
          subjectName: subject.name,
          dayOfWeek: _slotDayOfWeek,
          startTime: _slotStartTimeController.text.trim(),
          endTime: _slotEndTimeController.text.trim(),
          room: _slotRoomController.text.trim(),
          color: subject.color,
        );
        provider.addTimetableSlot(newSlot);
        break;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyProvider>(
      builder: (context, provider, child) {
        return Dialog(
          backgroundColor: AppColors.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
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
                          _getDialogTitle(),
                          style: const TextStyle(
                            fontSize: 18,
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
                    const SizedBox(height: 12),

                    // Segmented Mode Selector (if not editing)
                    if (widget.editAssignment == null && widget.editExam == null) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildModeChip('Log Session', StudyDialogMode.logSession),
                            const SizedBox(width: 6),
                            _buildModeChip('Assignment', StudyDialogMode.addAssignment),
                            const SizedBox(width: 6),
                            _buildModeChip('Exam', StudyDialogMode.addExam),
                            const SizedBox(width: 6),
                            _buildModeChip('Class Slot', StudyDialogMode.addClassSlot),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Subject Dropdown
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: provider.subjects.any((s) => s.id == _selectedSubjectId)
                          ? _selectedSubjectId
                          : (provider.subjects.isNotEmpty ? provider.subjects.first.id : null),
                      dropdownColor: AppColors.surfaceContainerHigh,
                      style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                      decoration: _buildInputDecoration('Subject', Icons.book_outlined),
                      items: provider.subjects.map((s) {
                        return DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedSubjectId = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Mode Dynamic Form Fields
                    if (_mode == StudyDialogMode.logSession) ...[
                      TextFormField(
                        controller: _topicController,
                        style: const TextStyle(color: AppColors.onSurface),
                        decoration: _buildInputDecoration('Topic / Focus Area', Icons.subject),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        // ignore: deprecated_member_use
                        value: _durationMinutes,
                        dropdownColor: AppColors.surfaceContainerHigh,
                        style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                        decoration: _buildInputDecoration('Session Duration', Icons.timer),
                        items: const [
                          DropdownMenuItem(value: 30, child: Text('30 Minutes')),
                          DropdownMenuItem(value: 45, child: Text('45 Minutes')),
                          DropdownMenuItem(value: 60, child: Text('1 Hour (60 mins)')),
                          DropdownMenuItem(value: 90, child: Text('1.5 Hours (90 mins)')),
                          DropdownMenuItem(value: 120, child: Text('2 Hours (120 mins)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _durationMinutes = val);
                        },
                      ),
                    ] else if (_mode == StudyDialogMode.addAssignment) ...[
                      TextFormField(
                        controller: _assignmentTitleController,
                        style: const TextStyle(color: AppColors.onSurface),
                        decoration: _buildInputDecoration('Assignment Title *', Icons.assignment_outlined),
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter title' : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(true),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Due Date', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                                    Text(
                                      DateFormat('MMM dd, yyyy').format(_assignmentDueDate),
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              // ignore: deprecated_member_use
                              value: _assignmentPriority,
                              dropdownColor: AppColors.surfaceContainerHigh,
                              style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                              decoration: _buildInputDecoration('Priority', Icons.priority_high),
                              items: ['High', 'Medium', 'Low'].map((p) {
                                return DropdownMenuItem(value: p, child: Text(p));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _assignmentPriority = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ] else if (_mode == StudyDialogMode.addExam) ...[
                      TextFormField(
                        controller: _examTitleController,
                        style: const TextStyle(color: AppColors.onSurface),
                        decoration: _buildInputDecoration('Exam Title *', Icons.event_note),
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter title' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _examLocationController,
                        style: const TextStyle(color: AppColors.onSurface),
                        decoration: _buildInputDecoration('Exam Hall / Location', Icons.location_on_outlined),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(false),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Exam Date', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                                    Text(
                                      DateFormat('MMM dd, yyyy').format(_examDate),
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              // ignore: deprecated_member_use
                              value: _examWeight,
                              dropdownColor: AppColors.surfaceContainerHigh,
                              style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                              decoration: _buildInputDecoration('Weight %', Icons.percent),
                              items: [10, 15, 20, 25, 30, 40, 50].map((w) {
                                return DropdownMenuItem(value: w, child: Text('$w% of Final'));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _examWeight = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ] else if (_mode == StudyDialogMode.addClassSlot) ...[
                      DropdownButtonFormField<int>(
                        // ignore: deprecated_member_use
                        value: _slotDayOfWeek,
                        dropdownColor: AppColors.surfaceContainerHigh,
                        style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                        decoration: _buildInputDecoration('Day of Week', Icons.calendar_view_week),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Monday')),
                          DropdownMenuItem(value: 2, child: Text('Tuesday')),
                          DropdownMenuItem(value: 3, child: Text('Wednesday')),
                          DropdownMenuItem(value: 4, child: Text('Thursday')),
                          DropdownMenuItem(value: 5, child: Text('Friday')),
                          DropdownMenuItem(value: 6, child: Text('Saturday')),
                          DropdownMenuItem(value: 7, child: Text('Sunday')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _slotDayOfWeek = val);
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _slotStartTimeController,
                              style: const TextStyle(color: AppColors.onSurface, fontSize: 13),
                              decoration: _buildInputDecoration('Start Time', Icons.schedule),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _slotEndTimeController,
                              style: const TextStyle(color: AppColors.onSurface, fontSize: 13),
                              decoration: _buildInputDecoration('End Time', Icons.schedule),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _slotRoomController,
                        style: const TextStyle(color: AppColors.onSurface, fontSize: 13),
                        decoration: _buildInputDecoration('Classroom / Room', Icons.meeting_room_outlined),
                      ),
                    ],
                    // Reminder for assignment / exam modes
                    if (_mode == StudyDialogMode.addAssignment) ...[
                      const SizedBox(height: 14),
                      ReminderDropdown(
                        value: _assignmentReminder,
                        onChanged: (v) => setState(() => _assignmentReminder = v),
                        label: 'Remind before due date',
                      ),
                    ] else if (_mode == StudyDialogMode.addExam) ...[
                      const SizedBox(height: 14),
                      ReminderDropdown(
                        value: _examReminder,
                        onChanged: (v) => setState(() => _examReminder = v),
                        label: 'Remind before exam',
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Actions
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
                            backgroundColor: AppColors.secondaryContainer,
                            foregroundColor: AppColors.onSecondaryContainer,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _saveForm,
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getDialogTitle() {
    switch (_mode) {
      case StudyDialogMode.logSession:
        return 'Log Study Session';
      case StudyDialogMode.addAssignment:
        return widget.editAssignment != null ? 'Edit Assignment' : 'Add Assignment';
      case StudyDialogMode.addExam:
        return widget.editExam != null ? 'Edit Exam' : 'Schedule Exam';
      case StudyDialogMode.addClassSlot:
        return 'Add Class Timetable Slot';
    }
  }

  Widget _buildModeChip(String label, StudyDialogMode mode) {
    final isSelected = _mode == mode;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _mode = mode);
      },
      selectedColor: AppColors.secondaryContainer,
      backgroundColor: AppColors.surfaceContainerLow,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.secondary, size: 18),
      filled: true,
      fillColor: AppColors.surfaceContainerHighest,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
      ),
    );
  }
}

