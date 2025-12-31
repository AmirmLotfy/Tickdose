// ignore_for_file: non_constant_identifier_names
enum ReminderFrequency {
  onceDaily,
  twiceDaily,
  threeTimes,
  fourTimes,
  every8Hours,
  every12Hours,
  withMeals,
  custom,
}

enum MealTime {
  breakfast,
  lunch,
  dinner,
  bedtime,
}

/// Meal timing for medication
enum MealTiming {
  beforeMeals,
  withMeals,  // Changed from 'with'
  afterMeals,
  notApplicable,
}

class ReminderModel {
  final String id;
  final String medicineId;
  final String medicineName;
  
  // New enhanced fields
  final ReminderFrequency frequency;
  final List<String> times; // HH:mm format times
  final String? imageUrl; // URL or local path to medicine image
  
  // For meal-based reminders
  final Map<String, String>? mealTimes; // MealTime.name -> HH:mm
  final MealTiming? mealTiming;
  
  // For interval-based reminders
  final String? startTime; // HH:mm format
  final int? intervalHours;
  final bool includeOvernight;
  final bool enabled;  // NEW: For enable/disable toggle
  
  // Timezone awareness and flexibility
  final bool isTimezoneAware; // Default true
  final int minutesOffset; // Range -30 to +60 for flexibility window
  
  // Legacy fields (kept for compatibility)
  final String time; // Primary time (for backwards compatibility)
  final String dosage;
  final String frequency_legacy; // Old frequency field
  final List<int> daysOfWeek;
  final int notificationId;

  ReminderModel({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.frequency,
    required this.times,
    this.imageUrl,
    this.mealTimes,
    this.mealTiming,
    this.startTime,
    this.intervalHours,
    this.includeOvernight = false,
    this.enabled = true,
    this.isTimezoneAware = true,
    this.minutesOffset = 0,
    required this.time,
    required this.dosage,
    required this.frequency_legacy,
    required this.daysOfWeek,
    required this.notificationId,
  });

  factory ReminderModel.fromMap(Map<String, dynamic> map, String id) {
    return ReminderModel(
      id: id,
      medicineId: map['medicineId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      frequency: _parseFrequency(map['frequency']),
      times: List<String>.from(map['times'] ?? [map['time'] ?? '08:00']),
      imageUrl: map['imageUrl'],
      mealTimes: map['mealTimes'] != null 
          ? Map<String, String>.from(map['mealTimes'])
          : null,
      mealTiming: map['mealTiming'] != null
          ? MealTiming.values.firstWhere(
              (e) => e.toString() == 'MealTiming.${map['mealTiming']}',
              orElse: () => MealTiming.withMeals,
            )
          : MealTiming.notApplicable,
      startTime: map['startTime'],
      intervalHours: map['intervalHours'],
      includeOvernight: map['includeOvernight'] ?? false,
      enabled: map['enabled'] ?? true,  // NEW: Default to true if not present
      isTimezoneAware: map['isTimezoneAware'] ?? true,
      minutesOffset: map['minutesOffset'] ?? 0,
      time: map['time'] ?? '08:00',
      dosage: map['dosage'] ?? '1 tablet',
      frequency_legacy: map['frequency_legacy'] ?? map['frequency'] ?? 'daily',
      daysOfWeek: List<int>.from(map['daysOfWeek'] ?? [1, 2, 3, 4, 5, 6, 7]),
      notificationId: map['notificationId'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicineId,
      'medicineName': medicineName,
      'frequency': frequency.name,
      'times': times,
      'imageUrl': imageUrl,
      'mealTimes': mealTimes,
      'mealTiming': mealTiming?.name,
      'startTime': startTime,
      'intervalHours': intervalHours,
      'includeOvernight': includeOvernight,
      'enabled': enabled,  // NEW
      'isTimezoneAware': isTimezoneAware,
      'minutesOffset': minutesOffset,
      'time': time,
      'dosage': dosage,
      'frequency_legacy': frequency_legacy,
      'daysOfWeek': daysOfWeek,
      'notificationId': notificationId,
    };
  }

  static ReminderFrequency _parseFrequency(dynamic freq) {
    if (freq == null) return ReminderFrequency.onceDaily;
    
    if (freq is ReminderFrequency) return freq;
    
    final String freqStr = freq.toString().toLowerCase();
    
    if (freqStr.contains('twice')) return ReminderFrequency.twiceDaily;
    if (freqStr.contains('three') || freqStr.contains('3')) return ReminderFrequency.threeTimes;
    if (freqStr.contains('four') || freqStr.contains('4')) return ReminderFrequency.fourTimes;
    if (freqStr.contains('8')) return ReminderFrequency.every8Hours;
    if (freqStr.contains('12')) return ReminderFrequency.every12Hours;
    if (freqStr.contains('meal')) return ReminderFrequency.withMeals;
    
    return ReminderFrequency.onceDaily;
  }

  ReminderModel copyWith({
    String? id,
    String? medicineId,
    String? medicineName,
    ReminderFrequency? frequency,
    List<String>? times,
    String? imageUrl,
    Map<String, String>? mealTimes,
    MealTiming? mealTiming,
    String? startTime,
    int? intervalHours,
    bool? includeOvernight,
    String? time,
    String? dosage,
    String? frequency_legacy,
    List<int>? daysOfWeek,
    int? notificationId,
    bool? enabled,
    bool? isTimezoneAware,
    int? minutesOffset,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      imageUrl: imageUrl ?? this.imageUrl,
      mealTimes: mealTimes ?? this.mealTimes,
      mealTiming: mealTiming ?? this.mealTiming,
      startTime: startTime ?? this.startTime,
      intervalHours: intervalHours ?? this.intervalHours,
      includeOvernight: includeOvernight ?? this.includeOvernight,
      enabled: enabled ?? this.enabled,  // NEW
      isTimezoneAware: isTimezoneAware ?? this.isTimezoneAware,
      minutesOffset: minutesOffset ?? this.minutesOffset,
      time: time ?? this.time,
      dosage: dosage ?? this.dosage,
      frequency_legacy: frequency_legacy ?? this.frequency_legacy,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      notificationId: notificationId ?? this.notificationId,
    );
  }
}
