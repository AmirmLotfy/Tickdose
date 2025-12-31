import 'package:flutter/material.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/features/profile/providers/settings_provider.dart';
import 'package:tickdose/features/navigation/routes/route_names.dart';
import 'package:tickdose/core/services/gamification_service.dart';
import 'package:tickdose/core/models/gamification_models.dart';
import 'package:tickdose/features/tracking/services/tracking_service.dart';

// Provider for user progress
final userProgressProvider = StreamProvider<UserProgressModel>((ref) {
  final service = GamificationService();
  return service.getUserProgressStream();
});

// Provider for daily quests
final dailyQuestsProvider = FutureProvider<List<QuestModel>>((ref) async {
  final service = GamificationService();
  return await service.getDailyQuests();
});

// Provider for stats
final profileStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return {
      'streak': 0,
      'meds': 0,
      'adherence': 0.0,
      'points': 0,
    };
  }

  final trackingService = TrackingService();
  final streak = await trackingService.getStreak(user.uid);
  
  // Get monthly stats for meds count
  final monthlyStats = await trackingService.getMonthlyStats(user.uid, DateTime.now());
  final meds = monthlyStats['taken'] ?? 0;
  final total = (monthlyStats['taken'] ?? 0) + (monthlyStats['missed'] ?? 0) + (monthlyStats['skipped'] ?? 0);
  final adherence = total > 0 ? ((monthlyStats['taken'] ?? 0) / total * 100) : 0.0;

  // Get XP as points
  final progressAsync = ref.watch(userProgressProvider);
  final progress = progressAsync.value;
  final points = progress?.currentXp ?? 0;

  return {
    'streak': streak,
    'meds': meds,
    'adherence': adherence,
    'points': points,
  };
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _getLevelName(int level) {
    if (level >= 10) return 'Health Master';
    if (level >= 7) return 'Health Guardian';
    if (level >= 5) return 'Wellness Warrior';
    if (level >= 3) return 'Health Seeker';
    return 'Beginner';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final settings = ref.watch(settingsProvider);
    final progressAsync = ref.watch(userProgressProvider);
    final statsAsync = ref.watch(profileStatsProvider);
    final questsAsync = ref.watch(dailyQuestsProvider);

    final progress = progressAsync.value;
    final currentLevel = progress?.currentLevel ?? 1;
    final currentXp = progress?.currentXp ?? 0;
    final nextLevelXp = currentLevel * 500;
    final xpForNextLevel = nextLevelXp - currentXp;
    final progressPercent = currentLevel > 1 
        ? ((currentXp - ((currentLevel - 1) * 500)) / 500 * 100).clamp(0.0, 100.0)
        : (currentXp / 500 * 100).clamp(0.0, 100.0);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: CustomScrollView(
        slivers: [
          // Sticky header
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.backgroundColor(context).withValues(alpha: 0.9),
        elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.calendar_today, color: AppColors.textPrimary(context)),
              onPressed: () {
                // Show date picker for viewing logs on a specific date
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                ).then((selectedDate) {
                  if (selectedDate != null) {
                    // Navigate to tracking screen with selected date
                    if (context.mounted) {
                      Navigator.pushNamed(
                        context,
                        Routes.tracking,
                        arguments: {'selectedDate': selectedDate},
                      );
                    }
                  }
                });
              },
            ),
            title: Text(
              AppLocalizations.of(context)!.profileTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.settings, color: AppColors.textPrimary(context)),
                onPressed: () {
                  Navigator.pushNamed(context, Routes.settings);
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
                  const SizedBox(height: 16),
                  // Profile Section
            Center(
              child: Column(
                      children: [
                        Stack(
                children: [
                  CircleAvatar(
                              radius: 64,
                              backgroundColor: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkCardSecondary
                                  : AppColors.primaryGreen.withValues(alpha: 0.1),
                    backgroundImage: user?.photoURL != null && user!.photoURL!.isNotEmpty
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user?.photoURL == null || user?.photoURL?.isEmpty == true
                        ? Text(
                            user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                                      style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                                        color: AppColors.primaryGreen,
                            ),
                          )
                        : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.backgroundColor(context),
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'User',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkCardSecondary
                                : AppColors.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primaryGreen.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 16,
                                color: AppColors.primaryGreen,
                              ),
                              const SizedBox(width: 6),
                  Text(
                                'Level $currentLevel: ${_getLevelName(currentLevel)}',
                    style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Level Progress
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level Progress',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          Text(
                            '$currentXp / $nextLevelXp XP',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkSurface
                              : AppColors.borderLight(context),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Stack(
                          children: [
                            FractionallySizedBox(
                              widthFactor: progressPercent / 100.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  borderRadius: BorderRadius.circular(9999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryGreen.withValues(alpha: 0.5),
                                      blurRadius: 10,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          AppLocalizations.of(context)!.xpToNextLevel(xpForNextLevel.toString(), (currentLevel + 1).toString()),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Stats Grid
                  statsAsync.when(
                    data: (stats) {
                      final streak = stats['streak'] as int;
                      final meds = stats['meds'] as int;
                      final adherence = stats['adherence'] as double;
                      final points = stats['points'] as int;

                      return SizedBox(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildStatCard(
                              context,
                              icon: Icons.local_fire_department,
                              iconColor: AppColors.warningOrange,
                              label: AppLocalizations.of(context)!.streakLabel,
                              value: streak.toString(),
                              subtitle: AppLocalizations.of(context)!.plusOneToday,
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              context,
                              icon: Icons.medication,
                              iconColor: AppColors.infoBlue,
                              label: AppLocalizations.of(context)!.medsLabel,
                              value: meds.toString(),
                              subtitle: AppLocalizations.of(context)!.adherencePercentage(adherence.toStringAsFixed(0)),
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              context,
                              icon: Icons.stars,
                              iconColor: AppColors.warningOrange,
                              label: 'POINTS',
                              value: points >= 1000 ? '${(points / 1000).toStringAsFixed(1)}k' : points.toString(),
                              subtitle: 'Rank #42',
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 32),
                  // Daily Quests
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Quests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to tracking/history screen to view all quests
                          Navigator.pushNamed(context, Routes.tracking);
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  ),
                ],
              ),
                  const SizedBox(height: 12),
                  questsAsync.when(
                    data: (quests) {
                      if (quests.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: quests.take(3).map((quest) {
                          final isCompleted = quest.status == QuestStatus.completed;
                          return _buildQuestCard(context, quest, isCompleted);
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),
            // Settings Section
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                AppLocalizations.of(context)!.settingsTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCard
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Theme.of(context).brightness == Brightness.dark
                    ? Border.all(
                        color: AppColors.borderLight(context),
                        width: 1,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor(context),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(AppLocalizations.of(context)!.notificationsLabel),
                    subtitle: Text(AppLocalizations.of(context)!.notificationsSubtitle),
                    value: settings.notificationsEnabled,
                    activeTrackColor: AppColors.primaryGreen,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleNotifications(value);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.languageLabel),
                    subtitle: Text(settings.language == 'en' ? AppLocalizations.of(context)!.english : AppLocalizations.of(context)!.arabic),
                    trailing: AppIcons.themedIcon(context, AppIcons.chevronRight(), color: AppColors.textSecondary(context), autoMirror: true),
                    onTap: () {
                      // Toggle language for demo
                      final newLang = settings.language == 'en' ? 'ar' : 'en';
                      ref.read(settingsProvider.notifier).setLanguage(newLang);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.privacyPolicyLabel),
                    trailing: AppIcons.themedIcon(context, AppIcons.chevronRight(), color: AppColors.textSecondary(context), autoMirror: true),
                    onTap: () {
                      Navigator.pushNamed(context, Routes.privacyPolicy);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(AppLocalizations.of(context)!.darkModeLabel),
                    subtitle: Text(AppLocalizations.of(context)!.darkModeSubtitle),
                    value: settings.darkMode,
                    activeTrackColor: AppColors.primaryGreen,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleDarkMode(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Account Management
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                AppLocalizations.of(context)!.accountTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCard
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Theme.of(context).brightness == Brightness.dark
                    ? Border.all(
                        color: AppColors.borderLight(context),
                        width: 1,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor(context),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.caregiversLabel),
                    leading: const Icon(Icons.people, color: AppColors.primaryGreen),
                    trailing: AppIcons.themedIcon(context, AppIcons.chevronRight(), color: AppColors.textSecondary(context), autoMirror: true),
                    onTap: () {
                      Navigator.pushNamed(context, Routes.caregiverManagement);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.acceptInvitationLabel),
                    leading: const Icon(Icons.person_add, color: AppColors.primaryGreen),
                    trailing: AppIcons.themedIcon(context, AppIcons.chevronRight(), color: AppColors.textSecondary(context), autoMirror: true),
                    onTap: () {
                      Navigator.pushNamed(context, Routes.caregiverEnterToken);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.changePasswordLabel),
                    leading: Icon(AppIcons.lock(), color: AppColors.primaryGreen),
                    trailing: AppIcons.themedIcon(context, AppIcons.chevronRight(), color: AppColors.textSecondary(context), autoMirror: true),
                    onTap: () {
                      Navigator.pushNamed(context, Routes.changePassword);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.deleteAccountLabel, style: const TextStyle(color: AppColors.errorRed)),
                    leading: Icon(AppIcons.delete(), color: AppColors.errorRed),
                    trailing: AppIcons.themedIcon(context, AppIcons.chevronRight(), color: AppColors.textSecondary(context), autoMirror: true),
                    onTap: () {
                      Navigator.pushNamed(context, Routes.deleteAccount);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.errorRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  AppLocalizations.of(context)!.logoutLabel,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderLight(context)
              : AppColors.borderLight(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary(context),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCard(BuildContext context, QuestModel quest, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? Colors.transparent
              : (quest.status == QuestStatus.active
                  ? AppColors.primaryGreen.withValues(alpha: 0.3)
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderLight(context)
                      : AppColors.borderLight(context))),
        ),
        boxShadow: quest.status == QuestStatus.active && !isCompleted
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medication,
              color: AppColors.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary(context),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.borderMedium(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCompleted
                      ? 'Completed • +${quest.xpReward} XP'
                      : 'Pending • +${quest.xpReward} XP',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted
                        ? AppColors.textSecondary(context)
                        : AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.primaryGreen
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: isCompleted
                  ? null
                  : Border.all(
                      color: AppColors.surfaceColor(context).withValues(alpha: 0.2),
                      width: 2,
                    ),
            ),
            child: isCompleted
                ? Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.textPrimary(context),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
