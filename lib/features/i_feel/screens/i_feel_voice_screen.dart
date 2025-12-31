import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;
import '../../../core/models/i_feel_models.dart';
import '../../../core/services/elevenlabs_service.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/services/api_error.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/remote_config_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger.dart';
import '../../auth/providers/auth_provider.dart';
import '../../medicines/providers/medicine_provider.dart';
import '../../navigation/widgets/bottom_nav_bar.dart';
import '../../navigation/routes/route_names.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/widgets/permission_dialog.dart';
import '../../../core/services/permission_service.dart';

/// I Feel Voice - Voice-First Symptom Checker
/// Uses ElevenLabs for voice responses and speech recognition for input
class IFeelVoiceScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;

  const IFeelVoiceScreen({super.key, this.isEmbedded = false});

  @override
  ConsumerState<IFeelVoiceScreen> createState() => _IFeelVoiceScreenState();
}

class _IFeelVoiceScreenState extends ConsumerState<IFeelVoiceScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<IFeelMessage> _messages = [];
  
  final uuid = const Uuid();
  final ElevenLabsService _elevenLabs = ElevenLabsService();
  final SpeechService _speech = SpeechService();
  
  bool _isLoading = false;
  bool _isListening = false;
  bool _isPlaying = false;
  String? _selectedVoiceId;
  
  late List<AnimationController> _waveformControllers;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    _waveformControllers = List.generate(
      7,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 800 + (index * 200)),
      )..repeat(reverse: true),
    );
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    for (var controller in _waveformControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  Future<void> _initializeServices() async {
    try {
      await _elevenLabs.initialize();
      Logger.info('ElevenLabs service initialized');
      
      // Try to get voices - if API key is not configured, this will return empty list silently
      final voices = await _elevenLabs.getAvailableVoices();
      if (voices.isNotEmpty) {
        setState(() {
          _selectedVoiceId = voices.first.id;
        });
        Logger.info('Selected voice: ${voices.first.name}');
      } else {
        Logger.info('No voices available - voice features may be disabled if API key is not configured', tag: 'IFeelVoice');
      }
      
      await _speech.initialize();
      Logger.info('Speech service initialized');
      
    } catch (e) {
      // Only show error for critical failures, not for missing API keys
      Logger.warn('Service initialization warning: $e', tag: 'IFeelVoice');
      // Don't show error banner - voice features are optional
    }
  }
  
  Future<void> _startVoiceInput() async {
    try {
      // Check microphone permission first
      final permissionService = PermissionService();
      final hasPermission = await permissionService.requestMicrophonePermission();
      
      if (!hasPermission) {
        if (mounted) {
          await PermissionDialog.showMicrophonePermission(
            context,
            onGrant: () async {
              final granted = await permissionService.requestMicrophonePermission();
              if (granted && mounted) {
                await _startVoiceInput();
              }
            },
            onDeny: () {},
          );
        }
        return;
      }
      
      setState(() => _isListening = true);
      
      for (var controller in _waveformControllers) {
        controller.repeat();
      }
      
      await _speech.startListening(
        onResult: (text) {
          setState(() {
            _textController.text = text;
          });
        },
        language: Localizations.localeOf(context).toString(),
      );
      
      Future.delayed(const Duration(seconds: 30), () {
        if (_isListening) {
          _stopVoiceInput();
        }
      });
      
    } catch (e) {
      Logger.error('Voice input error: $e');
      setState(() => _isListening = false);
      
      for (var controller in _waveformControllers) {
        controller.stop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorWithMessage(e.toString()))),
        );
      }
    }
  }
  
  Future<void> _stopVoiceInput() async {
    try {
      await _speech.stopListening();
      setState(() => _isListening = false);
      
      for (var controller in _waveformControllers) {
        controller.stop();
        controller.reset();
      }
      
      if (_textController.text.trim().isNotEmpty) {
        _sendMessage();
      }
    } catch (e) {
      Logger.error('Error stopping voice input: $e');
    }
  }
  
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    _textController.clear();
    
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first')),
      );
      return;
    }
    
    final medicinesAsync = ref.read(medicinesStreamProvider);
    final medicines = medicinesAsync.value?.map((m) => '${m.name} (${m.dosage})').toList() ?? [];
    
    final userMessage = IFeelMessage(
      id: uuid.v4(),
      userId: user.uid,
      text: text,
      sender: 'user',
      timestamp: DateTime.now(),
      medicinesAtTime: medicines,
    );
    
    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });
    
    _scrollToBottom();
    
    try {
      final config = RemoteConfigService();
      final geminiService = GeminiService();
      final aiText = await geminiService.checkSymptom(
        symptom: text,
        userMedicines: medicines,
        apiKey: config.getGeminiApiKey(),
      );
      
      final aiMessage = IFeelMessage(
        id: uuid.v4(),
        userId: user.uid,
        text: aiText,
        sender: 'ai',
        timestamp: DateTime.now(),
        medicinesAtTime: medicines,
        voiceId: _selectedVoiceId,
      );
      
      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });
      
      _scrollToBottom();
      
      if (_selectedVoiceId != null) {
        await _generateVoiceResponse(aiText);
      }
      
      await AudioService().playSound(SoundEffect.success);
      
    } on ApiError catch (apiError) {
      Logger.error('Error sending message: $apiError');
      final l10n = AppLocalizations.of(context)!;
      final errorMessageText = apiError.type.getLocalizedMessage(l10n);
      
      final errorMessage = IFeelMessage(
        id: uuid.v4(),
        userId: user.uid,
        text: errorMessageText,
        sender: 'ai',
        timestamp: DateTime.now(),
        medicinesAtTime: medicines,
      );
      
      setState(() {
        _messages.add(errorMessage);
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessageText)),
        );
      }
    } catch (e) {
      Logger.error('Error sending message: $e');
      final l10n = AppLocalizations.of(context)!;
      
      final errorMessage = IFeelMessage(
        id: uuid.v4(),
        userId: user.uid,
        text: l10n.apiGenericError,
        sender: 'ai',
        timestamp: DateTime.now(),
        medicinesAtTime: medicines,
      );
      
      setState(() {
        _messages.add(errorMessage);
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
        );
      }
    }
  }
  
  Future<void> _generateVoiceResponse(String text) async {
    try {
      if (_selectedVoiceId == null) return;
      
      Logger.info('Generating voice for: ${text.substring(0, math.min(50, text.length))}...');
      
      final audioPath = await _elevenLabs.textToSpeech(
        text: text,
        voiceId: _selectedVoiceId!,
      );
      
      setState(() => _isPlaying = true);
      
      await _elevenLabs.playAudio(audioPath: audioPath);
      
      _elevenLabs.playingStream.listen((playing) {
        if (mounted) {
          setState(() => _isPlaying = playing);
        }
      });
      
    } on ApiError catch (apiError) {
      Logger.error('Voice generation error: $apiError');
      setState(() => _isPlaying = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiError.type.getLocalizedMessage(l10n))),
        );
      }
    } catch (e) {
      Logger.error('Voice generation error: $e');
      setState(() => _isPlaying = false);
    }
  }
  
  Future<void> _playVoiceMessage(IFeelMessage message) async {
    try {
      if (message.voiceId == null) {
        await _generateVoiceResponse(message.text);
      } else {
        await _generateVoiceResponse(message.text);
      }
    } on ApiError catch (apiError) {
      Logger.error('Error playing voice message: $apiError');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiError.type.getLocalizedMessage(l10n))),
        );
      }
    } catch (e) {
      Logger.error('Error playing voice message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorWithMessage(e.toString()))),
        );
      }
    }
  }
  
  Future<void> _stopPlayback() async {
    try {
      await _elevenLabs.stopPlayback();
      setState(() => _isPlaying = false);
    } catch (e) {
      Logger.error('Error stopping playback: $e');
    }
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        // Header
        _buildHeader(context),
        // Main Content
        Expanded(
          child: Stack(
            children: [
              // Chat Messages
              _buildChatArea(context),
              // Visualization & Action Area
              _buildVisualizationArea(context),
            ],
          ),
        ),
        // Bottom Navigation - Only show when not embedded (standalone mode)
        // When embedded in IFeelScreen, the parent handles navigation
        // Note: Standalone mode typically doesn't need bottom nav as it's a detail screen
        // but if needed, it should navigate back to home
        if (!widget.isEmbedded)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: BottomNavBar(
              currentIndex: 2, // Tracking tab (I Feel is part of tracking/health)
              onTap: (index) {
                // Navigate based on tab
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, Routes.home);
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, Routes.reminders);
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, Routes.tracking);
                } else if (index == 3) {
                  Navigator.pushReplacementNamed(context, Routes.pharmacy);
                } else if (index == 4) {
                  Navigator.pushReplacementNamed(context, Routes.profile);
                }
              },
            ),
          ),
      ],
    );

    if (widget.isEmbedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: content,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
            color: AppColors.textPrimary(context),
          ),
          Expanded(
        child: Column(
          children: [
            Text(
                  'AI Assistant',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                    fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.75),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
            Text(
                      'Active',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              ],
            ),
          ],
        ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 24),
            onPressed: () {
              // Show settings
            },
            color: AppColors.textPrimary(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChatArea(BuildContext context) {
    return _messages.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildDateDivider(context);
              }
              return _buildMessageBubble(_messages[index - 1]);
            },
          );
  }

  Widget _buildDateDivider(BuildContext context) {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, h:mm a');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceColor(context)
                : AppColors.textSecondary(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Today, ${formatter.format(now)}',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondary(context)
                  : AppColors.textSecondary(context).withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(IFeelMessage message) {
    final isUser = message.sender == 'user';
    final isSpeaking = !isUser && _isPlaying && _messages.last.id == message.id;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryGreen.withValues(alpha: 0.2),
                    AppColors.primaryGreen.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.smart_toy,
                color: AppColors.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
        child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
                Row(
                  children: [
                    Text(
                      isUser ? 'You' : 'Tickdose AI',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isSpeaking) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Speaking...',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.primaryGreen.withValues(alpha: 0.2)
                        : Theme.of(context).brightness == Brightness.dark
                            ? AppColors.surfaceColor(context)
                            : AppColors.cardColor(context),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(8),
                      topRight: const Radius.circular(8),
                      bottomLeft: isUser ? const Radius.circular(8) : Radius.zero,
                      bottomRight: isUser ? Radius.zero : const Radius.circular(8),
                    ),
                    border: Border.all(
                      color: isSpeaking
                          ? AppColors.primaryGreen.withValues(alpha: 0.3)
                          : AppColors.borderLight(context),
                      width: 1,
                    ),
                    boxShadow: isSpeaking
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: AppColors.shadowColorLight(context),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Stack(
                    children: [
                      if (isSpeaking)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.text,
                            style: TextStyle(
                              color: isUser
                                  ? AppColors.textPrimary(context)
                                  : Theme.of(context).brightness == Brightness.dark
                                      ? AppColors.textPrimary(context)
                                      : AppColors.textTertiary(context),
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          if (!isUser && message.voiceId != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.only(top: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? AppColors.borderLight(context)
                                        : AppColors.borderLight(context),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.replay,
                                      size: 18,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? AppColors.textSecondary(context)
                                          : AppColors.textTertiary(context),
                                    ),
                                    onPressed: () => _playVoiceMessage(message),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.volume_up,
                                      size: 18,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? AppColors.textSecondary(context)
                                          : AppColors.textTertiary(context),
                                    ),
                                    onPressed: () => _playVoiceMessage(message),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '0:04 / 0:12',
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? AppColors.textSecondary(context)
                                          : AppColors.textTertiary(context),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.borderLight(context),
                  width: 1,
                ),
                // In a real app, this would be the user's profile image
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.person,
                color: AppColors.primaryGreen,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVisualizationArea(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundColor(context).withValues(alpha: 0.0),
              AppColors.backgroundColor(context),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Text
            Text(
              _isListening ? 'Listening...' : 'Tap to start',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Audio Visualizer
            if (_isListening) _buildWaveformVisualizer(),
            const SizedBox(height: 32),
            // Main Action Button
            _buildMainActionButton(context),
            const SizedBox(height: 16),
            Text(
              _isListening ? 'Tap to stop recording' : 'Tap to start recording',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWaveformVisualizer() {
    final heights = [0.3, 0.5, 0.8, 1.0, 0.7, 0.4, 0.2];
    
    return SizedBox(
      height: 64,
      width: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          return AnimatedBuilder(
            animation: _waveformControllers[index],
            builder: (context, child) {
              final animatedHeight = heights[index] +
                  (_waveformControllers[index].value * 0.2);
    return Container(
                width: 6,
                height: 64 * animatedHeight,
                margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
                  color: index < 3
                      ? AppColors.primaryGreen.withValues(alpha: 0.4 + index * 0.1)
                      : AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: index >= 3
                      ? [
          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.6),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildMainActionButton(BuildContext context) {
    return GestureDetector(
      onTap: _isListening ? _stopVoiceInput : _startVoiceInput,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          if (_isListening)
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          // Ping animation
          if (_isListening)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.cardColor(context).withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
            ),
          // Main button
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.mic,
              color: AppColors.backgroundColor(context),
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services,
              size: 64,
              color: AppColors.textTertiary(context),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.howAreYouFeeling,
              style: TextStyle(
                fontSize: 20,
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.describeSymptomsByVoiceOrText,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
