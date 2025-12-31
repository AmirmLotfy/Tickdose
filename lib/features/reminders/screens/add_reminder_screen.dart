import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:tickdose/core/models/reminder_model.dart';
import 'package:tickdose/core/models/user_model.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/core/utils/reminder_helpers.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/features/medicines/providers/medicine_provider.dart';
import 'package:tickdose/features/reminders/providers/reminder_provider.dart';
import 'package:tickdose/features/reminders/widgets/frequency_card.dart';
import 'package:tickdose/features/profile/providers/profile_provider.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

class AddReminderScreen extends ConsumerStatefulWidget {
  const AddReminderScreen({super.key});

  @override
  ConsumerState<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends ConsumerState<AddReminderScreen> {
  String? _selectedMedicineId;
  String? _selectedMedicineName;
  String? _selectedMedicineImageUrl; // Capture image URL
  ReminderFrequency? _selectedFrequency;
  List<TimeOfDay> _selectedTimes = [];
  final List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7]; // Default all days
  
  // Meal-based reminder fields
  final Set<String> _selectedMeals = {}; // 'breakfast', 'lunch', 'dinner', 'bedtime'
  MealTiming _selectedMealTiming = MealTiming.withMeals;
  bool _isTimezoneAware = true;
  int _flexibilityWindow = 0; // -30 to +60 minutes

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final medicinesAsync = ref.watch(medicinesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.addReminder,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Select Medicine
            const Text(
              'Select Medicine',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            medicinesAsync.when(
              data: (medicines) {
                if (medicines.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warningOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warningOrange.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(AppIcons.info(), color: AppColors.warningOrange),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('No medicines found. Please add a medicine first.'),
                        ),
                      ],
                    ),
                  );
                }
                return DropdownButtonFormField<String>(
                  initialValue: _selectedMedicineId,
                  hint: const Text('Choose a medicine'),
                  items: medicines.map((m) {
                    return DropdownMenuItem(
                      value: m.id,
                      child: Row(
                        children: [
                          // Medicine image thumbnail
                          if (m.imageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                m.imageUrl!,
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) {
                                  return Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(AppIcons.medicine(), size: 16),
                                  );
                                },
                              ),
                            )
                          else
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primaryTeal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.medication, size: 16),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  m.name,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${m.strength} • ${m.form}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          _selectedMedicineName = m.name;
                          _selectedMedicineImageUrl = m.imageUrl; // Capture image
                        });
                      },
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedMedicineId = val;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
            ),
            
            if (_selectedMedicineId != null) ...[
              const SizedBox(height: 32),
              
              // Step 2: Choose Frequency
              const Text(
                'How often?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Select how frequently you need to take this medicine',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 16),
              
              // Frequency Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  FrequencyCard(
                    frequency: ReminderFrequency.onceDaily,
                    isSelected: _selectedFrequency == ReminderFrequency.onceDaily,
                    onTap: () => _selectFrequency(ReminderFrequency.onceDaily),
                  ),
                  FrequencyCard(
                    frequency: ReminderFrequency.twiceDaily,
                    isSelected: _selectedFrequency == ReminderFrequency.twiceDaily,
                    onTap: () => _selectFrequency(ReminderFrequency.twiceDaily),
                  ),
                  FrequencyCard(
                    frequency: ReminderFrequency.threeTimes,
                    isSelected: _selectedFrequency == ReminderFrequency.threeTimes,
                    onTap: () => _selectFrequency(ReminderFrequency.threeTimes),
                  ),
                  FrequencyCard(
                    frequency: ReminderFrequency.fourTimes,
                    isSelected: _selectedFrequency == ReminderFrequency.fourTimes,
                    onTap: () => _selectFrequency(ReminderFrequency.fourTimes),
                  ),
                  FrequencyCard(
                    frequency: ReminderFrequency.every8Hours,
                    isSelected: _selectedFrequency == ReminderFrequency.every8Hours,
                    onTap: () => _selectFrequency(ReminderFrequency.every8Hours),
                  ),
                  FrequencyCard(
                    frequency: ReminderFrequency.every12Hours,
                    isSelected: _selectedFrequency == ReminderFrequency.every12Hours,
                    onTap: () => _selectFrequency(ReminderFrequency.every12Hours),
                  ),
                  FrequencyCard(
                    frequency: ReminderFrequency.withMeals,
                    isSelected: _selectedFrequency == ReminderFrequency.withMeals,
                    onTap: () => _selectFrequency(ReminderFrequency.withMeals),
                  ),
                  FrequencyCard(
                    frequency: ReminderFrequency.custom,
                    isSelected: _selectedFrequency == ReminderFrequency.custom,
                    onTap: () => _selectFrequency(ReminderFrequency.custom),
                  ),
                ],
              ),
            ],
            
            if (_selectedFrequency != null) ...[
              const SizedBox(height: 32),
              
              // Step 3: Set Times
              const Text(
                'Set reminder times',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Time selection based on frequency
              if (_selectedFrequency == ReminderFrequency.withMeals)
                _buildMealSelector()
              else
                _buildTimeSelector(),
              
              // Timezone and flexibility settings
              if (_selectedFrequency != null) ...[
                const SizedBox(height: 24),
                _buildAdvancedSettings(),
              ],
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _canSave() ? _saveReminders : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: AppColors.borderLight(context),
                  ),
                  child: const Text('Save Reminder', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _selectFrequency(ReminderFrequency frequency) {
    setState(() {
      _selectedFrequency = frequency;
      if (frequency == ReminderFrequency.withMeals) {
        // Default to breakfast, lunch, dinner for meal-based
        _selectedMeals.addAll(['breakfast', 'lunch', 'dinner']);
      } else {
        // Auto-set default times for the frequency
        _selectedTimes = FrequencyHelpers.getDefaultTimes(frequency);
        _selectedMeals.clear();
      }
    });
  }

  Widget _buildTimeSelector() {
    if (_selectedTimes.isEmpty) return const SizedBox.shrink();
    
    return Column(
      children: [
        for (int i = 0; i < _selectedTimes.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _selectTime(i),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderLight(context)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(AppIcons.time(), color: AppColors.primaryGreen),
                    const SizedBox(width: 12),
                    Text(
                      _getTimeLabel(i),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _selectedTimes[i].format(context),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppIcons.themedIcon(context, AppIcons.chevronRight(), color: AppColors.textSecondary(context), autoMirror: true),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getTimeLabel(int index) {
    switch (_selectedFrequency) {
      case ReminderFrequency.onceDaily:
        return 'Daily dose';
      case ReminderFrequency.twiceDaily:
        return index == 0 ? 'Morning dose' : 'Evening dose';
      case ReminderFrequency.threeTimes:
        return ['Morning dose', 'Afternoon dose', 'Evening dose'][index];
      case ReminderFrequency.fourTimes:
        return 'Dose ${index + 1}';
      case ReminderFrequency.every8Hours:
        return 'Dose ${index + 1}';
      case ReminderFrequency.every12Hours:
        return index == 0 ? 'First dose' : 'Second dose';
      case ReminderFrequency.withMeals:
        return ['Breakfast', 'Lunch', 'Dinner'][index];
      default:
        return 'Dose ${index + 1}';
    }
  }

  Future<void> _selectTime(int index) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTimes[index],
    );
    if (time != null) {
      setState(() {
        _selectedTimes[index] = time;
      });
    }
  }

  Widget _buildMealSelector() {
    final userAsync = ref.watch(userProfileProvider);
    
    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Text('Please complete your profile setup first');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal selection
            Text(
              'Select Meals',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMealChip('breakfast', user.breakfastTime),
                _buildMealChip('lunch', user.lunchTime),
                _buildMealChip('dinner', user.dinnerTime),
                _buildMealChip('bedtime', user.sleepTime),
              ],
            ),
            const SizedBox(height: 16),
            
            // Meal timing
            Text(
              'When to take with meals',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MealTiming>(
              initialValue: _selectedMealTiming,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: MealTiming.values.map((timing) {
                return DropdownMenuItem(
                  value: timing,
                  child: Text(_getMealTimingLabel(timing)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMealTiming = value);
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Calculated times preview
            if (_selectedMeals.isNotEmpty) ...[
              Text(
                'Calculated reminder times',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 8),
              ..._buildCalculatedTimesPreview(user),
            ],
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, s) => Text('Error: $e'),
    );
  }

  Widget _buildMealChip(String meal, String time) {
    final isSelected = _selectedMeals.contains(meal);
    final icon = meal == 'breakfast'
        ? Icons.wb_sunny
        : meal == 'lunch'
            ? Icons.lunch_dining
            : meal == 'dinner'
                ? Icons.dinner_dining
                : Icons.bedtime;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(meal[0].toUpperCase() + meal.substring(1)),
          const SizedBox(width: 4),
          Text(
            '($time)',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedMeals.add(meal);
          } else {
            _selectedMeals.remove(meal);
          }
        });
      },
      selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primaryGreen,
    );
  }

  List<Widget> _buildCalculatedTimesPreview(UserModel user) {
    final preview = <Widget>[];
    // final calculationService = ReminderCalculationService();

    for (final meal in _selectedMeals) {
      String mealTime;
      switch (meal) {
        case 'breakfast':
          mealTime = user.breakfastTime;
          break;
        case 'lunch':
          mealTime = user.lunchTime;
          break;
        case 'dinner':
          mealTime = user.dinnerTime;
          break;
        case 'bedtime':
          mealTime = user.sleepTime;
          break;
        default:
          continue;
      }

      // Apply flexibility window
      final timeParts = mealTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final adjustedMinute = minute + _flexibilityWindow;
      final adjustedHour = hour + (adjustedMinute ~/ 60);
      final finalMinute = adjustedMinute % 60;
      
      final previewTime = '${adjustedHour.toString().padLeft(2, '0')}:${finalMinute.toString().padLeft(2, '0')}';

      preview.add(
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                '${meal[0].toUpperCase() + meal.substring(1)}: $previewTime',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return preview;
  }

  Widget _buildAdvancedSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            
            // Timezone awareness toggle
            SwitchListTile(
              title: const Text('Timezone aware'),
              subtitle: const Text('Adjust reminders when timezone changes'),
              value: _isTimezoneAware,
              onChanged: (value) {
                setState(() => _isTimezoneAware = value);
              },
              activeThumbColor: AppColors.primaryGreen,
            ),
            
            // Flexibility window slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Flexibility window'),
                    Text(
                      '${_flexibilityWindow >= 0 ? "+" : ""}$_flexibilityWindow min',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _flexibilityWindow.toDouble(),
                  min: -30,
                  max: 60,
                  divisions: 18,
                  label: '${_flexibilityWindow >= 0 ? "+" : ""}$_flexibilityWindow min',
                  onChanged: (value) {
                    setState(() => _flexibilityWindow = value.round());
                  },
                ),
                Text(
                  'Reminder can be ±${_flexibilityWindow >= 0 ? _flexibilityWindow : -_flexibilityWindow} minutes from scheduled time',
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
    );
  }

  String _getMealTimingLabel(MealTiming timing) {
    switch (timing) {
      case MealTiming.beforeMeals:
        return 'Before meals';
      case MealTiming.withMeals:
        return 'With meals';
      case MealTiming.afterMeals:
        return 'After meals';
      case MealTiming.notApplicable:
        return 'Not applicable';
    }
  }

  bool _canSave() {
    if (_selectedMedicineId == null || _selectedFrequency == null) return false;
    
    if (_selectedFrequency == ReminderFrequency.withMeals) {
      return _selectedMeals.isNotEmpty;
    } else {
      return _selectedTimes.isNotEmpty;
    }
  }

  Future<void> _saveReminders() async {
    final user = ref.read(authStateProvider).value;
    final userProfileAsync = ref.read(userProfileProvider);
    final userProfile = userProfileAsync.value;
    
    if (user == null || userProfile == null) return;

    if (_selectedFrequency == ReminderFrequency.withMeals) {
      // Create meal-based reminder
      final mealTimesMap = <String, String>{};
      
      for (final meal in _selectedMeals) {
        switch (meal) {
          case 'breakfast':
            mealTimesMap['breakfast'] = userProfile.breakfastTime;
            break;
          case 'lunch':
            mealTimesMap['lunch'] = userProfile.lunchTime;
            break;
          case 'dinner':
            mealTimesMap['dinner'] = userProfile.dinnerTime;
            break;
          case 'bedtime':
            mealTimesMap['bedtime'] = userProfile.sleepTime;
            break;
        }
      }

      // Calculate times for preview (will be recalculated by ReminderCalculationService)
      final calculatedTimes = <String>[];
      for (final mealTime in mealTimesMap.values) {
        calculatedTimes.add(mealTime);
      }

      final newReminder = ReminderModel(
        id: const Uuid().v4(),
        medicineId: _selectedMedicineId!,
        medicineName: _selectedMedicineName!,
        frequency: ReminderFrequency.withMeals,
        times: calculatedTimes,
        mealTimes: mealTimesMap,
        mealTiming: _selectedMealTiming,
        time: calculatedTimes.isNotEmpty ? calculatedTimes.first : '08:00',
        dosage: '1 dose',
        frequency_legacy: 'withMeals',
        daysOfWeek: _selectedDays,
        notificationId: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        includeOvernight: false,
        isTimezoneAware: _isTimezoneAware,
        minutesOffset: _flexibilityWindow,
        imageUrl: _selectedMedicineImageUrl, // Pass image URL
      );

      await ref.read(reminderControllerProvider.notifier).addReminder(newReminder);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Meal-based reminder added for $_selectedMedicineName'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context);
    } else {
      // Create time-based reminders (existing logic)
      for (int i = 0; i < _selectedTimes.length; i++) {
        final time = _selectedTimes[i];
        final timeString = time.toFormattedString();
        
        final newReminder = ReminderModel(
          id: const Uuid().v4(),
          medicineId: _selectedMedicineId!,
          medicineName: _selectedMedicineName!,
          frequency: _selectedFrequency!,
          times: _selectedTimes.map((t) => t.toFormattedString()).toList(),
          time: timeString,
          dosage: '1 dose',
          frequency_legacy: _selectedFrequency!.name,
          daysOfWeek: _selectedDays,
          notificationId: DateTime.now().millisecondsSinceEpoch ~/ 1000 + i,
          includeOvernight: false,
          isTimezoneAware: _isTimezoneAware,
          minutesOffset: _flexibilityWindow,
          imageUrl: _selectedMedicineImageUrl, // Pass image URL
        );

        await ref.read(reminderControllerProvider.notifier).addReminder(newReminder);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ ${_selectedTimes.length} reminder(s) added for $_selectedMedicineName'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context);
    }
  }
}
