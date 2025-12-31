import 'package:package_info_plus/package_info_plus.dart';
import 'package:tickdose/core/utils/logger.dart';

/// Service for checking app updates and version information
class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._internal();
  factory AppUpdateService() => _instance;
  AppUpdateService._internal();

  PackageInfo? _packageInfo;
  DateTime? _lastCheckTime;
  static const Duration _checkInterval = Duration(hours: 24);

  /// Initialize and get package info
  Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      Logger.info('App version: ${_packageInfo?.version}', tag: 'AppUpdate');
    } catch (e) {
      Logger.error('Failed to get package info: $e', tag: 'AppUpdate', error: e);
    }
  }

  /// Get current app version
  String getCurrentVersion() {
    return _packageInfo?.version ?? '1.0.0';
  }

  /// Get current build number
  String getCurrentBuildNumber() {
    return _packageInfo?.buildNumber ?? '1';
  }

  /// Check if update check is needed (not checked in last 24 hours)
  bool shouldCheckForUpdate() {
    if (_lastCheckTime == null) {
      return true;
    }
    return DateTime.now().difference(_lastCheckTime!) > _checkInterval;
  }

  /// Check for app updates
  /// Returns update info if update is available, null otherwise
  Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      if (!shouldCheckForUpdate()) {
        Logger.info('Update check skipped (checked recently)', tag: 'AppUpdate');
        return null;
      }

      _lastCheckTime = DateTime.now();

      // For Android: Check Play Store API
      // For iOS: Check App Store API
      // This is a simplified version - in production, use proper APIs

      final currentVersion = getCurrentVersion();
      Logger.info('Checking for updates. Current version: $currentVersion', tag: 'AppUpdate');

      // Placeholder: In production, you'd call:
      // - Google Play API for Android
      // - App Store API for iOS
      // - Or use a custom version endpoint

      // For now, return null (no update available)
      // In production, implement actual version checking
      return null;
    } catch (e) {
      Logger.error('Failed to check for updates: $e', tag: 'AppUpdate', error: e);
      return null;
    }
  }

  /// Get package info
  PackageInfo? get packageInfo => _packageInfo;
}

/// App update information
class AppUpdateInfo {
  final String latestVersion;
  final bool isUpdateAvailable;
  final bool isCriticalUpdate;
  final String? releaseNotes;
  final String? updateUrl;

  AppUpdateInfo({
    required this.latestVersion,
    required this.isUpdateAvailable,
    this.isCriticalUpdate = false,
    this.releaseNotes,
    this.updateUrl,
  });

  /// Compare versions and determine if update is needed
  static bool isVersionNewer(String currentVersion, String latestVersion) {
    final currentParts = currentVersion.split('.').map(int.parse).toList();
    final latestParts = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final current = i < currentParts.length ? currentParts[i] : 0;
      final latest = i < latestParts.length ? latestParts[i] : 0;

      if (latest > current) {
        return true;
      } else if (latest < current) {
        return false;
      }
    }

    return false;
  }
}
