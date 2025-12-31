import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/services/voice_confirmation_service.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/utils/logger.dart';

/// Screen that displays voice confirmation UI when a reminder is triggered
class VoiceConfirmationScreen extends ConsumerStatefulWidget {
  final String medicineName;
  final String dosage;
  final String voiceId;

  const VoiceConfirmationScreen({
    super.key,
    required this.medicineName,
    required this.dosage,
    required this.voiceId,
  });

  @override
  ConsumerState<VoiceConfirmationScreen> createState() => _VoiceConfirmationScreenState();
}

class _VoiceConfirmationScreenState extends ConsumerState<VoiceConfirmationScreen> {
  final VoiceConfirmationService _confirmationService = VoiceConfirmationService();
  ConfirmationResult? _result;
  bool _isListening = false;
  String _transcribedText = '';
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeAndStart();
  }

  Future<void> _initializeAndStart() async {
    try {
      // Initialize speech recognition
      await _confirmationService.initialize();

      // Listen to confirmation results
      _confirmationService.confirmationResults.listen((result) {
        if (mounted) {
          setState(() {
            _result = result;
            _isListening = false;
            _hasCompleted = true;
            if (result.recognizedText.isNotEmpty) {
              _transcribedText = result.recognizedText;
            }
          });

          // Auto-close after showing result
          if (result.isSuccess) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.pop(context, result);
              }
            });
          }
        }
      });

      // Start voice confirmation flow
      _startConfirmation();
    } catch (e) {
      Logger.error('Error initializing voice confirmation: $e', tag: 'VoiceConfirmationScreen');
      if (mounted) {
        setState(() {
          _result = ConfirmationResult.error(e.toString());
          _hasCompleted = true;
        });
      }
    }
  }

  Future<void> _startConfirmation() async {
    setState(() {
      _isListening = true;
      _transcribedText = '';
    });

    try {
      final result = await _confirmationService.playReminderAndWaitForConfirmation(
        medicineName: widget.medicineName,
        dosage: widget.dosage,
        voiceId: widget.voiceId,
        timeoutSeconds: 5,
      );

      if (mounted) {
        setState(() {
          _result = result;
          _isListening = false;
          _hasCompleted = true;
          _transcribedText = result.recognizedText;
        });
      }
    } catch (e) {
      Logger.error('Error in voice confirmation: $e', tag: 'VoiceConfirmationScreen');
      if (mounted) {
        setState(() {
          _result = ConfirmationResult.error(e.toString());
          _isListening = false;
          _hasCompleted = true;
        });
      }
    }
  }

  void _handleManualResponse(ConfirmationResponse response) {
    setState(() {
      _result = ConfirmationResult(
        response: response,
        recognizedText: response == ConfirmationResponse.yes ? 'yes' : 'no',
        timestamp: DateTime.now(),
      );
      _hasCompleted = true;
      _isListening = false;
    });

    _confirmationService.stopListening();

    // Close after brief delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context, _result);
      }
    });
  }

  @override
  void dispose() {
    _confirmationService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Medicine info
              const Icon(
                Icons.medication,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                widget.medicineName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.dosage,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),

              // Listening indicator or result
              if (_isListening && !_hasCompleted)
                Column(
                  children: [
                    // Animated listening indicator
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(seconds: 1),
                      onEnd: () {
                        if (mounted && _isListening) {
                          setState(() {});
                        }
                      },
                      builder: (context, value, child) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryGreen.withValues(alpha: 1 - value),
                              width: 3,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.mic,
                              size: 50,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Listening...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Say "yes" or "no"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                )
              else if (_result != null && _hasCompleted)
                Column(
                  children: [
                    // Result icon
                    Icon(
                      _result!.response == ConfirmationResponse.yes
                          ? Icons.check_circle
                          : _result!.response == ConfirmationResponse.no
                              ? Icons.cancel
                              : Icons.error,
                      size: 80,
                      color: _result!.response == ConfirmationResponse.yes
                          ? AppColors.successGreen
                          : _result!.response == ConfirmationResponse.no
                              ? AppColors.warningOrange
                              : AppColors.errorRed,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _result!.response == ConfirmationResponse.yes
                          ? 'Confirmed!'
                          : _result!.response == ConfirmationResponse.no
                              ? 'Skipped'
                              : 'Timeout',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (_transcribedText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Heard: "$_transcribedText"',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),

              const SizedBox(height: 48),

              // Manual buttons
              if (!_hasCompleted)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isListening
                          ? () => _handleManualResponse(ConfirmationResponse.yes)
                          : null,
                      icon: const Icon(Icons.check),
                      label: const Text('Yes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isListening
                          ? () => _handleManualResponse(ConfirmationResponse.no)
                          : null,
                      icon: const Icon(Icons.close),
                      label: const Text('No'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warningOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _result),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Close'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
