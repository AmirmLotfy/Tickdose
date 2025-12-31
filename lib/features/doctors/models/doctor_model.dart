import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor {
  final String id;
  final String userId;
  final String name;
  final String phoneNumber;
  final String dialCode;
  final String specialization;
  final DateTime createdAt;

  Doctor({
    required this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.dialCode,
    required this.specialization,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'phoneNumber': phoneNumber,
      'dialCode': dialCode,
      'specialization': specialization,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map, String id) {
    return Doctor(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      dialCode: map['dialCode'] ?? '',
      specialization: map['specialization'] ?? 'General',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
