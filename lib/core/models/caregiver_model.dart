import 'package:cloud_firestore/cloud_firestore.dart';

/// Caregiver permissions
enum CaregiverPermission {
  viewMedications,
  viewAdherence,
  receiveAlerts,
  sendReminders,
}

/// Model representing a caregiver relationship
class CaregiverModel {
  final String id;
  final String userId; // The user being cared for
  final String? caregiverUserId; // Caregiver's user ID (if they have an account)
  final String caregiverEmail;
  final String caregiverName;
  final List<CaregiverPermission> permissions;
  final String relationship; // "family", "friend", "nurse", etc.
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  CaregiverModel({
    required this.id,
    required this.userId,
    this.caregiverUserId,
    required this.caregiverEmail,
    required this.caregiverName,
    required this.permissions,
    this.relationship = 'family',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'caregiverUserId': caregiverUserId,
      'caregiverEmail': caregiverEmail,
      'caregiverName': caregiverName,
      'permissions': permissions.map((p) => p.name).toList(),
      'relationship': relationship,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory CaregiverModel.fromMap(Map<String, dynamic> map, String id) {
    return CaregiverModel(
      id: id,
      userId: map['userId'] ?? '',
      caregiverUserId: map['caregiverUserId'],
      caregiverEmail: map['caregiverEmail'] ?? '',
      caregiverName: map['caregiverName'] ?? '',
      permissions: (map['permissions'] as List<dynamic>?)
              ?.map((p) => CaregiverPermission.values.firstWhere(
                    (perm) => perm.name == p,
                    orElse: () => CaregiverPermission.viewMedications,
                  ))
              .toList() ??
          [CaregiverPermission.viewMedications],
      relationship: map['relationship'] ?? 'family',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  CaregiverModel copyWith({
    String? id,
    String? userId,
    String? caregiverUserId,
    String? caregiverEmail,
    String? caregiverName,
    List<CaregiverPermission>? permissions,
    String? relationship,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return CaregiverModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      caregiverUserId: caregiverUserId ?? this.caregiverUserId,
      caregiverEmail: caregiverEmail ?? this.caregiverEmail,
      caregiverName: caregiverName ?? this.caregiverName,
      permissions: permissions ?? this.permissions,
      relationship: relationship ?? this.relationship,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool hasPermission(CaregiverPermission permission) {
    return permissions.contains(permission);
  }
}

/// Caregiver settings for notification preferences
class CaregiverSettings {
  final bool notifyOnMissedDose;
  final bool notifyOnSideEffects;
  final bool receiveDailySummary;
  final bool receiveWeeklySummary;
  final String preferredNotificationTime; // HH:mm format

  CaregiverSettings({
    this.notifyOnMissedDose = true,
    this.notifyOnSideEffects = true,
    this.receiveDailySummary = false,
    this.receiveWeeklySummary = true,
    this.preferredNotificationTime = '20:00', // 8 PM default
  });

  Map<String, dynamic> toMap() {
    return {
      'notifyOnMissedDose': notifyOnMissedDose,
      'notifyOnSideEffects': notifyOnSideEffects,
      'receiveDailySummary': receiveDailySummary,
      'receiveWeeklySummary': receiveWeeklySummary,
      'preferredNotificationTime': preferredNotificationTime,
    };
  }

  factory CaregiverSettings.fromMap(Map<String, dynamic> map) {
    return CaregiverSettings(
      notifyOnMissedDose: map['notifyOnMissedDose'] ?? true,
      notifyOnSideEffects: map['notifyOnSideEffects'] ?? true,
      receiveDailySummary: map['receiveDailySummary'] ?? false,
      receiveWeeklySummary: map['receiveWeeklySummary'] ?? true,
      preferredNotificationTime: map['preferredNotificationTime'] ?? '20:00',
    );
  }
}
