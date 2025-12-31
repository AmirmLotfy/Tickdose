import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/icons/app_icons.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/ai_assistant_banner.dart';
import '../widgets/daily_adherence_stats.dart';
import '../widgets/medication_timeline.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE').format(now);
    final dateStr = DateFormat('MMM d').format(now);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Consumer(
                        builder: (context, ref, child) {
                          final authState = ref.watch(authStateProvider);
                          final user = authState.value;
                          final photoURL = user?.photoURL;
                          
                          return Stack(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.borderLight(context),
                                backgroundImage: photoURL != null && photoURL.isNotEmpty
                                    ? NetworkImage(photoURL)
                                    : null,
                                child: photoURL == null || photoURL.isEmpty
                                    ? Icon(
                                        AppIcons.person(),
                                        color: AppColors.textSecondary(context),
                                        size: 20,
                                      )
                                    : null,
                              ),
                              // Green status dot
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.backgroundColor(context),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Consumer(
                        builder: (context, ref, child) {
                          final authState = ref.watch(authStateProvider);
                          final user = authState.value;
                          final displayName = user?.displayName?.split(' ').first ?? 'User';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_getGreeting(),',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary(context),
                                  height: 1.2,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  // Notification button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSurface
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.notifications,
                            size: 24,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        // Red dot indicator
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red.shade500,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkSurface
                                    : Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Date Section
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(text: '$dayName, '),
                    TextSpan(
                      text: dateStr,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // AI Assistant Banner
              const AIAssistantBanner(),
              const SizedBox(height: 24),
              // Daily Adherence Stats
              const DailyAdherenceStats(),
              const SizedBox(height: 32),
              // Medication Timeline
              const MedicationTimeline(),
              const SizedBox(height: 100), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }
}
