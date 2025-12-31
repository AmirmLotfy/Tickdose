import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineLogModel {
  final String id;
  final String userId;
  final String medicineId;
  final String medicineName;
  final DateTime takenAt;
  final String status; // 'taken', 'skipped'
  final String? notes;

  MedicineLogModel({
    required this.id,
    required this.userId,
    required this.medicineId,
    required this.medicineName,
    required this.takenAt,
    required this.status,
    this.notes,
  });

  factory MedicineLogModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicineLogModel(
      id: id,
      userId: map['userId'] ?? '',
      medicineId: map['medicineId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      takenAt: (map['takenAt'] as Timestamp).toDate(),
      status: map['status'] ?? 'taken',
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'takenAt': Timestamp.fromDate(takenAt),
      'status': status,
      'notes': notes,
    };
  }
}
