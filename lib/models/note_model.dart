class NoteModel {
  final String id;
  final String title;
  final String content;
  final String tag;
  final DateTime updatedAt;
  final bool isPinned;
  final String colorHex;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.tag,
    required this.updatedAt,
    this.isPinned = false,
    this.colorHex = '#7C3AED',
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? tag,
    DateTime? updatedAt,
    bool? isPinned,
    String? colorHex,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tag: tag ?? this.tag,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tag': tag,
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
      'colorHex': colorHex,
    };
  }

  factory NoteModel.fromMap(Map<dynamic, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      tag: map['tag'] as String,
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isPinned: map['isPinned'] as bool? ?? false,
      colorHex: map['colorHex'] as String? ?? '#7C3AED',
    );
  }
}
