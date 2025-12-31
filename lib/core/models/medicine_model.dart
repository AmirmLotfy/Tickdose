import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineModel {
  final String id;
  final String userId;
  final String name;
  final String genericName;
  final String strength; // "500mg"
  final String form; // "tablet", "capsule", "liquid", "injection"
  final String dosage; // "1 tablet"
  final String frequency; // "daily", "twice daily", etc.
  final String manufacturer;
  final String batchNumber;
  final DateTime? expiryDate;
  final String prescribedBy;
  final DateTime? prescriptionDate;
  final int refillReminderDays;
  final List<String> sideEffects;
  final List<String> interactions;
  final String notes;
  final String? imageUrl;
  final String? doctorId;
  final int notificationId;
  final DateTime? imageCapturedAt;
  final String? barcode;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicineModel({
    required this.id,
    required this.userId,
    required this.name,
    this.genericName = '',
    required this.strength,
    required this.form,
    required this.dosage,
    required this.frequency,
    this.manufacturer = '',
    this.batchNumber = '',
    this.expiryDate,
    this.prescribedBy = '',
    this.prescriptionDate,
    this.refillReminderDays = 7,
    this.sideEffects = const [],
    this.interactions = const [],
    this.notes = '',
    this.imageUrl,
    this.doctorId,
    this.imageCapturedAt,
    this.notificationId = 0, // Default to 0 if not set
    this.barcode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicineModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicineModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      genericName: map['genericName'] ?? '',
      strength: map['strength'] ?? '',
      form: map['form'] ?? 'tablet',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      manufacturer: map['manufacturer'] ?? '',
      batchNumber: map['batchNumber'] ?? '',
      expiryDate: map['expiryDate'] != null ? (map['expiryDate'] as Timestamp).toDate() : null,
      prescribedBy: map['prescribedBy'] ?? '',
      prescriptionDate: map['prescriptionDate'] != null ? (map['prescriptionDate'] as Timestamp).toDate() : null,
      refillReminderDays: map['refillReminderDays'] ?? 7,
      sideEffects: List<String>.from(map['sideEffects'] ?? []),
      interactions: List<String>.from(map['interactions'] ?? []),
      notes: map['notes'] ?? '',
      imageUrl: map['imageUrl'],
      doctorId: map['doctorId'],
      imageCapturedAt: map['imageCapturedAt'] != null ? (map['imageCapturedAt'] as Timestamp).toDate() : null,
      notificationId: map['notificationId'] ?? 0,
      barcode: map['barcode'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'genericName': genericName,
      'strength': strength,
      'form': form,
      'dosage': dosage,
      'frequency': frequency,
      'manufacturer': manufacturer,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'prescribedBy': prescribedBy,
      'prescriptionDate': prescriptionDate != null ? Timestamp.fromDate(prescriptionDate!) : null,
      'refillReminderDays': refillReminderDays,
      'sideEffects': sideEffects,
      'interactions': interactions,
      'notes': notes,
      'imageUrl': imageUrl,
      'doctorId': doctorId,
      'imageCapturedAt': imageCapturedAt != null ? Timestamp.fromDate(imageCapturedAt!) : null,
      'notificationId': notificationId,
      'barcode': barcode,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  MedicineModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? genericName,
    String? strength,
    String? form,
    String? dosage,
    String? frequency,
    String? manufacturer,
    String? batchNumber,
    DateTime? expiryDate,
    String? prescribedBy,
    DateTime? prescriptionDate,
    int? refillReminderDays,
    List<String>? sideEffects,
    List<String>? interactions,
    String? notes,
    String? imageUrl,
    String? doctorId,
    DateTime? imageCapturedAt,
    int? notificationId,
    String? barcode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      strength: strength ?? this.strength,
      form: form ?? this.form,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      manufacturer: manufacturer ?? this.manufacturer,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      prescriptionDate: prescriptionDate ?? this.prescriptionDate,
      refillReminderDays: refillReminderDays ?? this.refillReminderDays,
      sideEffects: sideEffects ?? this.sideEffects,
      interactions: interactions ?? this.interactions,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      doctorId: doctorId ?? this.doctorId,
      imageCapturedAt: imageCapturedAt ?? this.imageCapturedAt,
      notificationId: notificationId ?? this.notificationId,
      barcode: barcode ?? this.barcode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }
}
