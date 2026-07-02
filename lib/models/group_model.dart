class Group {
  final int? id;
  final String name;
  final String subject;
  final String schedule;
  final double monthlyFee;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Group({
    this.id,
    required this.name,
    required this.subject,
    required this.schedule,
    required this.monthlyFee,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] as int?,
      name: map['name'] as String,
      subject: map['subject'] as String,
      schedule: map['schedule'] as String,
      monthlyFee: (map['monthlyFee'] as num).toDouble(),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'schedule': schedule,
      'monthlyFee': monthlyFee,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Group copyWith({
    int? id,
    String? name,
    String? subject,
    String? schedule,
    double? monthlyFee,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      schedule: schedule ?? this.schedule,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
