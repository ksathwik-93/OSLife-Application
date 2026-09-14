import 'package:flutter/material.dart';

class SubjectModel {
  final String id;
  final String name;
  final String code;
  final Color color;
  final String instructor;
  final double targetHoursPerWeek;
  final double completedHoursThisWeek;

  SubjectModel({
    required this.id,
    required this.name,
    required this.code,
    required this.color,
    required this.instructor,
    this.targetHoursPerWeek = 5.0,
    this.completedHoursThisWeek = 0.0,
  });

  SubjectModel copyWith({
    String? id,
    String? name,
    String? code,
    Color? color,
    String? instructor,
    double? targetHoursPerWeek,
    double? completedHoursThisWeek,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      color: color ?? this.color,
      instructor: instructor ?? this.instructor,
      targetHoursPerWeek: targetHoursPerWeek ?? this.targetHoursPerWeek,
      completedHoursThisWeek: completedHoursThisWeek ?? this.completedHoursThisWeek,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'color': color.toARGB32(),
      'instructor': instructor,
      'targetHoursPerWeek': targetHoursPerWeek,
      'completedHoursThisWeek': completedHoursThisWeek,
    };
  }

  factory SubjectModel.fromMap(Map<dynamic, dynamic> map) {
    return SubjectModel(
      id: map['id'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      color: Color(map['color'] as int),
      instructor: map['instructor'] as String,
      targetHoursPerWeek: (map['targetHoursPerWeek'] as num?)?.toDouble() ?? 5.0,
      completedHoursThisWeek: (map['completedHoursThisWeek'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TimetableSlotModel {
  final String id;
  final String subjectId;
  final String subjectName;
  final int dayOfWeek; // 1 = Mon, 2 = Tue, ..., 7 = Sun
  final String startTime;
  final String endTime;
  final String room;
  final Color color;

  TimetableSlotModel({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.color,
  });

  String get dayName {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Day $dayOfWeek';
    }
  }

  TimetableSlotModel copyWith({
    String? id,
    String? subjectId,
    String? subjectName,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
    Color? color,
  }) {
    return TimetableSlotModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'color': color.toARGB32(),
    };
  }

  factory TimetableSlotModel.fromMap(Map<dynamic, dynamic> map) {
    return TimetableSlotModel(
      id: map['id'] as String,
      subjectId: map['subjectId'] as String,
      subjectName: map['subjectName'] as String,
      dayOfWeek: map['dayOfWeek'] as int,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      room: map['room'] as String,
      color: Color(map['color'] as int),
    );
  }
}

class AssignmentModel {
  final String id;
  final String subjectId;
  final String subjectName;
  final String title;
  final DateTime dueDate;
  final bool isCompleted;
  final String priority; // 'High', 'Medium', 'Low'
  final int? reminderMinutesBefore; // null = no reminder

  AssignmentModel({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = 'Medium',
    this.reminderMinutesBefore,
  });

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return target.difference(today).inDays;
  }

  AssignmentModel copyWith({
    String? id,
    String? subjectId,
    String? subjectName,
    String? title,
    DateTime? dueDate,
    bool? isCompleted,
    String? priority,
    Object? reminderMinutesBefore = _studySentinel,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      reminderMinutesBefore: reminderMinutesBefore == _studySentinel
          ? this.reminderMinutesBefore
          : reminderMinutesBefore as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }

  factory AssignmentModel.fromMap(Map<dynamic, dynamic> map) {
    return AssignmentModel(
      id: map['id'] as String,
      subjectId: map['subjectId'] as String,
      subjectName: map['subjectName'] as String,
      title: map['title'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      isCompleted: map['isCompleted'] as bool? ?? false,
      priority: map['priority'] as String? ?? 'Medium',
      reminderMinutesBefore: map['reminderMinutesBefore'] as int?,
    );
  }
}

class ExamModel {
  final String id;
  final String subjectId;
  final String subjectName;
  final String title;
  final DateTime examDate;
  final String location;
  final int weightPercentage;
  final bool isCompleted;
  final int? reminderMinutesBefore; // null = no reminder

  ExamModel({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.title,
    required this.examDate,
    required this.location,
    this.weightPercentage = 20,
    this.isCompleted = false,
    this.reminderMinutesBefore,
  });

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(examDate.year, examDate.month, examDate.day);
    return target.difference(today).inDays;
  }

  ExamModel copyWith({
    String? id,
    String? subjectId,
    String? subjectName,
    String? title,
    DateTime? examDate,
    String? location,
    int? weightPercentage,
    bool? isCompleted,
    Object? reminderMinutesBefore = _studySentinel,
  }) {
    return ExamModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      title: title ?? this.title,
      examDate: examDate ?? this.examDate,
      location: location ?? this.location,
      weightPercentage: weightPercentage ?? this.weightPercentage,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderMinutesBefore: reminderMinutesBefore == _studySentinel
          ? this.reminderMinutesBefore
          : reminderMinutesBefore as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'title': title,
      'examDate': examDate.toIso8601String(),
      'location': location,
      'weightPercentage': weightPercentage,
      'isCompleted': isCompleted,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }

  factory ExamModel.fromMap(Map<dynamic, dynamic> map) {
    return ExamModel(
      id: map['id'] as String,
      subjectId: map['subjectId'] as String,
      subjectName: map['subjectName'] as String,
      title: map['title'] as String,
      examDate: DateTime.parse(map['examDate'] as String),
      location: map['location'] as String,
      weightPercentage: map['weightPercentage'] as int? ?? 20,
      isCompleted: map['isCompleted'] as bool? ?? false,
      reminderMinutesBefore: map['reminderMinutesBefore'] as int?,
    );
  }
}

const Object _studySentinel = Object();

class StudySessionModel {
  final String id;
  final String subjectId;
  final String subjectName;
  final String topic;
  final int durationMinutes;
  final DateTime date;
  final bool isCompleted;

  StudySessionModel({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.topic,
    required this.durationMinutes,
    required this.date,
    this.isCompleted = true,
  });

  StudySessionModel copyWith({
    String? id,
    String? subjectId,
    String? subjectName,
    String? topic,
    int? durationMinutes,
    DateTime? date,
    bool? isCompleted,
  }) {
    return StudySessionModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      topic: topic ?? this.topic,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'topic': topic,
      'durationMinutes': durationMinutes,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory StudySessionModel.fromMap(Map<dynamic, dynamic> map) {
    return StudySessionModel(
      id: map['id'] as String,
      subjectId: map['subjectId'] as String,
      subjectName: map['subjectName'] as String,
      topic: map['topic'] as String,
      durationMinutes: map['durationMinutes'] as int,
      date: DateTime.parse(map['date'] as String),
      isCompleted: map['isCompleted'] as bool? ?? true,
    );
  }
}
