import 'dart:async';
import 'package:tickdose/core/utils/logger.dart';
import 'package:health/health.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for managing wearable device integration
/// Supports Wear OS (Android) and watchOS (iOS) features
class WearableService {
  static final WearableService _instance = WearableService._internal();
  factory WearableService() => _instance;
  WearableService._internal();

  Health? _health;
  bool _isInitialized = false;
  final StreamController<WearableReminder> _reminderController = StreamController<WearableReminder>.broadcast();
  final StreamController<HealthData> _healthDataController = StreamController<HealthData>.broadcast();

  Stream<WearableReminder> get reminderStream => _reminderController.stream;
  Stream<HealthData> get healthDataStream => _healthDataController.stream;

  /// Initialize wearable service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _health = Health();
      
      // Request permissions for health data
      final types = [
        HealthDataType.HEART_RATE,
        HealthDataType.SLEEP_IN_BED,
        HealthDataType.STEPS,
        HealthDataType.WEIGHT,
      ];

      final hasPermissions = await _health!.requestAuthorization(types);
      
      if (hasPermissions) {
        _isInitialized = true;
        Logger.info('Wearable service initialized successfully', tag: 'Wearable');
        
        // Start listening to health data
        _startHealthDataListener();
        return true;
      } else {
        Logger.warn('Wearable service: Health permissions denied', tag: 'Wearable');
        return false;
      }
    } catch (e) {
      Logger.error('Error initializing wearable service: $e', tag: 'Wearable');
      return false;
    }
  }

  /// Start listening to health data from wearable devices
  void _startHealthDataListener() {
    // Check for new health data periodically
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _fetchHealthData();
    });
  }

  /// Fetch latest health data from wearable
  Future<void> _fetchHealthData() async {
    if (_health == null || !_isInitialized) return;

    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      // Fetch heart rate
      final heartRateData = await _health!.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: yesterday,
        endTime: now,
      );

      // Fetch sleep data
      final sleepData = await _health!.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_IN_BED],
        startTime: yesterday,
        endTime: now,
      );

      // Process and emit health data
      for (final data in heartRateData) {
        _healthDataController.add(HealthData(
          type: HealthDataType.HEART_RATE,
          value: (data.value as NumericHealthValue).numericValue.toDouble(),
          unit: data.unit.toString(),
          dateFrom: data.dateFrom,
          dateTo: data.dateTo,
        ));
      }

      for (final data in sleepData) {
        _healthDataController.add(HealthData(
          type: HealthDataType.SLEEP_IN_BED,
          value: (data.value as NumericHealthValue).numericValue.toDouble(),
          unit: data.unit.toString(),
          dateFrom: data.dateFrom,
          dateTo: data.dateTo,
        ));
      }
    } catch (e) {
      Logger.error('Error fetching health data: $e', tag: 'Wearable');
    }
  }

  /// Send reminder to wearable device
  Future<bool> sendReminderToWearable({
    required String reminderId,
    required String medicineName,
    required String dosage,
    required DateTime scheduledTime,
    String? mealTime,
  }) async {
    try {
      // For now, we'll store reminders in Firestore
      // In a full implementation, this would use platform channels to communicate with Wear OS/watchOS
      final user = await _getCurrentUserId();
      if (user == null) return false;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user)
          .collection('wearable_reminders')
          .doc(reminderId)
          .set({
        'reminderId': reminderId,
        'medicineName': medicineName,
        'dosage': dosage,
        'scheduledTime': Timestamp.fromDate(scheduledTime),
        'mealTime': mealTime,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Emit reminder event
      _reminderController.add(WearableReminder(
        reminderId: reminderId,
        medicineName: medicineName,
        dosage: dosage,
        scheduledTime: scheduledTime,
        mealTime: mealTime,
      ));

      Logger.info('Reminder sent to wearable: $medicineName', tag: 'Wearable');
      return true;
    } catch (e) {
      Logger.error('Error sending reminder to wearable: $e', tag: 'Wearable');
      return false;
    }
  }

  /// Handle quick action from wearable (take/skip medicine)
  Future<bool> handleWearableAction({
    required String reminderId,
    required WearableAction action,
    DateTime? timestamp,
  }) async {
    try {
      final user = await _getCurrentUserId();
      if (user == null) return false;

      // Update reminder status
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user)
          .collection('wearable_reminders')
          .doc(reminderId)
          .update({
        'status': action == WearableAction.taken ? 'taken' : 'skipped',
        'actionTimestamp': FieldValue.serverTimestamp(),
        'actionSource': 'wearable',
      });

      // Create medicine log entry
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user)
          .collection('logs')
          .add({
        'medicineId': reminderId.split('_')[0], // Extract medicine ID from reminder ID
        'medicineName': '', // Will be filled from reminder
        'status': action == WearableAction.taken ? 'taken' : 'skipped',
        'takenAt': timestamp != null ? Timestamp.fromDate(timestamp) : FieldValue.serverTimestamp(),
        'source': 'wearable',
      });

      Logger.info('Wearable action recorded: $action for reminder $reminderId', tag: 'Wearable');
      return true;
    } catch (e) {
      Logger.error('Error handling wearable action: $e', tag: 'Wearable');
      return false;
    }
  }

  /// Get heart rate data for a specific time range
  Future<List<HealthDataPoint>> getHeartRateData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_health == null || !_isInitialized) return [];

    try {
      return await _health!.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: startDate,
        endTime: endDate,
      );
    } catch (e) {
      Logger.error('Error fetching heart rate data: $e', tag: 'Wearable');
      return [];
    }
  }

  /// Get sleep data for a specific time range
  Future<List<HealthDataPoint>> getSleepData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_health == null || !_isInitialized) return [];

    try {
      return await _health!.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_IN_BED],
        startTime: startDate,
        endTime: endDate,
      );
    } catch (e) {
      Logger.error('Error fetching sleep data: $e', tag: 'Wearable');
      return [];
    }
  }

  /// Check if wearable is connected
  Future<bool> isWearableConnected() async {
    // In a full implementation, this would check actual device connection
    // For now, we check if health data is available
    if (_health == null || !_isInitialized) return false;
    
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final data = await _health!.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: yesterday,
        endTime: now,
      );
      return data.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<String?> _getCurrentUserId() async {
    // This should be injected or accessed via a provider
    // For now, using a simple approach
    try {
      final auth = FirebaseAuth.instance;
      return auth.currentUser?.uid;
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _reminderController.close();
    _healthDataController.close();
  }
}

/// Wearable reminder model
class WearableReminder {
  final String reminderId;
  final String medicineName;
  final String dosage;
  final DateTime scheduledTime;
  final String? mealTime;

  WearableReminder({
    required this.reminderId,
    required this.medicineName,
    required this.dosage,
    required this.scheduledTime,
    this.mealTime,
  });
}

/// Wearable action types
enum WearableAction {
  taken,
  skipped,
}

/// Health data model
class HealthData {
  final HealthDataType type;
  final double value;
  final String unit;
  final DateTime dateFrom;
  final DateTime dateTo;

  HealthData({
    required this.type,
    required this.value,
    required this.unit,
    required this.dateFrom,
    required this.dateTo,
  });
}
