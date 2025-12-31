import 'package:cloud_firestore/cloud_firestore.dart';
import 'caregiver_model.dart';

enum ReminderStyle {
  strict,
  flexible,
}

class NotificationSettings {
  final bool enableNotifications;
  final bool enableSound;
  final bool enableVibration;
  final String quietHoursStart; // "22:00"
  final String quietHoursEnd;   // "08:00"

  NotificationSettings({
    this.enableNotifications = true,
    this.enableSound = true,
    this.enableVibration = true,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '08:00',
  });

  Map<String, dynamic> toMap() {
    return {
      'enableNotifications': enableNotifications,
      'enableSound': enableSound,
      'enableVibration': enableVibration,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      enableNotifications: map['enableNotifications'] ?? true,
      enableSound: map['enableSound'] ?? true,
      enableVibration: map['enableVibration'] ?? true,
      quietHoursStart: map['quietHoursStart'] ?? '22:00',
      quietHoursEnd: map['quietHoursEnd'] ?? '08:00',
    );
  }

  NotificationSettings copyWith({
    bool? enableNotifications,
    bool? enableSound,
    bool? enableVibration,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationSettings(
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableSound: enableSound ?? this.enableSound,
      enableVibration: enableVibration ?? this.enableVibration,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}

class EmergencyContact {
  final String name;
  final String phone;
  final String whatsapp;

  EmergencyContact({
    required this.name,
    required this.phone,
    this.whatsapp = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'whatsapp': whatsapp,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
    );
  }
}

class DoctorInfo {
  final String name;
  final String phone;
  final String whatsapp;
  final String specialty;

  DoctorInfo({
    required this.name,
    required this.phone,
    this.whatsapp = '',
    this.specialty = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'whatsapp': whatsapp,
      'specialty': specialty,
    };
  }

  factory DoctorInfo.fromMap(Map<String, dynamic> map) {
    return DoctorInfo(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      specialty: map['specialty'] ?? '',
    );
  }
}

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String phone;
  final String profileImageUrl;
  final String language; // 'en' or 'ar'
  final String country;
  final List<String> healthConditions;
  final List<String> allergies;
  final List<EmergencyContact> emergencyContacts;
  final DoctorInfo? doctorInfo;
  final NotificationSettings notificationSettings;
  
  // Timezone and routine fields
  final String timezone; // e.g., "Africa/Cairo"
  final bool timezoneAutoDetect;
  final String breakfastTime; // HH:mm format
  final String lunchTime; // HH:mm format
  final String dinnerTime; // HH:mm format
  final String sleepTime; // HH:mm format
  final String wakeTime; // HH:mm format
  
  // Health profile fields
  final int? age;
  final String? gender;
  final double? weight; // in kg
  final double? height; // in cm
  
  // Reminder preferences
  final ReminderStyle reminderStyle;
  final int flexibilityWindow; // minutes, default 30
  
  // Caregiver support
  final List<String> caregivers; // List of caregiver IDs
  final CaregiverSettings? caregiverSettings;
  
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.phone = '',
    this.profileImageUrl = '',
    this.language = 'en',
    this.country = '',
    this.healthConditions = const [],
    this.allergies = const [],
    this.emergencyContacts = const [],
    this.doctorInfo,
    NotificationSettings? notificationSettings,
    this.timezone = 'Africa/Cairo',
    this.timezoneAutoDetect = true,
    this.breakfastTime = '08:00',
    this.lunchTime = '13:00',
    this.dinnerTime = '19:00',
    this.sleepTime = '22:00',
    this.wakeTime = '07:00',
    this.age,
    this.gender,
    this.weight,
    this.height,
    this.reminderStyle = ReminderStyle.flexible,
    this.flexibilityWindow = 30,
    this.caregivers = const [],
    this.caregiverSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
  })  : notificationSettings = notificationSettings ?? NotificationSettings(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        lastLogin = lastLogin ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'language': language,
      'country': country,
      'healthConditions': healthConditions,
      'allergies': allergies,
      'emergencyContacts': emergencyContacts.map((e) => e.toMap()).toList(),
      'doctorInfo': doctorInfo?.toMap(),
      'notificationSettings': notificationSettings.toMap(),
      'timezone': timezone,
      'timezoneAutoDetect': timezoneAutoDetect,
      'breakfastTime': breakfastTime,
      'lunchTime': lunchTime,
      'dinnerTime': dinnerTime,
      'sleepTime': sleepTime,
      'wakeTime': wakeTime,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'reminderStyle': reminderStyle.name,
      'flexibilityWindow': flexibilityWindow,
      'caregivers': caregivers,
      'caregiverSettings': caregiverSettings?.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      language: map['language'] ?? 'en',
      country: map['country'] ?? '',
      healthConditions: List<String>.from(map['healthConditions'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
      emergencyContacts: (map['emergencyContacts'] as List?)
              ?.map((e) => EmergencyContact.fromMap(e))
              .toList() ??
          [],
      doctorInfo: map['doctorInfo'] != null
          ? DoctorInfo.fromMap(map['doctorInfo'])
          : null,
      notificationSettings: map['notificationSettings'] != null
          ? NotificationSettings.fromMap(map['notificationSettings'])
          : NotificationSettings(),
      timezone: map['timezone'] ?? 'Africa/Cairo',
      timezoneAutoDetect: map['timezoneAutoDetect'] ?? true,
      breakfastTime: map['breakfastTime'] ?? '08:00',
      lunchTime: map['lunchTime'] ?? '13:00',
      dinnerTime: map['dinnerTime'] ?? '19:00',
      sleepTime: map['sleepTime'] ?? '22:00',
      wakeTime: map['wakeTime'] ?? '07:00',
      age: map['age'] != null ? (map['age'] is int ? map['age'] : int.tryParse(map['age'].toString())) : null,
      gender: map['gender'],
      weight: map['weight'] != null ? (map['weight'] is double ? map['weight'] : double.tryParse(map['weight'].toString())) : null,
      height: map['height'] != null ? (map['height'] is double ? map['height'] : double.tryParse(map['height'].toString())) : null,
      reminderStyle: map['reminderStyle'] != null
          ? ReminderStyle.values.firstWhere(
              (e) => e.name == map['reminderStyle'],
              orElse: () => ReminderStyle.flexible,
            )
          : ReminderStyle.flexible,
      flexibilityWindow: map['flexibilityWindow'] ?? 30,
      caregivers: List<String>.from(map['caregivers'] ?? []),
      caregiverSettings: map['caregiverSettings'] != null
          ? CaregiverSettings.fromMap(map['caregiverSettings'])
          : null,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phone,
    String? profileImageUrl,
    String? language,
    String? country,
    List<String>? healthConditions,
    List<String>? allergies,
    List<EmergencyContact>? emergencyContacts,
    DoctorInfo? doctorInfo,
    NotificationSettings? notificationSettings,
    String? timezone,
    bool? timezoneAutoDetect,
    String? breakfastTime,
    String? lunchTime,
    String? dinnerTime,
    String? sleepTime,
    String? wakeTime,
    int? age,
    String? gender,
    double? weight,
    double? height,
    ReminderStyle? reminderStyle,
    int? flexibilityWindow,
    List<String>? caregivers,
    CaregiverSettings? caregiverSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      language: language ?? this.language,
      country: country ?? this.country,
      healthConditions: healthConditions ?? this.healthConditions,
      allergies: allergies ?? this.allergies,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      doctorInfo: doctorInfo ?? this.doctorInfo,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      timezone: timezone ?? this.timezone,
      timezoneAutoDetect: timezoneAutoDetect ?? this.timezoneAutoDetect,
      breakfastTime: breakfastTime ?? this.breakfastTime,
      lunchTime: lunchTime ?? this.lunchTime,
      dinnerTime: dinnerTime ?? this.dinnerTime,
      sleepTime: sleepTime ?? this.sleepTime,
      wakeTime: wakeTime ?? this.wakeTime,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      reminderStyle: reminderStyle ?? this.reminderStyle,
      flexibilityWindow: flexibilityWindow ?? this.flexibilityWindow,
      caregivers: caregivers ?? this.caregivers,
      caregiverSettings: caregiverSettings ?? this.caregiverSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
