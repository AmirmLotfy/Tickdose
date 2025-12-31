import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/features/tracking/widgets/circular_progress_card.dart';
import 'package:tickdose/features/tracking/widgets/view_toggle.dart';
import 'package:tickdose/features/tracking/widgets/redesigned_calendar_widget.dart';
import 'package:tickdose/features/tracking/widgets/redesigned_history_list.dart';
import 'package:tickdose/features/tracking/providers/tracking_provider.dart';
import 'package:tickdose/features/tracking/services/tracking_service.dart';
import 'package:tickdose/features/tracking/services/pdf_service.dart';
import 'package:tickdose/core/utils/adherence_calculator.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';

// Provider for tracking stats
final trackingStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return {
      'adherence': 0.0,
      'streak': 0,
      'missed': 0,
      'taken': 0,
      'total': 0,
    };
  }

  final service = TrackingService();
  final now = DateTime.now();
  final monthlyStats = await service.getMonthlyStats(user.uid, now);
  final streak = await service.getStreak(user.uid);

  final taken = monthlyStats['taken'] ?? 0;
  final missed = monthlyStats['missed'] ?? 0;
  final skipped = monthlyStats['skipped'] ?? 0;
  final total = taken + missed + skipped;

  final adherence = total > 0
      ? AdherenceCalculator.calculateAdherence(taken, total)
      : 0.0;

  return {
    'adherence': adherence,
    'streak': streak,
    'missed': missed,
    'taken': taken,
    'total': total,
  };
});

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  String _selectedView = 'Monthly';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(trackingStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: Column(
        children: [
          // Sticky header
          _buildHeader(context, l10n),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // View toggle
                  ViewToggle(
                    selectedView: _selectedView,
                    onChanged: (view) => setState(() => _selectedView = view),
                  ),
                  const SizedBox(height: 16),
                  // Stats overview
                  statsAsync.when(
                    data: (stats) => _buildStatsOverview(context, stats),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => FutureErrorWidget(
                      error: e,
                      onRetry: () => ref.invalidate(trackingStatsProvider),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Calendar
                  const RedesignedCalendarWidget(),
                  const SizedBox(height: 24),
                  // Recent Activity
                  Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const RedesignedHistoryList(),
                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight(context).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.trackingTitle,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your medication adherence',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Export Report button - modern icon button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderLight(context),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.download_outlined,
                    color: AppColors.textPrimary(context),
                    size: 22,
                  ),
                  onPressed: () async {
                    try {
                      final logsAsync = await ref.read(logsForCurrentMonthProvider.future);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.generatingPdfMessage(
                              DateFormat('MMMM').format(DateTime.now()),
                            )),
                          ),
                        );
                      }
                      
                      await PdfService().generateAndShareReport(logsAsync);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.pdfGeneratedSuccess('PDF')),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.pdfGenerationError(e)),
                            backgroundColor: AppColors.errorRed,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context, Map<String, dynamic> stats) {
    final adherence = stats['adherence'] as double? ?? 0.0;
    final streak = stats['streak'] as int? ?? 0;
    final missed = stats['missed'] as int? ?? 0;
    final encouragement = AdherenceCalculator.getAdherenceStatus(adherence);

    return Column(
      children: [
        // Circular progress and small stats
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CircularProgressCard(
                adherenceScore: adherence,
                encouragementText: encouragement,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _buildSmallStatCard(
                    context,
                    icon: Icons.local_fire_department,
                    iconColor: AppColors.warningOrange,
                    label: 'Current Streak',
                    value: '$streak Days',
                  ),
                  const SizedBox(height: 16),
                  _buildSmallStatCard(
                    context,
                    icon: Icons.event_busy,
                    iconColor: AppColors.errorRed,
                    label: 'Missed Doses',
                    value: missed.toString(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 1),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
