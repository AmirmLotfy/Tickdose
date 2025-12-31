import 'package:flutter/material.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/core/utils/adherence_calculator.dart';
import 'package:tickdose/core/widgets/glassmorphic_container.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/features/tracking/services/tracking_service.dart';
import 'animated_stat_ring.dart';

final monthlyStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return {'taken': 0, 'missed': 0, 'skipped': 0};
  
  final service = TrackingService();
  return await service.getMonthlyStats(user.uid, DateTime.now());
});

final streakProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return 0;
  
  final service = TrackingService();
  return await service.getStreak(user.uid);
});

class QuickStats extends ConsumerWidget {
  const QuickStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyStatsAsync = ref.watch(monthlyStatsProvider);
    final streakAsync = ref.watch(streakProvider);

    return GlassmorphicContainer(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      blur: 12,
      opacity: 0.75,
      child: Row(
        children: [
          Expanded(
            child: monthlyStatsAsync.when(
              data: (stats) {
                final total = stats['taken']! + stats['missed']! + stats['skipped']!;
                final adherence = AdherenceCalculator.calculateAdherence(stats['taken']!, total);
                final adherenceNormalized = adherence / 100.0;
                
                return _buildStatItem(
                  context: context,
                  label: AppLocalizations.of(context)!.adherenceLabel,
                  value: '${adherence.toStringAsFixed(0)}%',
                  icon: AppIcons.trendingUp(),
                  color: adherence >= 75 ? AppColors.primaryGreen : AppColors.errorRed,
                  progress: adherenceNormalized,
                );
              },
              loading: () => _buildStatItem(
                context: context,
                label: AppLocalizations.of(context)!.adherenceLabel,
                value: '--',
                icon: AppIcons.trendingUp(),
                color: AppColors.primaryGreen,
                progress: 0.0,
              ),
              error: (_, __) => _buildStatItem(
                context: context,
                label: AppLocalizations.of(context)!.adherenceLabel,
                value: '0%',
                icon: AppIcons.trendingUp(),
                color: AppColors.textSecondary(context),
                progress: 0.0,
              ),
            ),
          ),
          Container(
            width: 1.5,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.borderLight(context).withValues(alpha: 0.0),
                  AppColors.borderLight(context),
                  AppColors.borderLight(context).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          Expanded(
            child: streakAsync.when(
              data: (streak) => _buildStatItem(
                context: context,
                label: AppLocalizations.of(context)!.streakLabel,
                value: AppLocalizations.of(context)!.streakDays(streak),
                icon: AppIcons.flame(),
                color: AppColors.accentOrange,
                progress: (streak / 30.0).clamp(0.0, 1.0), // Normalize to 30-day max
              ),
              loading: () => _buildStatItem(
                context: context,
                label: AppLocalizations.of(context)!.streakLabel,
                value: '--',
                icon: AppIcons.flame(),
                color: AppColors.accentOrange,
                progress: 0.0,
              ),
              error: (_, __) => _buildStatItem(
                context: context,
                label: AppLocalizations.of(context)!.streakLabel,
                value: '0',
                icon: AppIcons.flame(),
                color: AppColors.textSecondary(context),
                progress: 0.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required double progress,
  }) {
    return Column(
      children: [
        // Animated ring with icon
        AnimatedStatRing(
          progress: progress,
          color: color,
          strokeWidth: 3.5,
          size: 72,
          child: Icon(
            icon,
            color: color,
            size: 32,
          ),
        ),
        const SizedBox(height: 12),
        // Value with enhanced typography
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary(context),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
