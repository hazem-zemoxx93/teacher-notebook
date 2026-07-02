class Attendance {
  final int? id;
  final int studentId;
  final int lessonId;
  final bool isPresent;
  final DateTime recordedAt;

  Attendance({
    this.id,
    required this.studentId,
    required this.lessonId,
    required this.isPresent,
    required this.recordedAt,
  });

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] as int?,
      studentId: map['studentId'] as int,
      lessonId: map['lessonId'] as int,
      isPresent: (map['isPresent'] as int?) == 1,
      recordedAt: DateTime.parse(map['recordedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'lessonId': lessonId,
      'isPresent': isPresent ? 1 : 0,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  Attendance copyWith({
    int? id,
    int? studentId,
    int? lessonId,
    bool? isPresent,
    DateTime? recordedAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      lessonId: lessonId ?? this.lessonId,
      isPresent: isPresent ?? this.isPresent,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}
