class TaskModel {
  final String id;
  final String title;
  final String category;
  final DateTime dueDate;
  final bool isCompleted;
  final String priority; // 'High', 'Medium', 'Low'
  final int? reminderMinutesBefore; // null = no reminder

  TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = 'Medium',
    this.reminderMinutesBefore,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? dueDate,
    bool? isCompleted,
    String? priority,
    Object? reminderMinutesBefore = _sentinel,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      reminderMinutesBefore: reminderMinutesBefore == _sentinel
          ? this.reminderMinutesBefore
          : reminderMinutesBefore as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }

  factory TaskModel.fromMap(Map<dynamic, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      isCompleted: map['isCompleted'] as bool? ?? false,
      priority: map['priority'] as String? ?? 'Medium',
      reminderMinutesBefore: map['reminderMinutesBefore'] as int?,
    );
  }
}

// Sentinel for nullable copyWith fields
const Object _sentinel = Object();
