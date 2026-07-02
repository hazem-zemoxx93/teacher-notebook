class Student {
  final int? id;
  final String fullName;
  final String phoneNumber;
  final String? parentPhone;
  final int groupId;
  final double? monthlyFeeOverride;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Student({
    this.id,
    required this.fullName,
    required this.phoneNumber,
    this.parentPhone,
    required this.groupId,
    this.monthlyFeeOverride,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      fullName: map['fullName'] as String,
      phoneNumber: map['phoneNumber'] as String,
      parentPhone: map['parentPhone'] as String?,
      groupId: map['groupId'] as int,
      monthlyFeeOverride: map['monthlyFeeOverride'] as double?,
      notes: map['notes'] as String?,
      isActive: (map['isActive'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'parentPhone': parentPhone,
      'groupId': groupId,
      'monthlyFeeOverride': monthlyFeeOverride,
      'notes': notes,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Student copyWith({
    int? id,
    String? fullName,
    String? phoneNumber,
    String? parentPhone,
    int? groupId,
    double? monthlyFeeOverride,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      parentPhone: parentPhone ?? this.parentPhone,
      groupId: groupId ?? this.groupId,
      monthlyFeeOverride: monthlyFeeOverride ?? this.monthlyFeeOverride,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}