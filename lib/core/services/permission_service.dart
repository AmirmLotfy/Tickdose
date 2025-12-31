import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> requestExactAlarmPermission() async {
    // Android 12+ requires this for exact alarms
    if (await Permission.scheduleExactAlarm.isDenied) {
      final status = await Permission.scheduleExactAlarm.request();
      return status.isGranted;
    }
    return true;
  }

  /// Requests both notification and exact alarm permissions
  Future<bool> requestReminderPermissions() async {
    final notificationStatus = await requestNotificationPermission();
    final alarmStatus = await requestExactAlarmPermission();
    return notificationStatus && alarmStatus;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> requestSpeechPermission() async {
    final status = await Permission.speech.request();
    return status.isGranted;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
