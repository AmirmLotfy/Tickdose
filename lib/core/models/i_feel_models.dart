import 'package:cloud_firestore/cloud_firestore.dart';

/// I Feel message model with voice support
class IFeelMessage {
  final String id;
  final String userId;
  final String text;
  final String sender; // 'user' or 'ai'
  final DateTime timestamp;
  final List<String> medicinesAtTime;
  final bool isVoice;  // NEW: Is this a voice message?
  final String? audioUrl;  // NEW: Cloud storage URL for voice
  final String? audioPath;  // NEW: Local path for voice file
  final String? voiceId;  // NEW: ElevenLabs voice ID used
  final Duration? audioDuration;  // NEW: Length of voice message
  
  IFeelMessage({
    required this.id,
    required this.userId,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.medicinesAtTime = const [],
    this.isVoice = false,
    this.audioUrl,
    this.audioPath,
    this.voiceId,
    this.audioDuration,
  });
  
  /// Create from Firestore document
  factory IFeelMessage.fromFirestore(Map<String, dynamic> data) {
    return IFeelMessage(
      id: data['id'] as String,
      userId: data['userId'] as String,
      text: data['text'] as String,
      sender: data['sender'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      medicinesAtTime: List<String>.from(data['medicines'] ?? []),
      isVoice: data['isVoice'] as bool? ?? false,
      audioUrl: data['audioUrl'] as String?,
      voiceId: data['voiceId'] as String?,
      audioDuration: data['audioDurationMs'] != null
          ? Duration(milliseconds: data['audioDurationMs'] as int)
          : null,
    );
  }
  
  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'text': text,
      'sender': sender,
      'timestamp': Timestamp.fromDate(timestamp),
      'medicines': medicinesAtTime,
      'isVoice': isVoice,
      'audioUrl': audioUrl,
      'voiceId': voiceId,
      'audioDurationMs': audioDuration?.inMilliseconds,
    };
  }
  
  /// Create a copy with modified fields
  IFeelMessage copyWith({
    String? id,
    String? userId,
    String? text,
    String? sender,
    DateTime? timestamp,
    List<String>? medicinesAtTime,
    bool? isVoice,
    String? audioUrl,
    String? audioPath,
    String? voiceId,
    Duration? audioDuration,
  }) {
    return IFeelMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      medicinesAtTime: medicinesAtTime ?? this.medicinesAtTime,
      isVoice: isVoice ?? this.isVoice,
      audioUrl: audioUrl ?? this.audioUrl,
      audioPath: audioPath ?? this.audioPath,
      voiceId: voiceId ?? this.voiceId,
      audioDuration: audioDuration ?? this.audioDuration,
    );
  }
  
  @override
  String toString() => 'IFeelMessage(id: $id, sender: $sender, text: "${text.substring(0, text.length > 30 ? 30 : text.length)}...", isVoice: $isVoice)';
}

/// I Feel conversation model
class IFeelConversation {
  final String id;
  final String userId;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String title;  // Summary of first message
  final int messageCount;
  final List<IFeelMessage> messages;
  
  IFeelConversation({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.lastMessageAt,
    required this.title,
    this.messageCount = 0,
    this.messages = const [],
  });
  
  /// Create from Firestore document
  factory IFeelConversation.fromFirestore(Map<String, dynamic> data) {
    return IFeelConversation(
      id: data['id'] as String,
      userId: data['userId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastMessageAt: (data['lastMessageAt'] as Timestamp).toDate(),
      title: data['title'] as String,
      messageCount: data['messageCount'] as int? ?? 0,
    );
  }
  
  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'title': title,
      'messageCount': messageCount,
    };
  }
}
