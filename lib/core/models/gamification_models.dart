
import 'package:cloud_firestore/cloud_firestore.dart';

enum QuestType {
  daily,
  weekly,
  challenge,
  milestone
}

enum QuestStatus {
  active,
  completed,
  claimed // Reward claimed
}

class QuestModel {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final QuestType type;
  final QuestStatus status;
  final Map<String, dynamic> metadata; // For tracking progress (e.g., {"target": 3, "current": 1})
  final DateTime createdAt;
  final DateTime? expiresAt;

  QuestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.type,
    this.status = QuestStatus.active,
    this.metadata = const {},
    required this.createdAt,
    this.expiresAt,
  });

  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      xpReward: json['xp_reward'] as int,
      type: QuestType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => QuestType.daily,
      ),
      status: QuestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => QuestStatus.active,
      ),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: (json['created_at'] as Timestamp).toDate(),
      expiresAt: json['expires_at'] != null ? (json['expires_at'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'xp_reward': xpReward,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'metadata': metadata,
      'created_at': Timestamp.fromDate(createdAt),
      'expires_at': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  QuestModel copyWith({
    String? id,
    String? title,
    String? description,
    int? xpReward,
    QuestType? type,
    QuestStatus? status,
    Map<String, dynamic>? metadata,
    DateTime? expiresAt,
  }) {
    return QuestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      type: type ?? this.type,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String iconAsset; // Path to local asset or URL
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int xpValue;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    this.isUnlocked = false,
    this.unlockedAt,
    this.xpValue = 100,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconAsset: json['icon_asset'] as String,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] != null ? (json['unlocked_at'] as Timestamp).toDate() : null,
      xpValue: json['xp_value'] as int? ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon_asset': iconAsset,
      'is_unlocked': isUnlocked,
      'unlocked_at': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
      'xp_value': xpValue,
    };
  }
}

class UserProgressModel {
  final String userId;
  final int currentXp;
  final int currentLevel;
  final int dailyStreak;
  final int totalQuestsCompleted;

  UserProgressModel({
    required this.userId,
    this.currentXp = 0,
    this.currentLevel = 1,
    this.dailyStreak = 0,
    this.totalQuestsCompleted = 0,
  });

  // Simple leveling formula: Level N requires N * 1000 XP total, or simple thresholds
  // Let's say Level 1 -> 2 needs 500 XP. Level 2 -> 3 needs 1000 XP.
  // We can just store current XP and calculate level dynamically or persist it.
  
  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      userId: json['user_id'] as String,
      currentXp: json['current_xp'] as int? ?? 0,
      currentLevel: json['current_level'] as int? ?? 1,
      dailyStreak: json['daily_streak'] as int? ?? 0,
      totalQuestsCompleted: json['total_quests_completed'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'current_xp': currentXp,
      'current_level': currentLevel,
      'daily_streak': dailyStreak,
      'total_quests_completed': totalQuestsCompleted,
    };
  }
  
  UserProgressModel copyWith({
    int? currentXp,
    int? currentLevel,
    int? dailyStreak,
    int? totalQuestsCompleted,
  }) {
    return UserProgressModel(
      userId: userId,
      currentXp: currentXp ?? this.currentXp,
      currentLevel: currentLevel ?? this.currentLevel,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      totalQuestsCompleted: totalQuestsCompleted ?? this.totalQuestsCompleted,
    );
  }
}
