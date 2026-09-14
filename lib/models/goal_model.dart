class MilestoneModel {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;

  MilestoneModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
  });

  MilestoneModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
  }) {
    return MilestoneModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory MilestoneModel.fromMap(Map<dynamic, dynamic> map) {
    return MilestoneModel(
      id: map['id'] as String,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] as bool? ?? false,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
    );
  }
}

class GoalModel {
  final String id;
  final String title;
  final String description;
  final double progress; // 0.0 to 1.0
  final DateTime targetDate;
  final DateTime startDate;
  final String category;
  final String priority; // 'High', 'Medium', 'Low'
  final List<MilestoneModel> milestones;
  final bool isCompleted;
  final int? reminderMinutesBefore; // null = no reminder

  GoalModel({
    required this.id,
    required this.title,
    required this.description,
    double? progress,
    required this.targetDate,
    DateTime? startDate,
    required this.category,
    this.priority = 'Medium',
    List<MilestoneModel>? milestones,
    bool? isCompleted,
    this.reminderMinutesBefore,
  })  : milestones = milestones ?? [],
        startDate = startDate ?? DateTime.now(),
        isCompleted = isCompleted ?? false,
        progress = progress ??
            (milestones != null && milestones.isNotEmpty
                ? milestones.where((m) => m.isCompleted).length / milestones.length
                : 0.0);

  int get completedMilestonesCount => milestones.where((m) => m.isCompleted).length;
  int get totalMilestonesCount => milestones.length;

  double get calculatedProgress {
    if (isCompleted) return 1.0;
    if (milestones.isNotEmpty) {
      return completedMilestonesCount / totalMilestonesCount;
    }
    return progress;
  }

  bool get isAchieved => isCompleted || (milestones.isNotEmpty && completedMilestonesCount == totalMilestonesCount) || progress >= 1.0;

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(today).inDays;
  }

  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    double? progress,
    DateTime? targetDate,
    DateTime? startDate,
    String? category,
    String? priority,
    List<MilestoneModel>? milestones,
    bool? isCompleted,
    Object? reminderMinutesBefore = _goalSentinel,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      targetDate: targetDate ?? this.targetDate,
      startDate: startDate ?? this.startDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      milestones: milestones ?? this.milestones,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderMinutesBefore: reminderMinutesBefore == _goalSentinel
          ? this.reminderMinutesBefore
          : reminderMinutesBefore as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'progress': progress,
      'targetDate': targetDate.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'category': category,
      'priority': priority,
      'milestones': milestones.map((m) => m.toMap()).toList(),
      'isCompleted': isCompleted,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }

  factory GoalModel.fromMap(Map<dynamic, dynamic> map) {
    final rawMilestones = map['milestones'] as List<dynamic>? ?? [];
    final milestoneList = rawMilestones
        .map((m) => MilestoneModel.fromMap(Map<dynamic, dynamic>.from(m as Map)))
        .toList();

    return GoalModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      progress: (map['progress'] as num?)?.toDouble(),
      targetDate: DateTime.parse(map['targetDate'] as String),
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate'] as String) : null,
      category: map['category'] as String,
      priority: map['priority'] as String? ?? 'Medium',
      milestones: milestoneList,
      isCompleted: map['isCompleted'] as bool?,
      reminderMinutesBefore: map['reminderMinutesBefore'] as int?,
    );
  }
}

const Object _goalSentinel = Object();
