class Lesson {
  final int? id;
  final int groupId;
  final DateTime date;
  final String topic;
  final String? notes;
  final DateTime createdAt;

  Lesson({
    this.id,
    required this.groupId,
    required this.date,
    required this.topic,
    this.notes,
    required this.createdAt,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] as int?,
      groupId: map['groupId'] as int,
      date: DateTime.parse(map['date'] as String),
      topic: map['topic'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'date': date.toIso8601String(),
      'topic': topic,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Lesson copyWith({
    int? id,
    int? groupId,
    DateTime? date,
    String? topic,
    String? notes,
    DateTime? createdAt,
  }) {
    return Lesson(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      date: date ?? this.date,
      topic: topic ?? this.topic,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}