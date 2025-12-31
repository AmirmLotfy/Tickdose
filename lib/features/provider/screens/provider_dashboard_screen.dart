import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tickdose/core/services/provider_analytics_service.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/core/utils/export_service.dart';
import 'package:tickdose/core/widgets/standard_error_widget.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

class ProviderDashboardScreen extends ConsumerStatefulWidget {
  final String? patientUserId; // If null, show list of patients

  const ProviderDashboardScreen({
    super.key,
    this.patientUserId,
  });

  @override
  ConsumerState<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends ConsumerState<ProviderDashboardScreen> {
  DateTime _selectedStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _selectedEndDate = DateTime.now();
  PatientAnalytics? _analytics;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.patientUserId != null) {
      _loadAnalytics();
    }
  }

  Future<void> _loadAnalytics() async {
    if (widget.patientUserId == null) return;

    setState(() => _isLoading = true);
    try {
      final analytics = await ProviderAnalyticsService().getPatientAnalytics(
        userId: widget.patientUserId!,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
      );
      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_analytics != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _exportData,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _analytics == null
              ? _buildPatientList()
              : _buildAnalyticsView(),
    );
  }

  Widget _buildPatientList() {
    final currentUser = ref.watch(authStateProvider).value;
    if (currentUser == null) {
      return const Center(
        child: Text('Please log in to view patients'),
      );
    }

    // Query patients who have this provider as their caregiver
    // In a real implementation, you'd have a provider-patient relationship collection
    // For now, we'll query caregivers collection to find patients linked to this provider
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('caregivers')
          .where('caregiverUserId', isEqualTo: currentUser.uid)
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return StandardErrorWidget(
            errorMessage: snapshot.error.toString(),
            onRetry: () {
              // Retry by invalidating the stream
            },
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppColors.textSecondary(context),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.noPatientsFound,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.patientsWillAppearHere,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          );
        }

        final caregiverDocs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: caregiverDocs.length,
          itemBuilder: (context, index) {
            final caregiverData = caregiverDocs[index].data() as Map<String, dynamic>;
            final patientUserId = caregiverData['userId'] as String?;
            final patientName = caregiverData['caregiverName'] as String? ?? 'Unknown Patient';
            final relationship = caregiverData['relationship'] as String?;

            if (patientUserId == null) {
              return const SizedBox.shrink();
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primaryBlue,
                  ),
                ),
                title: Text(
                  patientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: relationship != null
                    ? Text(relationship)
                    : null,
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary(context),
                ),
                onTap: () {
                  // Navigate to provider dashboard for this patient
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProviderDashboardScreen(
                        patientUserId: patientUserId,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnalyticsView() {
    final analytics = _analytics!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Date range selector
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(DateFormat('MMM dd').format(_selectedStartDate)),
                      onPressed: () => _selectDate(true),
                    ),
                    const Text('to'),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(DateFormat('MMM dd').format(_selectedEndDate)),
                      onPressed: () => _selectDate(false),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _loadAnalytics,
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Adherence overview
        _buildAdherenceCard(analytics),

        const SizedBox(height: 16),

        // Side effect correlations
        _buildSideEffectCorrelationsCard(analytics),

        const SizedBox(height: 16),

        // Effectiveness metrics
        _buildEffectivenessCard(analytics),

        const SizedBox(height: 16),

        // Trends chart
        _buildTrendsCard(analytics),

        const SizedBox(height: 16),

        // Time of day patterns
        _buildTimeOfDayCard(analytics),
      ],
    );
  }

  Widget _buildAdherenceCard(PatientAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adherence Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Overall Rate',
                    '${analytics.adherenceRate.toStringAsFixed(1)}%',
                    AppColors.primaryBlue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Taken',
                    '${analytics.takenDoses}',
                    AppColors.successGreen,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Skipped',
                    '${analytics.skippedDoses}',
                    AppColors.errorRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSideEffectCorrelationsCard(PatientAnalytics analytics) {
    if (analytics.sideEffectCorrelations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No side effect correlations found',
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Side Effect Correlations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...analytics.sideEffectCorrelations.values.map((correlation) {
              return ListTile(
                title: Text(correlation.medicineName),
                subtitle: Text(
                  '${correlation.sideEffectType} - ${correlation.correlationStrength} correlation',
                ),
                trailing: Chip(
                  label: Text('${correlation.adherenceRate.toStringAsFixed(0)}%'),
                  backgroundColor: correlation.adherenceRate >= 80
                      ? AppColors.successGreen.withValues(alpha: 0.2)
                      : AppColors.errorRed.withValues(alpha: 0.2),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectivenessCard(PatientAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medication Effectiveness',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...analytics.effectivenessMetrics.values.map((metric) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: metric.effectivenessScore >= 70
                    ? AppColors.successGreen.withValues(alpha: 0.1)
                    : AppColors.warningOrange.withValues(alpha: 0.1),
                child: ListTile(
                  title: Text(metric.medicineName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Effectiveness: ${metric.effectivenessScore.toStringAsFixed(1)}/100'),
                      Text('Adherence: ${metric.adherenceRate.toStringAsFixed(1)}%'),
                      Text('Side Effects: ${metric.sideEffectCount}'),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsCard(PatientAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adherence Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildTrendsChart(analytics.trends),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsChart(List<TrendDataPoint> trends) {
    if (trends.isEmpty) {
      return Center(
        child: Text(
          'No trend data available',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
      );
    }

    // Simple bar chart representation
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: trends.length,
      itemBuilder: (context, index) {
        final point = trends[index];
        final height = (point.adherenceRate / 100) * 150;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 20,
                height: height,
                decoration: BoxDecoration(
                  color: point.adherenceRate >= 80
                      ? AppColors.successGreen
                      : point.adherenceRate >= 60
                          ? AppColors.warningOrange
                          : AppColors.errorRed,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('M/d').format(point.date),
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeOfDayCard(PatientAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time of Day Patterns',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...analytics.timeOfDayPatterns.values.map((pattern) {
              return ListTile(
                title: Text('Most common: ${pattern.mostCommonTime}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: pattern.distribution.entries.map((entry) {
                    return Text('${entry.key}: ${entry.value.toStringAsFixed(1)}%');
                  }).toList(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _selectedStartDate : _selectedEndDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = date;
        } else {
          _selectedEndDate = date;
        }
      });
      _loadAnalytics();
    }
  }

  Future<void> _exportData() async {
    if (_analytics == null) return;

    try {
      final exportData = await ProviderAnalyticsService().exportForDoctorVisit(
        userId: widget.patientUserId!,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
      );

      // Use export service to generate PDF/CSV
      final exported = await ExportService().exportAnalytics(exportData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analytics exported to: $exported'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e')),
        );
      }
    }
  }
}
