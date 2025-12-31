import 'package:cloud_firestore/cloud_firestore.dart';

class SideEffectLog {
  final String id;
  final String userId;
  final String medicineId;
  final String medicineName;
  final String symptom;
  final String severity; // 'mild', 'moderate', 'severe'
  final DateTime occurredAt;
  final String notes;
  final DateTime createdAt;

  SideEffectLog({
    required this.id,
    required this.userId,
    required this.medicineId,
    required this.medicineName,
    required this.symptom,
    required this.severity,
    required this.occurredAt,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SideEffectLog.fromMap(Map<String, dynamic> map, String id) {
    return SideEffectLog(
      id: id,
      userId: map['userId'] ?? '',
      medicineId: map['medicineId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      symptom: map['symptom'] ?? '',
      severity: map['severity'] ?? 'mild',
      occurredAt: (map['occurredAt'] as Timestamp).toDate(),
      notes: map['notes'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'symptom': symptom,
      'severity': severity,
      'occurredAt': Timestamp.fromDate(occurredAt),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  SideEffectLog copyWith({
    String? id,
    String? userId,
    String? medicineId,
    String? medicineName,
    String? symptom,
    String? severity,
    DateTime? occurredAt,
    String? notes,
    DateTime? createdAt,
  }) {
    return SideEffectLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      symptom: symptom ?? this.symptom,
      severity: severity ?? this.severity,
      occurredAt: occurredAt ?? this.occurredAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
