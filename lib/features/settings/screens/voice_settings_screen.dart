import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/voice_settings_provider.dart';
import '../../../core/services/elevenlabs_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/utils/logger.dart';
import '../../../l10n/generated/app_localizations.dart';

enum VoiceMode { strict, gentle }

/// Voice Settings Screen
/// Configure voice preferences for reminders and responses
class VoiceSettingsScreen extends ConsumerStatefulWidget {
  const VoiceSettingsScreen({super.key});

  @override
  ConsumerState<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends ConsumerState<VoiceSettingsScreen> {
  bool _isTesting = false;
  
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(voiceSettingsProvider);
    final notifier = ref.read(voiceSettingsProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Settings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(AppIcons.restore()),
            onPressed: () async {
              await notifier.refreshVoices();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voices refreshed')),
                );
              }
            },
            tooltip: 'Refresh Voices',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Model Selection (NEW!)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Voice Model',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ElevenLabsModel>(
                    initialValue: ElevenLabsModel.values.firstWhere(
                      (m) => m.id == settings.selectedModel,
                      orElse: () => ElevenLabsModel.flash,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Select Model',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(AppIcons.statsChart()),
                      helperText: 'Choose based on your needs',
                    ),
                    items: ElevenLabsModel.values.map((model) {
                      return DropdownMenuItem(
                        value: model,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              model.displayName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              model.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (model) {
                      if (model != null) notifier.updateModel(model.id);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Voice Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Voice Selection',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: settings.selectedVoiceId.isEmpty ? null : settings.selectedVoiceId,
                    decoration: InputDecoration(
                      labelText: 'Select Voice',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(AppIcons.mic()),
                    ),
                    items: settings.availableVoices.map((voice) {
                      // Show voice name with gender and accent info if available
                      final List<String> info = [];
                      if (voice.gender != 'unknown') {
                        info.add(voice.gender.toUpperCase());
                      }
                      if (voice.accent != 'unknown') {
                        info.add(voice.accent);
                      }
                      if (info.isNotEmpty) {
                        // displayText = '${voice.name} (${info.join(', ')})';
                      }
                      return DropdownMenuItem(
                        value: voice.id,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(voice.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                            if (info.isNotEmpty)
                              Text(
                                info.join(' • '),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final voice = settings.availableVoices.firstWhere((v) => v.id == value);
                        notifier.updateVoice(value, voice.name);
                      }
                    },
                  ),
                  if (settings.selectedVoiceName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Currently using: ${settings.selectedVoiceName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Voice Controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Voice Controls',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Speed Control
                  _buildSliderSetting(
                    label: 'Speed',
                    value: settings.speed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    subtitle: '${settings.speed.toStringAsFixed(1)}x',
                    icon: AppIcons.speed(),
                    onChanged: (value) => notifier.updateSpeed(value),
                  ),
                  
                  const Divider(),
                  
                  // Volume Control
                  _buildSliderSetting(
                    label: 'Volume',
                    value: settings.volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    subtitle: '${(settings.volume * 100).toInt()}%',
                    icon: AppIcons.volume(),
                    onChanged: (value) => notifier.updateVolume(value),
                  ),
                  
                  const Divider(),
                  
                  // Clarity Control (NEW!)
                  _buildSliderSetting(
                    label: 'Clarity',
                    value: settings.clarity,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    subtitle: '${(settings.clarity * 100).toInt()}%',
                    icon: AppIcons.mic(),
                    onChanged: (value) => notifier.updateClarity(value),
                    helpText: 'Higher = clearer voice',
                  ),
                  
                  const Divider(),
                  
                  // Emotional Intensity Control (NEW!)
                  _buildSliderSetting(
                    label: 'Emotional Intensity',
                    value: settings.styleExaggeration,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    subtitle: '${(settings.styleExaggeration * 100).toInt()}%',
                    icon: AppIcons.sentiment(),
                    onChanged: (value) => notifier.updateStyleExaggeration(value),
                    helpText: 'Higher = more expressive',
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Language Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Language',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: settings.language,
                    decoration: InputDecoration(
                      labelText: 'Voice Language',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(AppIcons.language()),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'en-US', child: Text('English (US)')),
                      DropdownMenuItem(value: 'en-GB', child: Text('English (UK)')),
                      DropdownMenuItem(value: 'ar-SA', child: Text('العربية (Arabic)')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        notifier.updateLanguage(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Features Toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Voice Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Voice Reminders'),
                    subtitle: const Text('Use AI voice instead of sound effects'),
                    value: settings.useVoiceReminders,
                    onChanged: (value) => notifier.toggleVoiceReminders(value),
                    secondary: Icon(AppIcons.notifications(filled: true)),
                  ),
                  SwitchListTile(
                    title: const Text('Voice Congratulations'),
                    subtitle: const Text('Celebrate streaks with voice messages'),
                    value: settings.useVoiceCongratulations,
                    onChanged: (value) => notifier.toggleVoiceCongratulations(value),
                    secondary: Icon(AppIcons.celebration()),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Speaker Boost'),
                    subtitle: const Text('Enhanced voice presence'),
                    value: settings.speakerBoost,
                    onChanged: (value) => notifier.toggleSpeakerBoost(value),
                    secondary: Icon(AppIcons.sound()),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Streaming Mode'),
                    subtitle: const Text('Real-time playback (faster)'),
                    value: settings.useStreaming,
                    onChanged: (value) => notifier.toggleStreaming(value),
                    secondary: Icon(AppIcons.flash()),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Voice Confirmations'),
                    subtitle: const Text('Enable voice-based yes/no confirmations'),
                    value: settings.useVoiceConfirmations ?? true,
                    onChanged: (value) => notifier.toggleVoiceConfirmations(value),
                    secondary: Icon(AppIcons.mic()),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Voice Mode Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Voice Mode',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose the tone for your reminders',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<VoiceMode>(
                    segments: const [
                      ButtonSegment(
                        value: VoiceMode.strict,
                        label: Text('Strict'),
                        tooltip: 'Urgent, alert tone',
                      ),
                      ButtonSegment(
                        value: VoiceMode.gentle,
                        label: Text('Gentle'),
                        tooltip: 'Soft, friendly tone',
                      ),
                    ],
                    selected: {settings.voiceMode == 'strict' ? VoiceMode.strict : VoiceMode.gentle},
                    onSelectionChanged: (Set<VoiceMode> selection) {
                      if (selection.isNotEmpty) {
                        notifier.updateVoiceMode(selection.first.name);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Test Voice Button
          ElevatedButton.icon(
            onPressed: _isTesting ? null : _testVoice,
            icon: _isTesting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(AppIcons.play()),
            label: Text(_isTesting ? 'Testing...' : 'Test Voice'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Reset Button
          OutlinedButton.icon(
            onPressed: () => _showResetDialog(),
            icon: Icon(AppIcons.restore()),
            label: const Text('Reset to Defaults'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build slider setting widget
  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String subtitle,
    required IconData icon,
    required ValueChanged<double> onChanged,
    String? helpText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (helpText != null)
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 4),
            child: Text(
              helpText,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: subtitle,
          onChanged: onChanged,
        ),
      ],
    );
  }
  
  /// Test voice with current settings
  Future<void> _testVoice() async {
    setState(() => _isTesting = true);
    
    try {
      final settings = ref.read(voiceSettingsProvider);
      final elevenLabs = ElevenLabsService();
      
      await elevenLabs.initialize();
      
      final testMessage = 'This is a test of your voice settings for TICKDOSE. '
                          'Your current speed is ${settings.speed.toStringAsFixed(1)}x '
                          'and volume is at ${(settings.volume * 100).toInt()} percent.';
      
      final audioPath = await elevenLabs.textToSpeech(
        text: testMessage,
        voiceId: settings.selectedVoiceId,
      );
      
      await elevenLabs.playAudio(
        audioPath: audioPath,
        volume: settings.volume,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Playing test voice...')),
        );
      }
    } catch (e) {
      Logger.error('Voice test error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorWithMessage(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    }
  }
  
  /// Show reset confirmation dialog
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.resetSettingsTitle),
        content: Text(AppLocalizations.of(context)!.resetSettingsConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(voiceSettingsProvider.notifier).resetToDefaults();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.settingsResetToDefaults)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: AppColors.lightBackground,
            ),
            child: Text(AppLocalizations.of(context)!.resetButton),
          ),
        ],
      ),
    );
  }
}
