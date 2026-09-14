import 'package:flutter/material.dart';
import '../models/study_model.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

class StudyProvider extends ChangeNotifier {
  final String _uid;

  List<SubjectModel> _subjects = [];
  List<TimetableSlotModel> _timetable = [];
  List<AssignmentModel> _assignments = [];
  List<ExamModel> _exams = [];
  List<StudySessionModel> _sessions = [];

  StudyProvider({required String uid}) : _uid = uid {
    _loadInitialData();
  }

  void _loadInitialData() {
    // New users start with empty study planner — no sample data.
    if (HiveService.isUserBoxEmpty(HiveService.studySubjectsBoxName, _uid)) {
      _subjects = [];
    } else {
      _subjects = HiveService.getUserItems(HiveService.studySubjectsBoxName, _uid, (map) => SubjectModel.fromMap(map));
    }

    if (HiveService.isUserBoxEmpty(HiveService.studyTimetableBoxName, _uid)) {
      _timetable = [];
    } else {
      _timetable = HiveService.getUserItems(HiveService.studyTimetableBoxName, _uid, (map) => TimetableSlotModel.fromMap(map));
    }

    if (HiveService.isUserBoxEmpty(HiveService.studyAssignmentsBoxName, _uid)) {
      _assignments = [];
    } else {
      _assignments = HiveService.getUserItems(HiveService.studyAssignmentsBoxName, _uid, (map) => AssignmentModel.fromMap(map));
    }

    if (HiveService.isUserBoxEmpty(HiveService.studyExamsBoxName, _uid)) {
      _exams = [];
    } else {
      _exams = HiveService.getUserItems(HiveService.studyExamsBoxName, _uid, (map) => ExamModel.fromMap(map));
    }

    if (HiveService.isUserBoxEmpty(HiveService.studySessionsBoxName, _uid)) {
      _sessions = [];
    } else {
      _sessions = HiveService.getUserItems(HiveService.studySessionsBoxName, _uid, (map) => StudySessionModel.fromMap(map));
    }
  }

  String _selectedSubjectFilter = 'All';

  // Getters
  List<SubjectModel> get subjects => List.unmodifiable(_subjects);
  List<TimetableSlotModel> get timetable => List.unmodifiable(_timetable);
  List<AssignmentModel> get assignments => List.unmodifiable(_assignments);
  List<ExamModel> get exams => List.unmodifiable(_exams);
  List<StudySessionModel> get sessions => List.unmodifiable(_sessions);
  String get selectedSubjectFilter => _selectedSubjectFilter;

  // Filtered Getters
  List<AssignmentModel> get filteredAssignments {
    if (_selectedSubjectFilter == 'All') return _assignments;
    return _assignments.where((a) => a.subjectId == _selectedSubjectFilter).toList();
  }

  List<ExamModel> get filteredExams {
    if (_selectedSubjectFilter == 'All') return _exams;
    return _exams.where((e) => e.subjectId == _selectedSubjectFilter).toList();
  }

  // Calculated Statistics
  double get totalWeeklyStudyHours {
    return _subjects.fold(0.0, (sum, s) => sum + s.completedHoursThisWeek);
  }

  double get targetWeeklyStudyHours {
    return _subjects.fold(0.0, (sum, s) => sum + s.targetHoursPerWeek);
  }

  double get weeklyProgressRatio {
    if (targetWeeklyStudyHours == 0) return 0.0;
    return (totalWeeklyStudyHours / targetWeeklyStudyHours).clamp(0.0, 1.0);
  }

  int get pendingAssignmentsCount => _assignments.where((a) => !a.isCompleted).length;
  int get completedAssignmentsCount => _assignments.where((a) => a.isCompleted).length;

  ExamModel? get nextUpcomingExam {
    final upcoming = _exams.where((e) => !e.isCompleted && e.daysRemaining >= 0).toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    return upcoming.first;
  }

  // Actions: Subjects
  void addSubject(SubjectModel subject) {
    _subjects.add(subject);
    HiveService.saveUserItem(HiveService.studySubjectsBoxName, _uid, subject.id, subject.toMap());
    notifyListeners();
  }

  void updateSubject(SubjectModel subject) {
    final idx = _subjects.indexWhere((s) => s.id == subject.id);
    if (idx != -1) {
      _subjects[idx] = subject;
      HiveService.saveUserItem(HiveService.studySubjectsBoxName, _uid, subject.id, subject.toMap());
      notifyListeners();
    }
  }

  void deleteSubject(String id) {
    for (final t in _timetable.where((t) => t.subjectId == id)) {
      HiveService.deleteUserItem(HiveService.studyTimetableBoxName, _uid, t.id);
    }
    for (final a in _assignments.where((a) => a.subjectId == id)) {
      HiveService.deleteUserItem(HiveService.studyAssignmentsBoxName, _uid, a.id);
    }
    for (final e in _exams.where((e) => e.subjectId == id)) {
      HiveService.deleteUserItem(HiveService.studyExamsBoxName, _uid, e.id);
    }
    for (final s in _sessions.where((s) => s.subjectId == id)) {
      HiveService.deleteUserItem(HiveService.studySessionsBoxName, _uid, s.id);
    }
    HiveService.deleteUserItem(HiveService.studySubjectsBoxName, _uid, id);

    _subjects.removeWhere((s) => s.id == id);
    _timetable.removeWhere((t) => t.subjectId == id);
    _assignments.removeWhere((a) => a.subjectId == id);
    _exams.removeWhere((e) => e.subjectId == id);
    _sessions.removeWhere((s) => s.subjectId == id);
    notifyListeners();
  }

  // Actions: Timetable
  void addTimetableSlot(TimetableSlotModel slot) {
    _timetable.add(slot);
    HiveService.saveUserItem(HiveService.studyTimetableBoxName, _uid, slot.id, slot.toMap());
    notifyListeners();
  }

  void deleteTimetableSlot(String id) {
    _timetable.removeWhere((t) => t.id == id);
    HiveService.deleteUserItem(HiveService.studyTimetableBoxName, _uid, id);
    notifyListeners();
  }

  // Actions: Assignments
  void addAssignment(AssignmentModel assignment) {
    _assignments.insert(0, assignment);
    HiveService.saveUserItem(HiveService.studyAssignmentsBoxName, _uid, assignment.id, assignment.toMap());
    _scheduleAssignmentReminder(assignment);
    notifyListeners();
  }

  void updateAssignment(AssignmentModel assignment) {
    final idx = _assignments.indexWhere((a) => a.id == assignment.id);
    if (idx != -1) {
      LocalNotificationService.cancelReminder(LocalNotificationService.notificationIdFor(assignment.id));
      _assignments[idx] = assignment;
      HiveService.saveUserItem(HiveService.studyAssignmentsBoxName, _uid, assignment.id, assignment.toMap());
      _scheduleAssignmentReminder(assignment);
      notifyListeners();
    }
  }

  void toggleAssignment(String id) {
    final idx = _assignments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final a = _assignments[idx];
      _assignments[idx] = a.copyWith(isCompleted: !a.isCompleted);
      HiveService.saveUserItem(HiveService.studyAssignmentsBoxName, _uid, _assignments[idx].id, _assignments[idx].toMap());
      notifyListeners();
    }
  }

  void deleteAssignment(String id) {
    LocalNotificationService.cancelReminder(LocalNotificationService.notificationIdFor(id));
    _assignments.removeWhere((a) => a.id == id);
    HiveService.deleteUserItem(HiveService.studyAssignmentsBoxName, _uid, id);
    notifyListeners();
  }

  // Actions: Exams
  void addExam(ExamModel exam) {
    _exams.add(exam);
    HiveService.saveUserItem(HiveService.studyExamsBoxName, _uid, exam.id, exam.toMap());
    _scheduleExamReminder(exam);
    notifyListeners();
  }

  void updateExam(ExamModel exam) {
    final idx = _exams.indexWhere((e) => e.id == exam.id);
    if (idx != -1) {
      LocalNotificationService.cancelReminder(LocalNotificationService.notificationIdFor(exam.id));
      _exams[idx] = exam;
      HiveService.saveUserItem(HiveService.studyExamsBoxName, _uid, exam.id, exam.toMap());
      _scheduleExamReminder(exam);
      notifyListeners();
    }
  }

  void toggleExamCompletion(String id) {
    final idx = _exams.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final e = _exams[idx];
      _exams[idx] = e.copyWith(isCompleted: !e.isCompleted);
      HiveService.saveUserItem(HiveService.studyExamsBoxName, _uid, _exams[idx].id, _exams[idx].toMap());
      notifyListeners();
    }
  }

  void deleteExam(String id) {
    LocalNotificationService.cancelReminder(LocalNotificationService.notificationIdFor(id));
    _exams.removeWhere((e) => e.id == id);
    HiveService.deleteUserItem(HiveService.studyExamsBoxName, _uid, id);
    notifyListeners();
  }

  // Actions: Study Sessions
  void logStudySession({
    required String subjectId,
    required String topic,
    required int durationMinutes,
  }) {
    final subject = _subjects.firstWhere(
      (s) => s.id == subjectId,
      orElse: () => _subjects.first,
    );

    final session = StudySessionModel(
      id: 'sess_${DateTime.now().millisecondsSinceEpoch}',
      subjectId: subject.id,
      subjectName: subject.name,
      topic: topic,
      durationMinutes: durationMinutes,
      date: DateTime.now(),
    );

    _sessions.insert(0, session);
    HiveService.saveUserItem(HiveService.studySessionsBoxName, _uid, session.id, session.toMap());

    // Update subject completed hours
    final subjIdx = _subjects.indexWhere((s) => s.id == subject.id);
    if (subjIdx != -1) {
      final subj = _subjects[subjIdx];
      final addedHours = durationMinutes / 60.0;
      _subjects[subjIdx] = subj.copyWith(
        completedHoursThisWeek: subj.completedHoursThisWeek + addedHours,
      );
      HiveService.saveUserItem(HiveService.studySubjectsBoxName, _uid, _subjects[subjIdx].id, _subjects[subjIdx].toMap());
    }

    notifyListeners();
  }

  void deleteStudySession(String id) {
    _sessions.removeWhere((s) => s.id == id);
    HiveService.deleteUserItem(HiveService.studySessionsBoxName, _uid, id);
    notifyListeners();
  }

  void setSubjectFilter(String subjectId) {
    _selectedSubjectFilter = subjectId;
    notifyListeners();
  }

  void _scheduleAssignmentReminder(AssignmentModel assignment) {
    final mins = assignment.reminderMinutesBefore;
    if (mins == null) return;
    final reminderTime = assignment.dueDate.subtract(Duration(minutes: mins));
    LocalNotificationService.scheduleReminder(
      LocalNotificationService.notificationIdFor(assignment.id),
      '📚 Assignment Due: ${assignment.title}',
      'Due ${_formatRelative(mins)} — ${assignment.subjectName} (${assignment.priority} Priority)',
      reminderTime,
    );
  }

  void _scheduleExamReminder(ExamModel exam) {
    final mins = exam.reminderMinutesBefore;
    if (mins == null) return;
    final reminderTime = exam.examDate.subtract(Duration(minutes: mins));
    LocalNotificationService.scheduleReminder(
      LocalNotificationService.notificationIdFor(exam.id),
      '📝 Exam Reminder: ${exam.title}',
      'Exam ${_formatRelative(mins)} — ${exam.subjectName} (${exam.weightPercentage}% weight)',
      reminderTime,
    );
  }

  String _formatRelative(int minutes) {
    if (minutes < 60) return 'in $minutes min';
    if (minutes < 1440) return 'in ${minutes ~/ 60}h';
    if (minutes < 10080) return 'in ${minutes ~/ 1440} day(s)';
    return 'in ${minutes ~/ 10080} week(s)';
  }
}
