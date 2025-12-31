# TICKDOSE Sound Effects Placeholders

This directory contains placeholder files for sound effects used throughout the app.

## Sound Files Needed:

### User Actions (0.5-1s duration, pleasant tones)
- **medication_taken.mp3** - Positive confirmation sound when user marks medication as taken
- **medication_skipped.mp3** - Neutral sound when user skips a dose
- **medication_missed.mp3** - Gentle alert sound for missed medications
- **success.mp3** - General success/confirmation sound
- **error.mp3** - Subtle error sound (not harsh)
- **tap.mp3** - Light tap/click sound for button presses

### Notifications (2-3s duration, attention-grabbing but pleasant)
- **reminder_alert.mp3** - Standard medication reminder sound
- **urgent_reminder.mp3** - More prominent sound for overdue medications

### Achievements (1-2s duration, celebratory)
- **achievement.mp3** - Sound for streak milestones
- **celebration.mp3** - Sound for perfect week/month completion

### UI Sounds (0.2-0.5s duration, subtle)
- **swipe.mp3** - Swipe gesture sound
- **toggle.mp3** - Toggle switch sound

## Usage in App:

```dart
// Example usage:
await AudioService().playSound(SoundEffect.medicationTaken);
```

## Recommendations:

1. **File Format**: MP3 (widely supported, good compression)
2. **Sample Rate**: 44.1kHz
3. **Bit Rate**: 128-192 kbps
4. **Volume**: Normalize all files to similar levels
5. **Tone**: Pleasant, non-intrusive sounds
6. **Health Context**: Avoid harsh or stressful sounds

## Where to Find Sounds:

- [Freesound.org](https://freesound.org/)
- [Zapsplat.com](https://www.zapsplat.com/)
- [Mixkit.co](https://mixkit.co/free-sound-effects/)

## Replacement Instructions:

1. Download or create your MP3 files
2. Name them exactly as listed above
3. Place them in this directory (`assets/sounds/`)
4. Run `flutter pub get` to ensure assets are recognized
5. Test in the app

---

**IMPORTANT**: These placeholder files are empty. Replace them with actual audio files before production release.
