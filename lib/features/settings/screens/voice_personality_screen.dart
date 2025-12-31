import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/services/elevenlabs_service.dart';
import 'package:tickdose/core/providers/voice_settings_provider.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import '../../auth/widgets/auth_button.dart';

class VoicePersonalityScreen extends ConsumerStatefulWidget {
  const VoicePersonalityScreen({super.key});

  @override
  ConsumerState<VoicePersonalityScreen> createState() => _VoicePersonalityScreenState();
}

class _VoicePersonalityScreenState extends ConsumerState<VoicePersonalityScreen> {
  String? _selectedPersonality;
  bool _isPlaying = false;
  bool _emotionalIntelligence = true;

  final Map<String, Map<String, dynamic>> _personalities = {
    'strict': {
      'name': 'Strict',
      'description': 'Urgent, alert tone for important reminders',
      'icon': Icons.warning,
      'color': AppColors.errorRed,
    },
    'gentle': {
      'name': 'Gentle',
      'description': 'Soft, friendly tone for everyday reminders',
      'icon': Icons.favorite,
      'color': AppColors.primaryBlue,
    },
    'encouraging': {
      'name': 'Encouraging',
      'description': 'Motivational and supportive tone',
      'icon': Icons.celebration,
      'color': AppColors.successGreen,
    },
    'familiar': {
      'name': 'Familiar',
      'description': 'Use your recorded personal voice',
      'icon': Icons.person,
      'color': AppColors.primaryTeal,
    },
  };

  @override
  void initState() {
    super.initState();
    // Defer reading provider until after build or use listen manually if needed, 
    // but reading in initState via ref.read is effectively safe for initial value if provider is ready.
    // Better practice: use didChangeDependencies or just read in build?
    // We want to set local state once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(voiceSettingsProvider);
      setState(() {
        _selectedPersonality = settings.voiceStylePreference;
        _emotionalIntelligence = settings.styleExaggeration > 0;
      });
    });
  }

  Future<void> _saveSettings() async {
    if (_selectedPersonality == null) return;
    
    final notifier = ref.read(voiceSettingsProvider.notifier);
    
    // Save personality
    await notifier.updateVoiceStyle(_selectedPersonality!);
    
    // Map personality to basic mode strictly for legacy support if needed
    if (_selectedPersonality == 'strict') {
      await notifier.updateVoiceMode('strict');
    } else {
      await notifier.updateVoiceMode('gentle');
    }

    // Save emotional intelligence
    await notifier.updateStyleExaggeration(_emotionalIntelligence ? 0.45 : 0.0);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice personality saved')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Personality'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Choose Voice Personality',
            style: AppTextStyles.h2(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Select how you want your reminders to sound',
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Personality options
          ..._personalities.entries.map((entry) {
            final key = entry.key;
            final data = entry.value;
            final isSelected = _selectedPersonality == key;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: isSelected ? data['color'].withValues(alpha: 0.1) : null,
              child: InkWell(
                onTap: () {
                  setState(() => _selectedPersonality = key);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: data['color'].withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          data['icon'],
                          color: data['color'],
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['description'],
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: data['color'],
                        ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                        onPressed: () => _previewVoice(key, data['name']),
                        color: AppColors.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Emotional intelligence toggle
          Card(
            child: SwitchListTile(
              title: const Text('Emotional Intelligence'),
              subtitle: const Text('Adjust tone based on your responses and adherence patterns'),
              value: _emotionalIntelligence,
              onChanged: (value) {
                setState(() => _emotionalIntelligence = value);
              },
              activeThumbColor: AppColors.primaryBlue,
            ),
          ),

          const SizedBox(height: 24),

          // Save button
          AuthButton(
            text: 'Save Personality',
            onPressed: _selectedPersonality != null ? _saveSettings : null,
          ),
        ],
      ),
    );
  }

  Future<void> _previewVoice(String personality, String name) async {
    setState(() => _isPlaying = true);

    try {
      final voiceSettings = ref.read(voiceSettingsProvider);
      final elevenLabsService = ElevenLabsService();

      String message;

      switch (personality) {
        case 'strict':
          message = 'URGENT! It\'s time to take your medication. Please take it now.';
          break;
        case 'gentle':
          message = 'Hello! This is a gentle reminder to take your medication.';
          break;
        case 'encouraging':
          message = 'You\'re doing great! Keep up the good work by taking your medication now.';
          break;
        case 'familiar':
          message = 'Time to take your medicine. Remember to take care of yourself!';
          break;
        default:
          message = 'Time to take your medication.';
      }

      final audioPath = await elevenLabsService.textToSpeech(
        text: message,
        voiceId: voiceSettings.selectedVoiceId.isNotEmpty
            ? voiceSettings.selectedVoiceId
            : 'default',
        // Pass style exaggeration for preview if we want to simulate the selected setting
        // style: _emotionalIntelligence ? 0.45 : 0.0, 
      );

      await elevenLabsService.playAudio(audioPath: audioPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preview error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    }
  }
}
