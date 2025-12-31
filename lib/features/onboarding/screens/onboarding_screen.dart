import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

import '../../../core/theme/app_theme.dart';
import 'timezone_screen.dart';
import 'routine_setup_screen.dart';
import 'health_profile_screen.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/services/permission_service.dart';
import '../../../features/navigation/routes/route_names.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<String, dynamic> _setupData = {};

  // Removed static list definition to move inside build or use a getter


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      {
        'title': l10n.onboardingTitle1,
        'description': l10n.onboardingDesc1,
        'image': 'assets/images/onboarding_1.png',
      },
      {
        'title': l10n.onboardingTitle2,
        'description': l10n.onboardingDesc2,
        'image': 'assets/images/onboarding_2.png',
      },
      {
        'title': l10n.onboardingTitle3,
        'description': l10n.onboardingDesc3,
        'image': 'assets/images/onboarding_3.png',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () {
                    // Skip onboarding and go directly to setup flow
                    _navigateThroughSetup(context);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.skip,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            // Carousel with snap scrolling
            Expanded(
              child: Stack(
                children: [
                  // Fade overlays on edges
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.backgroundColor(context),
                            AppColors.backgroundColor(context).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            AppColors.backgroundColor(context),
                            AppColors.backgroundColor(context).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // PageView with snap scrolling
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Image container with gradient overlay and icon
                              AspectRatio(
                                aspectRatio: 1.0,
                                child: Container(
                                  width: double.infinity,
                                  constraints: const BoxConstraints(maxHeight: 360),
                                  decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.primaryGreen.withValues(alpha: 0.2),
                                      Colors.transparent,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Background image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        pages[index]['image']!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        opacity: const AlwaysStoppedAnimation(0.6),
                                      ),
                                    ),
                                    // Material icon overlay
                                    Center(
                                      child: Icon(
                                        index == 0
                                            ? Icons.medication
                                            : index == 1
                                                ? Icons.favorite
                                                : Icons.psychology,
                                        size: 80,
                                        color: AppColors.primaryGreen,
                                        shadows: [
                                          Shadow(
                                            color: AppColors.primaryGreen.withValues(alpha: 0.5),
                                            blurRadius: 15,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                              const SizedBox(height: 32),
                              Text(
                                pages[index]['title']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary(context),
                                  height: 1.2,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                pages[index]['description']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary(context),
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Footer with indicators and button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        height: 8,
                        width: _currentPage == index ? 32 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primaryGreen
                              : AppColors.borderLight(context),
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: _currentPage == index
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.6),
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Next/Get Started Button (rounded-full)
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_currentPage < pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          // Navigate through setup screens
                          await _navigateThroughSetup(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: AppColors.darkBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == pages.length - 1
                                ? l10n.getStarted
                                : l10n.next,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}

  Future<void> _navigateThroughSetup(BuildContext context) async {
    // Request notification and alarm permissions
    await PermissionService().requestReminderPermissions();
    if (!context.mounted) return;

    // Step 1: Timezone setup
    final timezoneResult = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const TimezoneScreen(
          currentStep: 1,
          totalSteps: 3,
        ),
      ),
    );
    
    if (timezoneResult != null) {
      _setupData['timezone'] = timezoneResult['timezone'];
      _setupData['timezoneAutoDetect'] = timezoneResult['autoDetect'];
    }

    if (!context.mounted) return;

    // Step 2: Routine setup
    final routineResult = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const RoutineSetupScreen(
          currentStep: 2,
          totalSteps: 3,
        ),
      ),
    );
    
    if (routineResult != null) {
      // Map 'bedtime' to 'sleepTime' for UserModel compatibility
      if (routineResult.containsKey('bedtime')) {
        _setupData['sleepTime'] = routineResult['bedtime'];
      }
      if (routineResult.containsKey('wakeTime')) {
        _setupData['wakeTime'] = routineResult['wakeTime'];
      }
      // Set default meal times if not provided
      // These can be customized later in settings
      _setupData['breakfastTime'] = routineResult['breakfastTime'] ?? '08:00';
      _setupData['lunchTime'] = routineResult['lunchTime'] ?? '13:00';
      _setupData['dinnerTime'] = routineResult['dinnerTime'] ?? '19:00';
    }

    if (!context.mounted) return;

    // Step 3: Health profile (optional)
    final healthResult = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const HealthProfileScreen(
          currentStep: 3,
          totalSteps: 3,
        ),
      ),
    );
    
    if (healthResult != null) {
      _setupData.addAll(healthResult);
    }

    if (!context.mounted) return;

    // Save setup data to user profile (if user is logged in)
    final userAsync = ref.read(authStateProvider);
    if (userAsync.value != null) {
      final userProfileAsync = ref.read(userProfileProvider);
      final userProfile = userProfileAsync.value;
      
      if (userProfile != null) {
        // Update user profile with setup data
        final updatedUser = userProfile.copyWith(
          timezone: _setupData['timezone'] ?? userProfile.timezone,
          timezoneAutoDetect: _setupData['timezoneAutoDetect'] ?? userProfile.timezoneAutoDetect,
          breakfastTime: _setupData['breakfastTime'] ?? userProfile.breakfastTime,
          lunchTime: _setupData['lunchTime'] ?? userProfile.lunchTime,
          dinnerTime: _setupData['dinnerTime'] ?? userProfile.dinnerTime,
          sleepTime: _setupData['sleepTime'] ?? userProfile.sleepTime,
          wakeTime: _setupData['wakeTime'] ?? userProfile.wakeTime,
          age: _setupData['age'] ?? userProfile.age,
          gender: _setupData['gender'] ?? userProfile.gender,
          weight: _setupData['weight'] ?? userProfile.weight,
          height: _setupData['height'] ?? userProfile.height,
          healthConditions: _setupData['healthConditions'] ?? userProfile.healthConditions,
          allergies: _setupData['allergies'] ?? userProfile.allergies,
        );
        
        await ref.read(profileControllerProvider.notifier).updateProfile(updatedUser);
      }
    }

    // Navigate to Register/Login
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }
}

// Extension to fix the width issue since AuthButton is double.infinity
extension WidgetExt on Widget {
  Widget width(double width) {
    return SizedBox(width: width, child: this);
  }
}
