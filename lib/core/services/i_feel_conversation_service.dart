import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tickdose/core/models/i_feel_models.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:uuid/uuid.dart';

class IFeelConversationService {
  static final IFeelConversationService _instance = IFeelConversationService._internal();
  factory IFeelConversationService() => _instance;
  IFeelConversationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /// Create a new conversation and return its ID
  Future<String> createConversation({
    required String userId,
    required String firstMessage,
  }) async {
    try {
      final conversationId = _uuid.v4();
      final now = DateTime.now();
      
      // Create conversation title from first message (first 50 chars)
      final title = firstMessage.length > 50 
          ? '${firstMessage.substring(0, 50)}...'
          : firstMessage;

      await _firestore.collection('iFeelConversations').doc(conversationId).set({
        'id': conversationId,
        'userId': userId,
        'createdAt': Timestamp.fromDate(now),
        'lastMessageAt': Timestamp.fromDate(now),
        'title': title,
        'messageCount': 0,
      });

      Logger.info('Conversation created: $conversationId', tag: 'IFeelConversation');
      return conversationId;
    } catch (e) {
      Logger.error('Error creating conversation: $e', tag: 'IFeelConversation');
      rethrow;
    }
  }

  /// Add a message to a conversation
  Future<void> addMessage({
    required String conversationId,
    required String userId,
    required String text,
    required String sender,
    List<String>? medicinesAtTime,
  }) async {
    try {
      final messageId = _uuid.v4();
      final now = DateTime.now();

      // Add message to subcollection
      await _firestore
          .collection('iFeelConversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .set({
        'id': messageId,
        'userId': userId,
        'text': text,
        'sender': sender,
        'timestamp': Timestamp.fromDate(now),
        'medicines': medicinesAtTime ?? [],
        'isVoice': false,
      });

      // Update conversation metadata
      await _firestore
          .collection('iFeelConversations')
          .doc(conversationId)
          .update({
        'lastMessageAt': Timestamp.fromDate(now),
        'messageCount': FieldValue.increment(1),
      });

      Logger.info('Message added to conversation: $conversationId', tag: 'IFeelConversation');
    } catch (e) {
      Logger.error('Error adding message: $e', tag: 'IFeelConversation');
      rethrow;
    }
  }

  /// Get all conversations for a user
  Stream<List<IFeelConversation>> getConversations(String userId) {
    return _firestore
        .collection('iFeelConversations')
        .where('userId', isEqualTo: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => IFeelConversation.fromFirestore({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    });
  }

  /// Get messages for a conversation
  Stream<List<IFeelMessage>> getMessages(String conversationId) {
    return _firestore
        .collection('iFeelConversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => IFeelMessage.fromFirestore({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    });
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Delete all messages first
      final messagesSnapshot = await _firestore
          .collection('iFeelConversations')
          .doc(conversationId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_firestore.collection('iFeelConversations').doc(conversationId));
      await batch.commit();

      Logger.info('Conversation deleted: $conversationId', tag: 'IFeelConversation');
    } catch (e) {
      Logger.error('Error deleting conversation: $e', tag: 'IFeelConversation');
      rethrow;
    }
  }
}

