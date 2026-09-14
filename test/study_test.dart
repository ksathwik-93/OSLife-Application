import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos_flutter/models/study_model.dart';
import 'package:lifeos_flutter/providers/study_provider.dart';

void main() {
  group('StudyProvider Unit Tests', () {
    late StudyProvider provider;

    setUp(() {
      provider = StudyProvider(uid: 'test_user');
    });

    test('Initial sample study data loads correctly', () {
      expect(provider.subjects.length, 4);
      expect(provider.timetable.isNotEmpty, true);
      expect(provider.assignments.length, 4);
      expect(provider.exams.length, 3);
      expect(provider.sessions.isNotEmpty, true);
    });

    test('Logging a study session updates weekly hours and logs', () {
      final initialHours = provider.totalWeeklyStudyHours;
      final initialSessions = provider.sessions.length;

      provider.logStudySession(
        subjectId: provider.subjects.first.id,
        topic: 'Test Topic',
        durationMinutes: 60, // 1 hour
      );

      expect(provider.sessions.length, initialSessions + 1);
      expect(provider.totalWeeklyStudyHours, initialHours + 1.0);
    });

    test('Toggling assignment completion status updates pending count', () {
      final initialPending = provider.pendingAssignmentsCount;
      final assignmentId = provider.assignments.firstWhere((a) => !a.isCompleted).id;

      provider.toggleAssignment(assignmentId);

      expect(provider.pendingAssignmentsCount, initialPending - 1);
    });

    test('Next upcoming exam returns earliest uncompleted exam', () {
      final nextExam = provider.nextUpcomingExam;

      expect(nextExam, isNotNull);
      expect(nextExam!.daysRemaining >= 0, true);
      expect(nextExam.title, contains('Neural Networks'));
    });

    test('Adding a new timetable slot updates schedule', () {
      final initialSlots = provider.timetable.length;
      final newSlot = TimetableSlotModel(
        id: 'test_slot',
        subjectId: provider.subjects.first.id,
        subjectName: provider.subjects.first.name,
        dayOfWeek: 6, // Saturday
        startTime: '10:00 AM',
        endTime: '12:00 PM',
        room: 'Online Zoom',
        color: provider.subjects.first.color,
      );

      provider.addTimetableSlot(newSlot);

      expect(provider.timetable.length, initialSlots + 1);
      expect(provider.timetable.any((s) => s.id == 'test_slot'), true);
    });

    test('Deleting a subject removes its associated timetable slots and assignments', () {
      final subjectId = provider.subjects.first.id;

      provider.deleteSubject(subjectId);

      expect(provider.subjects.any((s) => s.id == subjectId), false);
      expect(provider.timetable.any((t) => t.subjectId == subjectId), false);
      expect(provider.assignments.any((a) => a.subjectId == subjectId), false);
    });
  });
}
