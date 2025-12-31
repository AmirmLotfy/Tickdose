
import 'package:tickdose/core/utils/logger.dart';
import 'package:audioplayers/audioplayers.dart';

enum SoundEffect {
  // User Actions
  medicationTaken,
  medicationSkipped,
  medicationMissed,
  success,
  error,
  tap,
  
  // Notifications
  reminderAlert,
  urgentReminder,
  
  // Achievements
  streakMilestone,
  perfectWeek,
  
  // General
  swipe,
  toggle,
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;
  double _volume = 0.7;

  // Sound file paths
  final Map<SoundEffect, String> _soundPaths = {
    SoundEffect.medicationTaken: 'assets/sounds/medication_taken.mp3',
    SoundEffect.medicationSkipped: 'assets/sounds/medication_skipped.mp3',
    SoundEffect.medicationMissed: 'assets/sounds/medication_missed.mp3',
    SoundEffect.success: 'assets/sounds/success.mp3',
    SoundEffect.error: 'assets/sounds/error.mp3',
    SoundEffect.tap: 'assets/sounds/tap.mp3',
    SoundEffect.reminderAlert: 'assets/sounds/reminder_alert.mp3',
    SoundEffect.urgentReminder: 'assets/sounds/urgent_reminder.mp3',
    SoundEffect.streakMilestone: 'assets/sounds/achievement.mp3',
    SoundEffect.perfectWeek: 'assets/sounds/celebration.mp3',
    SoundEffect.swipe: 'assets/sounds/swipe.mp3',
    SoundEffect.toggle: 'assets/sounds/toggle.mp3',
  };

  // Initialize audio service
  Future<void> initialize() async {
    try {
      await _player.setVolume(_volume);
      Logger.info('Audio service initialized', tag: 'Audio');
    } catch (e) {
      Logger.error('Failed to initialize audio service', tag: 'Audio', error: e);
    }
  }

  // Play sound effect
  Future<void> playSound(SoundEffect sound) async {
    if (!_soundEnabled) return;

    try {
      final path = _soundPaths[sound];
      if (path == null) {
        Logger.warning('Sound path not found for: $sound', tag: 'Audio');
        return;
      }

      await _player.play(AssetSource(path.replaceFirst('assets/', '')));
      Logger.debug('Playing sound: $sound', tag: 'Audio');
    } catch (e) {
      Logger.error('Failed to play sound: $sound', tag: 'Audio', error: e);
    }
  }

  // Play with custom volume
  Future<void> playSoundWithVolume(SoundEffect sound, double volume) async {
    if (!_soundEnabled) return;

    try {
      final path = _soundPaths[sound];
      if (path == null) return;

      await _player.setVolume(volume);
      await _player.play(AssetSource(path.replaceFirst('assets/', '')));
      await _player.setVolume(_volume); // Reset to default
    } catch (e) {
      Logger.error('Failed to play sound with volume', tag: 'Audio', error: e);
    }
  }

  // Enable/disable sounds
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    Logger.info('Sound ${enabled ? 'enabled' : 'disabled'}', tag: 'Audio');
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
    Logger.info('Volume set to: $_volume', tag: 'Audio');
  }

  // Stop currently playing sound
  Future<void> stop() async {
    await _player.stop();
  }

  // Dispose
  Future<void> dispose() async {
    await _player.dispose();
  }

  // Getters
  bool get isSoundEnabled => _soundEnabled;
  double get volume => _volume;
}
