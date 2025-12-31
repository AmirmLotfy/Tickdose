import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/features/reminders/providers/reminder_provider.dart';
import 'package:tickdose/core/services/remote_command_service.dart';
import 'package:tickdose/features/navigation/widgets/bottom_nav_bar.dart';
import 'package:tickdose/features/navigation/routes/route_names.dart';
import 'package:tickdose/features/medicines/providers/medicine_provider.dart';
import 'package:tickdose/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

/// Dashboard screen for caregivers to view patient's medication information
class CaregiverDashboardScreen extends ConsumerStatefulWidget {
  final String patientUserId;
  final String? patientName;

  const CaregiverDashboardScreen({
    super.key,
    required this.patientUserId,
    this.patientName,
  });

  @override
  ConsumerState<CaregiverDashboardScreen> createState() => _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends ConsumerState<CaregiverDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final remindersAsync = ref.watch(todaysRemindersProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            child: Column(
              children: [
                // Sticky Header
                _buildHeader(context),
                const SizedBox(height: 16),
                // Stats Overview
                _buildStatsOverview(context, remindersAsync),
                const SizedBox(height: 24),
                // Voice Reminder Card
                _buildVoiceReminderCard(context, remindersAsync),
                const SizedBox(height: 24),
                // Today's Schedule
                _buildScheduleTimeline(context, remindersAsync),
                const SizedBox(height: 24),
                // Quick Actions
                _buildQuickActions(context),
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
          // Floating Bottom Navigation
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: BottomNavBar(
              currentIndex: 0, // Home tab active
              onTap: (index) {
                // Navigate based on tab
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, Routes.home);
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, Routes.reminders);
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, Routes.tracking);
                } else if (index == 3) {
                  Navigator.pushReplacementNamed(context, Routes.pharmacyFinder);
                } else if (index == 4) {
                  Navigator.pushReplacementNamed(context, Routes.profile);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final patientName = widget.patientName ?? l10n.patient;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(context).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight(context),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            children: [
              // Patient Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                    backgroundImage: null, // Could load patient photo
                    child: Text(
                      patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
              ),
              const SizedBox(width: 12),
              // Patient Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$patientName's Dashboard",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Status: On Track',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryGreen.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Call Button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor(context),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.borderLight(context),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.call,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                  onPressed: () {
                    // Call patient functionality
                    _callPatient(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context, AsyncValue remindersAsync) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Adherence Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                        color: AppColors.surfaceColor(context).withValues(alpha: 0.05),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary(context).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryGreen.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  // Content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
          Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryGreen.withValues(alpha: 0.2),
                            width: 4,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Progress indicator
                            CircularProgressIndicator(
                              value: 0.8, // 80% adherence
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryGreen,
                              ),
                              backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                            ),
                            Center(
                              child: Text(
                                '80%',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.adherenceLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary(context),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Vitals Group
          Expanded(
            child: Column(
              children: [
                // BP Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.borderLight(context),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary(context).withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BP',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary(context),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '120/80',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.favorite,
                        color: AppColors.errorRed,
                        size: 24,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Heart Rate Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.borderLight(context),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary(context).withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.heartRate,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary(context),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '98 ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                                TextSpan(
                                  text: 'bpm',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.monitor_heart,
                        color: AppColors.primaryGreen,
                        size: 24,
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

  Widget _buildVoiceReminderCard(BuildContext context, AsyncValue remindersAsync) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surfaceColor(context),
              AppColors.darkCard,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderLight(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary(context).withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decoration (could add image)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: const BorderRadiusDirectional.only(
                    topEnd: Radius.circular(16),
                    bottomStart: Radius.circular(80),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                              l10n.voiceReminder,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Send a quick audio nudge to ${widget.patientName ?? 'patient'}.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.graphic_eq,
                          color: AppColors.primaryGreen,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _recordVoiceReminder(context, remindersAsync),
                          icon: const Icon(Icons.mic, size: 20),
                          label: Text(l10n.recordNudge),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: AppColors.backgroundColor(context),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            shadowColor: AppColors.primaryGreen.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderLight(context),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.history, size: 20),
                          color: AppColors.textPrimary(context),
                          onPressed: () {
                            // Show history
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Last nudge delivered 15m ago',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildScheduleTimeline(BuildContext context, AsyncValue remindersAsync) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                "Today's Schedule",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.reminders);
                },
                child: Text(
                  l10n.viewFullList,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
                    ),
                    const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(context),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                        color: AppColors.surfaceColor(context).withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: remindersAsync.when(
                      data: (reminders) {
                        if (reminders.isEmpty) {
                  return Center(
                            child: Padding(
                      padding: const EdgeInsets.all(32),
                              child: Text(
                        l10n.noRemindersToday,
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                  children: [
                    for (int i = 0; i < reminders.length; i++)
                      _buildTimelineItem(
                        context,
                        reminder: reminders[i],
                        isLast: i == reminders.length - 1,
                        ref: ref,
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(
                child: Text(
                  'Error loading schedule: $e',
                  style: TextStyle(color: AppColors.errorRed),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required reminder,
    required bool isLast,
    required WidgetRef ref,
  }) {
    // Check if medicine was taken today using FutureBuilder
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfDay = today.add(const Duration(days: 1));
    
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.patientUserId)
          .collection('logs')
          .where('medicineId', isEqualTo: reminder.medicineId)
          .where('takenAt', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
          .where('takenAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get(),
      builder: (context, snapshot) {
        final isTaken = snapshot.data?.docs.any((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'taken') ?? false;
        final isOverdue = DateTime.now().isAfter(reminder.time);
        
        return _buildTimelineItemContent(
          context,
          reminder: reminder,
          isLast: isLast,
          isTaken: isTaken,
          isOverdue: isOverdue,
        );
      },
    );
  }

  Widget _buildTimelineItemContent(
    BuildContext context, {
    required reminder,
    required bool isLast,
    required bool isTaken,
    required bool isOverdue,
  }) {
    final l10n = AppLocalizations.of(context)!;
    Color statusColor;
    IconData statusIcon;
    String statusText;
    Color textColor;

    if (isOverdue) {
      statusColor = AppColors.warningOrange;
      statusIcon = Icons.priority_high;
      statusText = l10n.overdue;
      textColor = AppColors.textPrimary(context);
    } else {
      statusColor = AppColors.textSecondary(context);
      statusIcon = Icons.circle;
      statusText = l10n.pending;
      textColor = AppColors.textSecondary(context);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isOverdue
                  ? Icon(
                      statusIcon,
                      size: 14,
                      color: statusColor,
                    )
                  : Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                color: AppColors.borderLight(context),
                margin: const EdgeInsets.only(top: 4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reminder.medicineName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                          child: Text(
                        statusText,
                            style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          color: statusColor,
                            ),
                          ),
                        ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('h:mm a', Localizations.localeOf(context).toString()).format(reminder.time)} • ${reminder.dosage}',
                              style: TextStyle(
                    fontSize: 14,
                                color: AppColors.textSecondary(context),
                  ),
                ),
              ],
                              ),
                            ),
                          ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: [
          _buildQuickActionButton(
            context,
            icon: Icons.medication,
            label: l10n.pillList,
            onTap: () {
              Navigator.pushNamed(context, Routes.medicinesList);
            },
          ),
          _buildQuickActionButton(
            context,
            icon: Icons.calendar_month,
            label: l10n.refills,
            onTap: () {
              Navigator.pushNamed(context, Routes.medicinesList);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
                        color: AppColors.surfaceColor(context).withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primaryGreen,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _callPatient(BuildContext context) async {
    try {
      // Get patient's user profile to get phone number
      final patientDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.patientUserId)
          .get();
      
      if (!patientDoc.exists) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient profile not found'),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }
      
      final patientData = patientDoc.data()!;
      final phoneNumber = patientData['phone'] as String? ?? '';
      
      if (phoneNumber.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient phone number not available'),
            backgroundColor: AppColors.warningOrange,
          ),
        );
        return;
      }
      
      final uri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot make phone call'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorWithMessage(e.toString())),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _recordVoiceReminder(
    BuildContext context,
    AsyncValue remindersAsync,
  ) async {
    try {
      final remoteService = RemoteCommandService();

      // Get first reminder for demo
      remindersAsync.whenData((reminders) {
        if (reminders.isNotEmpty) {
          final reminder = reminders.first;
          remoteService.sendCommand(
            targetUserId: widget.patientUserId,
        commandType: 'voice_reminder',
        payload: {
          'medicineName': reminder.medicineName,
          'dosage': reminder.dosage,
          'message': 'Caregiver reminder for ${reminder.medicineName}',
        },
      );
        }
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice reminder sent')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorWithMessage(e.toString()))),
        );
      }
    }
  }
}

