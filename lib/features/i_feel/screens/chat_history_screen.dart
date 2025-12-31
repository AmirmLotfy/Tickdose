import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/i_feel_conversation_service.dart';
import '../../../core/models/i_feel_models.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'i_feel_chat_screen.dart';

class ChatHistoryScreen extends ConsumerWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.history),
        ),
        body: const Center(child: Text('Please sign in')),
      );
    }

    final conversationService = IFeelConversationService();
    final conversationsStream = conversationService.getConversations(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.history,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: StreamBuilder<List<IFeelConversation>>(
        stream: conversationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: AppColors.errorRed),
              ),
            );
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(AppIcons.history(), size: 64, color: AppColors.textTertiary(context)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noChatHistoryYet,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    conversation.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  subtitle: Text(
                    '${conversation.messageCount} messages • ${DateFormat('MMM d, y • h:mm a').format(conversation.lastMessageAt)}',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary(context),
                  ),
                  onTap: () {
                    // Navigate to chat screen with conversation ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IFeelChatScreen(
                          conversationId: conversation.id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
