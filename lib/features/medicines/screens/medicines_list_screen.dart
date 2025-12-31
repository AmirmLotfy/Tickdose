import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/features/medicines/providers/medicine_provider.dart';
import 'package:tickdose/core/models/medicine_model.dart';
import 'package:tickdose/features/reminders/providers/reminder_provider.dart';
import 'package:tickdose/core/models/reminder_model.dart';

class MedicinesListScreen extends ConsumerStatefulWidget {
  const MedicinesListScreen({super.key});

  @override
  ConsumerState<MedicinesListScreen> createState() => _MedicinesListScreenState();
}

class _MedicinesListScreenState extends ConsumerState<MedicinesListScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final medicinesAsync = ref.watch(medicinesStreamProvider);
    final remindersAsync = ref.watch(remindersStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: Column(
        children: [
          // Sticky header
          _buildHeader(context, l10n),
          // Content
          Expanded(
            child: medicinesAsync.when(
              data: (medicines) {
                final reminders = remindersAsync.value ?? [];
                
                // Filter medicines
                final filteredMedicines = _filterMedicines(medicines);
                
                // Separate scheduled and PRN
                final scheduled = filteredMedicines.where((m) => !_isPRN(m)).toList();
                final prn = filteredMedicines.where((m) => _isPRN(m)).toList();

                if (filteredMedicines.isEmpty) {
                  return _buildEmptyState(context, l10n);
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search bar
                      _buildSearchBar(context, l10n),
                      const SizedBox(height: 20),
                      // Filter chips
                      _buildFilterChips(context),
                      const SizedBox(height: 24),
                      // Scheduled section
                      if (scheduled.isNotEmpty) ...[
                        _buildSectionHeader(context, 'SCHEDULED', l10n),
                        const SizedBox(height: 8),
                        ...scheduled.map((medicine) => _buildMedicineCard(
                          context,
                          medicine,
                          reminders,
                          isPRN: false,
                        )),
                        const SizedBox(height: 8),
                      ],
                      // As Needed section
                      if (prn.isNotEmpty) ...[
                        _buildSectionHeader(context, 'AS NEEDED', l10n),
                        const SizedBox(height: 8),
                        ...prn.map((medicine) => _buildMedicineCard(
                          context,
                          medicine,
                          reminders,
                          isPRN: true,
                        )),
                      ],
                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text(
                  l10n.errorLabel(err),
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                      'My',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                  Text(
                      'Medications',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Floating add button
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/medicines/add'),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.darkBackground,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
              ),
            );
          }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFocused = FocusScope.of(context).focusedChild != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused
              ? AppColors.primaryGreen.withValues(alpha: 0.5)
              : AppColors.borderLight(context),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(
              Icons.search,
              color: isFocused
                  ? AppColors.primaryGreen
                  : AppColors.textSecondary(context),
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(color: AppColors.textPrimary(context)),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchMedicinesHint,
                hintStyle: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.tune,
              color: AppColors.textSecondary(context),
              size: 20,
            ),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = ['All', 'Active', 'PRN', 'History'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.surfaceColor(context),
                  borderRadius: BorderRadius.circular(9999),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: AppColors.borderLight(context),
                          width: 1,
                        ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.2),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.darkBackground
                        : AppColors.textSecondary(context),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary(context),
            letterSpacing: 1.2,
          ),
        ),
        if (title == 'SCHEDULED')
          TextButton(
        onPressed: () {
              // Edit list
            },
            child: Text(
              'Edit List',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMedicineCard(
    BuildContext context,
    MedicineModel medicine,
    List<ReminderModel> reminders, {
    required bool isPRN,
  }) {
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

    // Get next time
    String? nextTime;
    String? timeLabel;
    if (!isPRN && reminder.times.isNotEmpty) {
      final now = DateTime.now();
      
      // Find next time today or tomorrow
      for (var timeStr in reminder.times) {
        final parts = timeStr.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
        
        if (scheduledTime.isAfter(now)) {
          nextTime = DateFormat('h:mm a').format(scheduledTime);
          timeLabel = 'Upcoming';
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
        timeLabel = 'Tomorrow';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isPRN
                  ? AppColors.borderLight(context)
                  : AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getMedicineIcon(medicine.form),
              color: isPRN
                  ? AppColors.textSecondary(context)
                  : AppColors.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Medicine info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      medicine.strength,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary(context),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      isPRN ? 'PRN' : medicine.frequency,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Time badge or add button
          if (isPRN)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                Icons.add,
                color: AppColors.textPrimary(context),
                size: 20,
              ),
            )
          else if (nextTime != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    nextTime,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeLabel ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  IconData _getMedicineIcon(String form) {
    switch (form.toLowerCase()) {
      case 'liquid':
        return Icons.medication_liquid;
      case 'injection':
        return Icons.vaccines;
      case 'drops':
        return Icons.water_drop;
      default:
        return Icons.medication;
    }
  }

  bool _isPRN(MedicineModel medicine) {
    return medicine.frequency.toLowerCase().contains('prn') ||
        medicine.frequency.toLowerCase().contains('as needed');
  }

  List<MedicineModel> _filterMedicines(List<MedicineModel> medicines) {
    var filtered = medicines;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((m) {
        return m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            m.genericName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Category filter
    if (_selectedFilter == 'Active') {
      filtered = filtered.where((m) => !_isPRN(m)).toList();
    } else if (_selectedFilter == 'PRN') {
      filtered = filtered.where((m) => _isPRN(m)).toList();
    } else if (_selectedFilter == 'History') {
      // Filter expired or inactive medicines
      filtered = filtered.where((m) => m.isExpired).toList();
    }

    return filtered;
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.medicine(),
            size: 64,
            color: AppColors.textTertiary(context),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noMedicinesAdded,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
