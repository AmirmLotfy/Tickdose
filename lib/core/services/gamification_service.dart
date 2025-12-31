
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tickdose/core/models/gamification_models.dart';
import 'package:tickdose/core/models/user_model.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/core/services/gemini_service.dart';
import 'package:tickdose/core/services/remote_config_service.dart';

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Collection references
  CollectionReference get _usersRef => _firestore.collection('users');
  CollectionReference _questsRef(String userId) => _usersRef.doc(userId).collection('quests');
  // CollectionReference _achievementsRef(String userId) => _usersRef.doc(userId).collection('achievements');

  /// Initialize user progress if not exists
  Future<void> initializeUserProgress(String userId) async {
    final docRef = _usersRef.doc(userId);
    final docSnapshot = await docRef.get();
    
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      if (!data.containsKey('current_xp')) {
        // Migrate existing user
        await docRef.update({
          'current_xp': 0,
          'current_level': 1,
          'daily_streak': 0,
          'total_quests_completed': 0,
        });
      }
    }
  }

  /// Get current user progress
  Stream<UserProgressModel> getUserProgressStream() {
    if (_userId == null) return const Stream.empty();
    
    return _usersRef.doc(_userId).snapshots().map((snapshot) {
      if (!snapshot.exists) return UserProgressModel(userId: _userId!);
      return UserProgressModel.fromJson(snapshot.data() as Map<String, dynamic>);
    });
  }

  /// Award XP to user and check for level up
  Future<void> awardXp(int amount, {String? reason}) async {
    if (_userId == null) return;
    
    try {
      final userRef = _usersRef.doc(_userId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) return; // Should handle init

        final currentXp = snapshot.get('current_xp') as int? ?? 0;
        final currentLevel = snapshot.get('current_level') as int? ?? 1;
        
        int newXp = currentXp + amount;
        int newLevel = currentLevel;

        // Simple linear leveling: Level * 1000 XP threshold for next level
        // e.g. Level 1 needs 1000 total to reach Level 2.
        // Actually, let's do a cumulative curve: Level N requires 500 * N * (N-1) total XP?
        // Let's keep it simple: Threshold for Level L+1 is L * 500 XP (relative to level start)
        // Or specific thresholds.
        
        // Threshold check
        // int nextLevelThreshold = currentLevel * 500; 
        // If we want total XP based:
        // Level 1: 0-499
        // Level 2: 500-1499 (+1000)
        // Level 3: 1500-2999 (+1500)
        
        // Simplest: Level = (XP / 500).floor() + 1 ?
        // 0 XP -> Lvl 1
        // 500 XP -> Lvl 2
        // 1000 XP -> Lvl 3 
        // This is easy to track.
        
        int calculatedLevel = (newXp / 500).floor() + 1;
        
        if (calculatedLevel > currentLevel) {
          newLevel = calculatedLevel;
          Logger.info('Level Up! New Level: $newLevel', tag: 'Gamification');
          // TODO: Trigger visual celebration
        }

        transaction.update(userRef, {
          'current_xp': newXp,
          'current_level': newLevel,
        });
      });
      
    } catch (e) {
      Logger.error('Failed to award XP: $e', tag: 'GamificationService');
    }
  }

  /// Generate or fetch daily quests
  Future<List<QuestModel>> getDailyQuests() async {
    if (_userId == null) return [];
    
    // Check if we have quests for today
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    final snapshot = await _questsRef(_userId!)
        .where('type', isEqualTo: 'daily')
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs
          .map((doc) => QuestModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } else {
      // Try AI Generation
      try {
        final config = RemoteConfigService();
        final apiKey = config.getGeminiApiKey();
        
        if (apiKey.isNotEmpty) {
           // Fetch User Profile locally since we don't have Ref here
           final userDoc = await _usersRef.doc(_userId).get();
           if (userDoc.exists) {
             final userProfile = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
             
             final aiQuestsData = await GeminiService().generatePersonalizedQuests(
               userProfile: userProfile, 
               apiKey: apiKey
             );
             
             if (aiQuestsData.isNotEmpty) {
               final aiQuests = aiQuestsData.map((data) {
                 return QuestModel(
                   id: data['id'] ?? 'quest_${DateTime.now().millisecondsSinceEpoch}',
                   title: data['title'] ?? 'Daily Quest',
                   description: data['description'] ?? 'Complete this task',
                   xpReward: (data['xp_reward'] as num?)?.toInt() ?? 50,
                   type: QuestType.daily,
                   createdAt: DateTime.now(),
                   expiresAt: DateTime.now().add(const Duration(hours: 24)),
                 );
               }).toList();
               
               await _saveQuestsToFirestore(aiQuests);
               return aiQuests;
             }
           }
        }
      } catch (e) {
        Logger.error('AI Quest Generation failed, using defaults: $e', tag: 'GamificationService');
      }

      // Fallback to defaults
      return _generateDefaultDailyQuests();
    }
  }

  Future<void> _saveQuestsToFirestore(List<QuestModel> quests) async {
    final batch = _firestore.batch();
    for (var quest in quests) {
      final dateStr = DateTime.now().toIso8601String().split('T')[0];
      final uniqueId = '${quest.id}_$dateStr';
      
      batch.set(_questsRef(_userId!).doc(uniqueId), 
         quest.copyWith(id: uniqueId).toJson()
      );
    }
    await batch.commit();
  }

  Future<List<QuestModel>> _generateDefaultDailyQuests() async {
    if (_userId == null) return [];
    
    final defaultQuests = [
      QuestModel(
        id: 'daily_log_in',
        title: 'Daily Check-in',
        description: 'Open the app and check your schedule.',
        xpReward: 50,
        type: QuestType.daily,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      ),
      QuestModel(
        id: 'daily_all_meds',
        title: 'Perfect Adherence',
        description: 'Take all your scheduled medicines today.',
        xpReward: 100,
        type: QuestType.daily,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      ),
    ];
    
    await _saveQuestsToFirestore(defaultQuests);
    return defaultQuests;
  }
}
