class EventModel {
  final String id;
  final String title;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String category;
  final int? reminderMinutesBefore; // null = no reminder

  EventModel({
    required this.id,
    required this.title,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.category,
    this.reminderMinutesBefore,
  });

  EventModel copyWith({
    String? id,
    String? title,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    String? category,
    Object? reminderMinutesBefore = _eventSentinel,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      reminderMinutesBefore: reminderMinutesBefore == _eventSentinel
          ? this.reminderMinutesBefore
          : reminderMinutesBefore as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'category': category,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }

  factory EventModel.fromMap(Map<dynamic, dynamic> map) {
    return EventModel(
      id: map['id'] as String,
      title: map['title'] as String,
      location: map['location'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      category: map['category'] as String,
      reminderMinutesBefore: map['reminderMinutesBefore'] as int?,
    );
  }
}

const Object _eventSentinel = Object();
