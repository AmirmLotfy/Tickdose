import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:tickdose/core/services/storage_service.dart';
import '../../auth/widgets/auth_button.dart';


class VoiceMessageScreen extends ConsumerStatefulWidget {
  final String reminderId;
  final String medicineName;

  const VoiceMessageScreen({
    super.key,
    required this.reminderId,
    required this.medicineName,
  });

  @override
  ConsumerState<VoiceMessageScreen> createState() => _VoiceMessageScreenState();
}

class _VoiceMessageScreenState extends ConsumerState<VoiceMessageScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedFilePath;
  Duration _recordedDuration = Duration.zero;
  Duration _recordingDuration = Duration.zero;

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
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

        // Update duration while recording
        _updateRecordingDuration();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.microphonePermissionRequired)),
          );
        }
      }
    } catch (e) {
      Logger.error('Error starting recording: $e', tag: 'VoiceMessage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.recordingError(e))),
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
          _recordedDuration = _recordingDuration;
        });
      }
    } catch (e) {
      Logger.error('Error stopping recording: $e', tag: 'VoiceMessage');
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
    return '${directory.path}/voice_message_$timestamp.m4a';
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
      Logger.error('Error playing recording: $e', tag: 'VoiceMessage');
      setState(() => _isPlaying = false);
    }
  }

  Future<void> _saveVoiceMessage() async {
    if (_recordedFilePath == null) return;

    try {
      final file = File(_recordedFilePath!);
      final bytes = await file.readAsBytes();

      // Upload to Firebase Storage
      final storageService = StorageService();
      final downloadUrl = await storageService.uploadVoiceMessage(
        reminderId: widget.reminderId,
        audioBytes: bytes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.voiceMessageSaved),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.pop(context, downloadUrl);
      }
    } catch (e) {
      Logger.error('Error saving voice message: $e', tag: 'VoiceMessage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorLabel(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDuration = _isRecording ? _recordingDuration : _recordedDuration;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.recordVoiceMessageTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            AppLocalizations.of(context)!.voiceMessageFor(widget.medicineName),
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.recordVoiceMessageDescription,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

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
                  label: Text(AppLocalizations.of(context)!.startRecordingButton),
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
                  label: Text(AppLocalizations.of(context)!.stopRecordingButton),
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
                      _recordedDuration = Duration.zero;
                    });
                  },
                  color: AppColors.textSecondary(context),
                ),
              ],
            ],
          ),
          const SizedBox(height: 48),

          // Save button
          if (_recordedFilePath != null && !_isRecording)
            AuthButton(
              text: AppLocalizations.of(context)!.saveVoiceMessageButton,
              onPressed: _saveVoiceMessage,
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
