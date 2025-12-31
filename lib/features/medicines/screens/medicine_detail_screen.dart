import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:tickdose/core/models/medicine_model.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/features/reminders/providers/reminder_provider.dart';
import 'package:tickdose/core/models/reminder_model.dart';
import 'package:tickdose/features/tracking/providers/tracking_provider.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/core/models/medicine_log_model.dart';
import 'package:tickdose/features/medicines/screens/edit_medicine_screen.dart';
import 'package:tickdose/features/medicines/screens/log_side_effect_screen.dart';
import 'package:tickdose/features/medicines/screens/medicine_interaction_warning_screen.dart';
import 'package:tickdose/features/medicines/providers/medicine_provider.dart';
import 'package:tickdose/core/services/gemini_service.dart';
import 'package:tickdose/core/services/remote_config_service.dart';
import 'package:tickdose/features/navigation/routes/route_names.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

class MedicineDetailScreen extends ConsumerWidget {
  final MedicineModel medicine;

  const MedicineDetailScreen({super.key, required this.medicine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final remindersAsync = ref.watch(remindersStreamProvider);
    final reminder = remindersAsync.value?.firstWhere(
      (r) => r.medicineId == medicine.id,
      orElse: () => ReminderModel(
        id: '',
        medicineId: medicine.id,
        medicineName: medicine.name,
        frequency: ReminderFrequency.onceDaily,
        times: [],
        time: '08:00',
        dosage: '1 dose',
        frequency_legacy: 'daily',
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        notificationId: 0,
        enabled: false,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: Column(
        children: [
          // Sticky header
          _buildHeader(context, l10n),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Medicine image
                  _buildMedicineImage(context),
                  const SizedBox(height: 24),
                  // Medicine info
                  _buildMedicineInfo(context),
                  const SizedBox(height: 24),
                  // Action grid
                  _buildActionGrid(context, l10n, ref),
                  const SizedBox(height: 24),
                  // Next Dose card
                  if (reminder != null && reminder.times.isNotEmpty)
                    _buildNextDoseCard(context, reminder, ref),
                  const SizedBox(height: 16),
                  // Side Effect card
                  _buildSideEffectCard(context, l10n),
                  const SizedBox(height: 24),
                  // Supply Tracking
                  _buildSupplyTracking(context, l10n),
                  const SizedBox(height: 24),
                  // About section
                  _buildAboutSection(context, l10n),
                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
      // Special bottom nav with elevated Track button
      bottomNavigationBar: _buildSpecialBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight(context),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            IconButton(
                icon: const Icon(Icons.arrow_back, size: 24),
                color: AppColors.darkTextPrimary,
                onPressed: () => Navigator.pop(context),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.history, size: 24),
                    color: AppColors.darkTextPrimary,
                    onPressed: () {
                      // Show history
                    },
                  ),
            IconButton(
                    icon: const Icon(Icons.edit, size: 24),
                    color: AppColors.darkTextPrimary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditMedicineScreen(medicine: medicine),
                  ),
                );
              },
            ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineImage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
          children: [
          // Blur glow effect
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(),
            ),
          ),
          // Image
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderLight(context),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor(context),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: medicine.imageUrl != null && medicine.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: medicine.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.medication,
                          color: AppColors.primaryGreen,
                          size: 64,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.medication,
                        color: AppColors.primaryGreen,
                        size: 64,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
        children: [
          Text(
            medicine.name,
          style: TextStyle(
            fontSize: 30,
              fontWeight: FontWeight.bold,
            color: AppColors.cardColor(context),
            letterSpacing: -0.5,
            ),
          textAlign: TextAlign.center,
          ),
            const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                l10n.active,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Generic: ${medicine.genericName.isNotEmpty ? medicine.genericName : 'N/A'}',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
                        const SizedBox(height: 8),
                        Text(
          '${medicine.strength} • ${medicine.form}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.cardColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context, AppLocalizations l10n, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.description,
              iconColor: AppColors.primaryGreen,
              label: l10n.monograph,
              onTap: () => _showMonograph(context, ref, l10n),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.medication_liquid,
              iconColor: AppColors.warningOrange,
              label: l10n.interactions,
              onTap: () => _showInteractions(context, ref),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.calendar_month,
              iconColor: AppColors.infoBlue,
              label: l10n.schedule,
              onTap: () => _showSchedule(context, ref),
            ),
          ),
                  const SizedBox(width: 12),
                  Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.more_horiz,
              iconColor: AppColors.textSecondary(context),
              label: l10n.more,
              onTap: () => _showMoreOptions(context, ref, l10n),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
            Container(
            width: 56,
            height: 56,
              decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkCard
                  : AppColors.surfaceColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                    color: AppColors.borderLight(context),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor(context).withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                  ),
                ],
              ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextDoseCard(BuildContext context, ReminderModel reminder, WidgetRef ref) {
    final now = DateTime.now();
    String? nextTime;
    String? instructions = 'Take with food • ${reminder.dosage}';

    // Find next time
    for (var timeStr in reminder.times) {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

      if (scheduledTime.isAfter(now)) {
        nextTime = DateFormat('h:mm a').format(scheduledTime);
        break;
      }
    }

    if (nextTime == null && reminder.times.isNotEmpty) {
      // Next is tomorrow
      final firstTime = reminder.times[0];
      final parts = firstTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final tomorrow = DateTime(now.year, now.month, now.day + 1, hour, minute);
      nextTime = DateFormat('h:mm a').format(tomorrow);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
                    color: AppColors.borderLight(context),
            width: 1,
          ),
        ),
        child: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Stack(
              children: [
                // Blur effect
                Positioned(
                  right: -40,
                  top: -40,
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                      child: Container(),
                    ),
                  ),
                ),
                // Content
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: AppColors.primaryGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.nextDose,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary(context),
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            nextTime ?? l10n.noUpcomingDose,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkTextPrimary,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            instructions,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final user = ref.read(authStateProvider).value;
                        if (user != null) {
                          await ref.read(trackingControllerProvider.notifier).logMedicine(
                            MedicineLogModel(
                              id: '',
                              userId: user.uid,
                              medicineId: medicine.id,
                              medicineName: medicine.name,
                              takenAt: DateTime.now(),
                              status: 'taken',
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(l10n.logTaken),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: AppColors.textPrimary(context),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSideEffectCard(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.errorRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.errorRed.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Gradient overlay
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.errorRed.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Blur effect
            Positioned(
              left: -40,
              bottom: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(),
                ),
              ),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.errorRed.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              l10n.symptomCheck,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.errorRed,
                                letterSpacing: 1,
                              ),
                            ),
              ),
              const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.feelingUnwell,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Log adverse reactions or new symptoms to help AI analyze potential side effects.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary(context),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.errorRed.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: AppColors.errorRed,
                        size: 32,
                      ),
                    ),
                  ],
            ),
            const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LogSideEffectScreen(medicine: medicine),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle, size: 20),
                  label: Text(
                    AppLocalizations.of(context)!.logSideEffectButton,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorRed,
                    foregroundColor: AppColors.darkTextPrimary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildSupplyTracking(BuildContext context, AppLocalizations l10n) {
    // Placeholder values - in real app, calculate from logs
    final remaining = 14;
    final total = 30;
    final percentage = (remaining / total).clamp(0.0, 1.0);
    final daysRemaining = 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.supplyTracking,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Request refill
                },
                child: Text(
                  AppLocalizations.of(context)!.requestRefill,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderLight(context),
                width: 1,
              ),
            ),
            child: Column(
                children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.primaryGreen.withValues(alpha: 0.15)
                                : AppColors.borderLight(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.medication,
                            color: AppColors.textSecondary(context),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.remaining,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkTextPrimary,
                    ),
                  ),
                ],
              ),
                    Text(
                      '$remaining / $total pills',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
            Container(
                  height: 10,
              decoration: BoxDecoration(
                    color: AppColors.darkBackground,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: percentage,
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
                ),
                const SizedBox(height: 12),
                Row(
                children: [
                    Icon(
                      Icons.warning,
                      color: AppColors.warningOrange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        'Refill recommended soon. Supply will last approx. $daysRemaining days.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.aboutThisDrug,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.cardColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderLight(context),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.notes.isNotEmpty
                      ? medicine.notes
                      : '${medicine.name} is a medication used to treat various conditions. Please consult your healthcare provider for complete information.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary(context),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    // Show full monograph
                  },
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.primaryGreen,
                  ),
                  label: Text(
                    l10n.readFullMonograph,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialBottomNav(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.borderLight(context),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home, l10n.home, isActive: false),
              _buildNavItem(context, Icons.notifications, l10n.reminders, isActive: false),
              // Elevated center button
              Container(
                margin: const EdgeInsets.only(bottom: 32),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.textPrimary(context),
                  size: 28,
                ),
              ),
              _buildNavItem(context, Icons.local_pharmacy, l10n.pharmacy, isActive: false),
              _buildNavItem(context, Icons.person, l10n.profile, isActive: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, {required bool isActive}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? AppColors.primaryGreen : AppColors.textSecondary(context),
          size: 26,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.darkTextPrimary : AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  void _showMonograph(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    try {
      // Get API key from Remote Config
      final apiKey = RemoteConfigService().getGeminiApiKey();
      if (apiKey.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.apiKeyNotConfigured),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }

      // Show loading dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Get medicine details from Gemini
      final geminiService = GeminiService();
      final details = await geminiService.getMedicineDetails(
        medicine.name,
        apiKey: apiKey,
        language: Localizations.localeOf(context).languageCode,
      );

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show monograph in dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.monographTitle(medicine.name)),
          content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
            children: [
                if (details['generic_name'] != null && details['generic_name'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '${l10n.genericNameLabel} ${details['generic_name']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                if (details['manufacturer'] != null && details['manufacturer'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '${l10n.manufacturerLabel} ${details['manufacturer']}',
                      style: TextStyle(color: AppColors.textSecondary(context)),
                    ),
                  ),
                if (details['side_effects'] != null && (details['side_effects'] as List).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                          'Common Side Effects:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...(details['side_effects'] as List).map((effect) => Padding(
                          padding: const EdgeInsets.only(left: 8, top: 2),
                          child: Text(
                            '• $effect',
                            style: TextStyle(color: AppColors.textSecondary(context)),
                              ),
                            )),
                    ],
                  ),
                ),
                if (details.isEmpty)
              Text(
                    'No additional information available.',
                    style: TextStyle(color: AppColors.textSecondary(context)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog if open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorLabel('Failed to load monograph: $e')),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _showInteractions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final medicinesAsync = ref.read(medicinesStreamProvider);
    medicinesAsync.when(
      data: (medicines) {
        // Filter out current medicine
        final otherMedicines = medicines.where((m) => m.id != medicine.id).toList();
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MedicineInteractionWarningScreen(
              medicine: medicine,
              existingMedicines: otherMedicines,
            ),
          ),
        );
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.loadingMedicines)),
        );
      },
      error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorLabel(e.toString())),
            backgroundColor: AppColors.errorRed,
          ),
        );
      },
    );
  }

  void _showSchedule(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final remindersAsync = ref.read(remindersStreamProvider);
    remindersAsync.when(
      data: (reminders) {
        final reminder = reminders.firstWhere(
          (r) => r.medicineId == medicine.id,
          orElse: () => ReminderModel(
            id: '',
            medicineId: medicine.id,
            medicineName: medicine.name,
            frequency: ReminderFrequency.onceDaily,
            times: [],
            time: '08:00',
            dosage: '1 dose',
            frequency_legacy: 'daily',
            daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
            notificationId: 0,
            enabled: false,
          ),
        );

        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => Container(
            padding: const EdgeInsets.all(24),
      child: Column(
              mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                Text(
                  l10n.reminderSchedule,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 16),
                if (reminder.times.isEmpty)
                  Text(
                    'No reminders set for this medicine.',
                    style: TextStyle(color: AppColors.textSecondary(context)),
                  )
                else
                  ...reminder.times.map((time) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
            children: [
                        Icon(Icons.access_time, color: AppColors.primaryGreen, size: 20),
                        const SizedBox(width: 12),
              Text(
                          time,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary(context),
                ),
              ),
                        const Spacer(),
                        if (reminder.enabled)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                child: Text(
                              l10n.active,
                  style: TextStyle(
                                fontSize: 12,
                                color: AppColors.successGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary(context).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n.inactive,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                ),
              )),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.close),
                    ),
                    if (reminder.times.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            Routes.editReminder,
                            arguments: reminder,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                        ),
                        child: Text(l10n.editSchedule),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.loadingSchedule)),
        );
      },
      error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorLabel(e.toString())),
            backgroundColor: AppColors.errorRed,
          ),
        );
      },
    );
  }

  void _showMoreOptions(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.primaryGreen),
              title: Text(l10n.editMedicine),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  Routes.editMedicine,
                  arguments: medicine,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: AppColors.infoBlue),
              title: Text(l10n.shareMedicine),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final shareText = '${medicine.name} - ${medicine.strength} ${medicine.form}\n${medicine.genericName.isNotEmpty ? 'Generic: ${medicine.genericName}\n' : ''}Dosage: ${medicine.dosage}\nFrequency: ${medicine.frequency}';
                  await Clipboard.setData(ClipboardData(text: shareText));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.shareMedicine}: ${l10n.medicineNameLabel} copied to clipboard')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.errorFailedToShare(e))),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.errorRed),
              title: Text(l10n.deleteMedicineTitle),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, ref, l10n);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.close, color: AppColors.textSecondary(context)),
              title: Text(l10n.dialogCancel),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMedicineQuestion),
        content: Text(l10n.deleteMedicineContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                await ref.read(medicineControllerProvider.notifier).deleteMedicine(medicine.id);
                if (!context.mounted) return;
                Navigator.pop(context); // Go back to medicines list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${medicine.name} deleted'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.failedToDelete(e)),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
