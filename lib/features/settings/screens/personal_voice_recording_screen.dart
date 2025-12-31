import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tickdose/core/services/personal_voice_service.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import '../../auth/widgets/auth_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/widgets/permission_dialog.dart';
import '../../../core/services/permission_service.dart';

class PersonalVoiceRecordingScreen extends ConsumerStatefulWidget {
  const PersonalVoiceRecordingScreen({super.key});

  @override
  ConsumerState<PersonalVoiceRecordingScreen> createState() => _PersonalVoiceRecordingScreenState();
}

class _PersonalVoiceRecordingScreenState extends ConsumerState<PersonalVoiceRecordingScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final PersonalVoiceService _voiceService = PersonalVoiceService();
  
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedFilePath;
  Duration _recordingDuration = Duration.zero;
  String? _voiceName;
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      // Check permission first
      final permissionService = PermissionService();
      final hasPermission = await permissionService.requestMicrophonePermission();
      
      if (!hasPermission) {
        if (mounted) {
          await PermissionDialog.showMicrophonePermission(
            context,
            onGrant: () async {
              final granted = await permissionService.requestMicrophonePermission();
              if (granted && mounted) {
                await _startRecording();
              }
            },
            onDeny: () {},
          );
        }
        return;
      }
      
      // Double check with recorder's permission check
      if (await _recorder.hasPermission()) {
        final path = await _getRecordingPath();
        await _recorder.start(
          const RecordConfig(),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordingDuration = Duration.zero;
        });

        _updateRecordingDuration();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.microphonePermissionRequired)),
          );
        }
      }
    } catch (e) {
      Logger.error('Error starting recording: $e', tag: 'PersonalVoice');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorWithMessage(e.toString()))),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      if (path != null) {
        setState(() {
          _isRecording = false;
          _recordedFilePath = path;
        });
      }
    } catch (e) {
      Logger.error('Error stopping recording: $e', tag: 'PersonalVoice');
    }
  }

  void _updateRecordingDuration() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && mounted) {
        setState(() {
          _recordingDuration = _recordingDuration + const Duration(seconds: 1);
        });
        _updateRecordingDuration();
      }
    });
  }

  Future<String> _getRecordingPath() async {
    final directory = Directory.systemTemp;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${directory.path}/personal_voice_$timestamp.m4a';
  }

  Future<void> _playRecording() async {
    if (_recordedFilePath == null) return;

    try {
      setState(() => _isPlaying = true);
      await _player.setFilePath(_recordedFilePath!);
      await _player.play();
      
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() => _isPlaying = false);
        }
      });
    } catch (e) {
      Logger.error('Error playing recording: $e', tag: 'PersonalVoice');
      setState(() => _isPlaying = false);
    }
  }

  Future<void> _savePersonalVoice() async {
    if (_recordedFilePath == null || _voiceName == null || _voiceName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a name for your voice')),
      );
      return;
    }

    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in')),
        );
        return;
      }

      final file = File(_recordedFilePath!);
      final downloadUrl = await _voiceService.recordPersonalVoice(
        audioFile: file,
        userId: user.uid,
        name: _voiceName!,
      );

      await _voiceService.setPersonalVoiceAsDefault(
        userId: user.uid,
        voiceUrl: downloadUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal voice saved and set as default!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      Logger.error('Error saving personal voice: $e', tag: 'PersonalVoice');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorWithMessage(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDuration = _recordingDuration;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Personal Voice'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Record Personal Voice',
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Record a family member\'s voice (15-30 seconds) to use for medication reminders',
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Voice name input
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Voice Name',
              hintText: 'e.g., Mom\'s voice, Dad\'s voice',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => _voiceName = value);
            },
          ),
          const SizedBox(height: 32),

          // Recording indicator
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording 
                    ? AppColors.errorRed.withValues(alpha: 0.2)
                    : AppColors.primaryBlue.withValues(alpha: 0.1),
              ),
              child: Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                size: 80,
                color: _isRecording ? AppColors.errorRed : AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Duration display
          Text(
            _formatDuration(currentDuration),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Recording controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isRecording && _recordedFilePath == null)
                ElevatedButton.icon(
                  onPressed: _startRecording,
                  icon: const Icon(Icons.mic),
                  label: const Text('Start Recording'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                )
              else if (_isRecording)
                ElevatedButton.icon(
                  onPressed: _stopRecording,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Recording'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                )
              else ...[
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 48,
                  onPressed: _isPlaying ? null : _playRecording,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.replay),
                  iconSize: 32,
                  onPressed: () {
                    setState(() {
                      _recordedFilePath = null;
                      _recordingDuration = Duration.zero;
                    });
                  },
                  color: AppColors.textSecondary(context),
                ),
              ],
            ],
          ),
          const SizedBox(height: 48),

          // Save button
          if (_recordedFilePath != null && !_isRecording && _voiceName != null && _voiceName!.isNotEmpty)
            AuthButton(
              text: 'Save Personal Voice',
              onPressed: _savePersonalVoice,
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
