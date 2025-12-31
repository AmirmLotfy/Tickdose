import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/services/remote_config_service.dart';
import '../../../core/services/api_error.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/services/i_feel_conversation_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger.dart';
import '../../../features/navigation/routes/route_names.dart';
import '../../profile/providers/profile_provider.dart';
import '../../medicines/providers/medicine_provider.dart';
import '../../medicines/screens/log_side_effect_screen.dart';
import '../../../core/models/medicine_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../settings/screens/privacy_settings_screen.dart';

class IFeelChatScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  final String? conversationId; // Optional: load existing conversation
  
  const IFeelChatScreen({super.key, this.isEmbedded = false, this.conversationId});

  @override
  ConsumerState<IFeelChatScreen> createState() => _IFeelChatScreenState();
}

class _IFeelChatScreenState extends ConsumerState<IFeelChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _isListening = false;
  final ScrollController _scrollController = ScrollController();
  final IFeelConversationService _conversationService = IFeelConversationService();
  final SpeechService _speechService = SpeechService();
  String? _currentConversationId;

  @override
  void initState() {
    super.initState();
    _speechService.initialize();
    _currentConversationId = widget.conversationId;
    if (widget.conversationId != null) {
      _loadConversation(widget.conversationId!);
    }
  }

  Future<void> _loadConversation(String conversationId) async {
    try {
      final messagesStream = _conversationService.getMessages(conversationId);
      await for (final messages in messagesStream) {
        if (mounted && messages.isNotEmpty) {
          setState(() {
            _messages.clear();
            _messages.addAll(messages.map((msg) => {
              'sender': msg.sender,
              'text': msg.text,
            }).toList());
          });
          _scrollToBottom();
          break; // Load once
        }
      }
    } catch (e) {
      Logger.error('Error loading conversation: $e', tag: 'IFeelChat');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _speechService.stopListening();
    super.dispose();
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
    final l10n = AppLocalizations.of(context)!;
    final medicinesAsync = ref.watch(medicinesStreamProvider);
    final medicines = medicinesAsync.value ?? [];
    final activeMedicines = medicines.take(2).map((m) => m.name).toList();
    final medicinesText = activeMedicines.join(', ');

    final content = Column(
      children: [
        // Header
        _buildHeader(context),
        // Context Indicator
        _buildContextIndicator(context, medicinesText),
        // Chat Messages
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyState(context)
              : _buildChatMessages(context),
        ),
        // Bottom Interface
        _buildBottomInterface(context),
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(context),
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight(context),
            width: 1,
          ),
        ),
      ),
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
                  l10n.iFeelAssistant,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.online,
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, size: 24),
            onPressed: () {
              // Show menu
            },
            color: AppColors.textPrimary(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContextIndicator(BuildContext context, String medicinesText) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.medication_liquid,
              color: AppColors.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.activeContext,
                  style: TextStyle(
                    color: AppColors.primaryGreen.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  medicinesText.isEmpty ? l10n.noActiveMedications : medicinesText,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.medicinesList);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.05),
              side: BorderSide(
                color: AppColors.primaryGreen.withValues(alpha: 0.2),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              l10n.viewMeds,
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + 1, // +1 for date divider
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildDateDivider(context);
        }
        final message = _messages[index - 1];
        final isUser = message['sender'] == 'user';
        return _buildMessageBubble(context, message['text']!, isUser, index == 1);
      },
    );
  }

  Widget _buildDateDivider(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final locale = Localizations.localeOf(context);
    final formatter = DateFormat('EEEE, h:mm a', locale.toString());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          l10n.todayAt(formatter.format(now)),
          style: TextStyle(
            color: AppColors.textTertiary(context),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, String text, bool isUser, bool isFirst) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAIAvatar(),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isUser && isFirst)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 6, start: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.primaryGreen.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 10,
                            color: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.iFeelAI,
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.primaryGreen
                        : AppColors.cardColor(context),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                    ),
                    border: Border.all(
                      color: isUser
                          ? AppColors.primaryGreen.withValues(alpha: 0.3)
                          : AppColors.borderLight(context),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? AppColors.primaryGreen.withValues(alpha: 0.2)
                            : AppColors.shadowColorLight(context),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isUser 
                      ? Text(
                          text,
                          style: TextStyle(
                            color: isDark ? AppColors.darkBackground : AppColors.textPrimary(context),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            letterSpacing: 0.1,
                          ),
                          softWrap: true,
                        )
                      : MarkdownBody(
                          data: text,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 15,
                              height: 1.6,
                              letterSpacing: 0.1,
                            ),
                            strong: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.bold,
                            ),
                            listBullet: TextStyle(
                              color: AppColors.textPrimary(context),
                            ),
                            code: TextStyle(
                              color: AppColors.primaryGreen,
                              backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                ),
                if (isUser)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 6, end: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Read ${DateFormat('h:mm a', Localizations.localeOf(context).toString()).format(DateTime.now())}',
                          style: TextStyle(
                            color: AppColors.textTertiary(context),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all_rounded,
                          color: AppColors.primaryGreen,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen.withValues(alpha: 0.2),
            AppColors.primaryGreen.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.psychology_rounded,
        color: AppColors.primaryGreen,
        size: 20,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              'How are you feeling?',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.describeSymptoms,
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

  Widget _buildBottomInterface(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(context).withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: AppColors.borderLight(context),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Recommendation Chips
              if (_messages.isNotEmpty)
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildRecommendationChip(
                              context,
                              l10n.logSymptom,
                              Icons.edit_note,
                              true,
                            ),
                            const SizedBox(width: 8),
                            _buildRecommendationChip(
                              context,
                              l10n.reportSideEffect,
                              Icons.medical_services,
                              false,
                            ),
                            const SizedBox(width: 8),
                            _buildRecommendationChip(
                              context,
                              l10n.callDoctor,
                              Icons.call,
                              false,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              // Input Field
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardColor(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.borderLight(context),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.add_circle,
                          color: AppColors.textSecondary(context),
                        ),
                        onPressed: () => _showQuickActions(context),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          maxLines: null,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 15,
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              color: AppColors.textTertiary(context),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: _sendMessage,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening 
                              ? AppColors.primaryGreen 
                              : AppColors.textSecondary(context),
                        ),
                        onPressed: _isListening ? _stopVoiceInput : _startVoiceInput,
                      ),
                      Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.4),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, size: 20),
                          color: AppColors.backgroundColor(context),
                          onPressed: () => _sendMessage(_controller.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Disclaimer Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 12,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'AI is not a doctor. Call emergency services for urgent needs.',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationChip(
    BuildContext context,
    String label,
    IconData icon,
    bool isPrimary,
  ) {
    return GestureDetector(
      onTap: () {
        if (label.contains('Log')) {
          // Navigate to medicines list to log symptom
          Navigator.pushNamed(context, Routes.medicinesList);
        } else if (label.contains('Report')) {
          // Show dialog to select medicine for side effect reporting
          _showMedicineSelectionDialog(context);
        } else if (label.contains('Call')) {
          // Call emergency services
          _callEmergency(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primaryGreen.withValues(alpha: 0.1)
              : AppColors.surfaceColor(context).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isPrimary
                ? AppColors.primaryGreen.withValues(alpha: 0.3)
                : AppColors.borderLight(context),
            width: 1,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary
                  ? AppColors.primaryGreen
                  : AppColors.textPrimary(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isPrimary
                    ? AppColors.primaryGreen
                    : AppColors.textPrimary(context),
                fontSize: 12,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
            ),
      ),
    );
  }

  Future<void> _showMedicineSelectionDialog(BuildContext context) async {
    final medicinesAsync = ref.read(medicinesStreamProvider);
    final medicines = medicinesAsync.value ?? [];
    
    if (medicines.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noMedicinesAdded),
            backgroundColor: AppColors.warningOrange,
          ),
        );
        // Navigate to add medicine screen
        Navigator.pushNamed(context, Routes.addMedicine);
      }
      return;
    }

    if (!context.mounted) return;
    
    final l10n = AppLocalizations.of(context)!;
    final selectedMedicine = await showDialog<MedicineModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.medicines),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];
              return ListTile(
                title: Text(medicine.name),
                subtitle: medicine.genericName.isNotEmpty 
                    ? Text(medicine.genericName) 
                    : null,
                onTap: () => Navigator.pop(context, medicine),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );

    if (selectedMedicine != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LogSideEffectScreen(medicine: selectedMedicine),
        ),
      );
    }
  }

  Future<void> _startVoiceInput() async {
    try {
      setState(() => _isListening = true);
      await _speechService.startListening(
        onResult: (text) {
          setState(() {
            _controller.text = text;
          });
        },
        language: Localizations.localeOf(context).toString(),
      );
    } catch (e) {
      Logger.error('Voice input error: $e', tag: 'IFeelChat');
      setState(() => _isListening = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
        );
      }
    }
  }

  Future<void> _stopVoiceInput() async {
    try {
      await _speechService.stopListening();
      setState(() => _isListening = false);
      if (_controller.text.trim().isNotEmpty) {
        _sendMessage(_controller.text);
      }
    } catch (e) {
      Logger.error('Error stopping voice input: $e', tag: 'IFeelChat');
      setState(() => _isListening = false);
    }
  }

  void _showQuickActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: Text(l10n.logSymptom),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.medicinesList);
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: Text(l10n.reportSideEffect),
              onTap: () {
                Navigator.pop(context);
                _showMedicineSelectionDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.call),
              title: Text(l10n.callDoctor),
              onTap: () {
                Navigator.pop(context);
                _callEmergency(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callEmergency(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: '911');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.couldNotMakeCall),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorWithMessage(e.toString())),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final config = RemoteConfigService();
      final apiKey = config.getGeminiApiKey();
      
      final userProfileAsync = ref.read(userProfileProvider);
      final userProfile = userProfileAsync.value;

      // Create conversation if this is the first message
      if (_currentConversationId == null) {
        _currentConversationId = await _conversationService.createConversation(
          userId: user.uid,
          firstMessage: text,
        );
      }

      // Save user message to Firestore
      final medicinesAsync = ref.read(medicinesStreamProvider);
      final medicines = medicinesAsync.value ?? [];
      await _conversationService.addMessage(
        conversationId: _currentConversationId!,
        userId: user.uid,
        text: text,
        sender: 'user',
        medicinesAtTime: medicines.take(2).map((m) => m.name).toList(),
      );

      final responseText = await GeminiService().sendChatMessage(
        text, 
        apiKey: apiKey,
        userProfile: userProfile,
      );

      if (mounted) {
        setState(() {
          _messages.add({'sender': 'ai', 'text': responseText});
          _isLoading = false;
        });

        // Save AI response to Firestore
        await _conversationService.addMessage(
          conversationId: _currentConversationId!,
          userId: user.uid,
          text: responseText,
          sender: 'ai',
        );

        AudioService().playSound(SoundEffect.success); 
        _scrollToBottom();
      }
    } on ApiError catch (apiError) {
      if (mounted) {
        setState(() => _isLoading = false);
        final errorMessage = apiError.type.getLocalizedMessage(l10n);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithMessage(e.toString()))),
        );
      }
    }
  }
}
