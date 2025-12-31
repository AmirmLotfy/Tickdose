import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/models/reminder_model.dart';
import 'package:tickdose/core/models/user_model.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/features/reminders/providers/reminder_provider.dart';
import 'package:tickdose/features/medicines/providers/medicine_provider.dart';
import 'package:tickdose/features/profile/providers/profile_provider.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

class EditReminderScreen extends ConsumerStatefulWidget {
  final ReminderModel reminder;

  const EditReminderScreen({
    super.key,
    required this.reminder,
  });

  @override
  ConsumerState<EditReminderScreen> createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends ConsumerState<EditReminderScreen> {
  late String selectedMedicineId;
  late TimeOfDay selectedTime;
  late ReminderFrequency selectedFrequency;
  Set<String> selectedMeals = {};
  MealTiming selectedMealTiming = MealTiming.withMeals;
  late bool isTimezoneAware;
  late int flexibilityWindow;

  @override
  void initState() {
    super.initState();
    selectedMedicineId = widget.reminder.medicineId;
    selectedFrequency = widget.reminder.frequency;
    isTimezoneAware = widget.reminder.isTimezoneAware;
    flexibilityWindow = widget.reminder.minutesOffset;
    
    // Parse time string "HH:mm" to TimeOfDay
    final timeParts = widget.reminder.time.split(':');
    selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
    
    // Load meal-based reminder data
    if (widget.reminder.frequency == ReminderFrequency.withMeals) {
      selectedMeals = widget.reminder.mealTimes?.keys.toSet() ?? {};
      selectedMealTiming = widget.reminder.mealTiming ?? MealTiming.withMeals;
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicinesAsync = ref.watch(medicinesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.editReminder,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: medicinesAsync.when(
        data: (medicines) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Medicine',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedMedicineId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: medicines.map((medicine) {
                    return DropdownMenuItem(
                      value: medicine.id,
                      child: Text(medicine.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedMedicineId = value);
                    }
                  },
                ),
                const SizedBox(height: 24),
                
                // Frequency display
                Text(
                  'Frequency: ${selectedFrequency.name}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Meal-based or time-based editing
                if (selectedFrequency == ReminderFrequency.withMeals)
                  _buildMealEditor(context)
                else
                  _buildTimeEditor(),
                
                const SizedBox(height: 24),
                
                // Advanced settings
                _buildAdvancedSettings(),
                
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    final selectedMedicine = medicines.firstWhere((m) => m.id == selectedMedicineId);
                    final userProfileAsync = ref.read(userProfileProvider);
                    final userProfile = userProfileAsync.value;
                    
                    ReminderModel updatedReminder;
                    
                    if (selectedFrequency == ReminderFrequency.withMeals && userProfile != null) {
                      // Update meal-based reminder
                      final mealTimesMap = <String, String>{};
                      for (final meal in selectedMeals) {
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
                      
                      updatedReminder = widget.reminder.copyWith(
                        medicineId: selectedMedicineId,
                        medicineName: selectedMedicine.name,
                        mealTimes: mealTimesMap,
                        mealTiming: selectedMealTiming,
                        isTimezoneAware: isTimezoneAware,
                        minutesOffset: flexibilityWindow,
                        time: mealTimesMap.values.isNotEmpty ? mealTimesMap.values.first : widget.reminder.time,
                        times: mealTimesMap.values.toList(),
                      );
                    } else {
                      // Update time-based reminder
                      updatedReminder = widget.reminder.copyWith(
                        medicineId: selectedMedicineId,
                        medicineName: selectedMedicine.name,
                        time: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                        isTimezoneAware: isTimezoneAware,
                        minutesOffset: flexibilityWindow,
                      );
                    }

                    await ref.read(reminderControllerProvider.notifier).updateReminder(updatedReminder);
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Update Reminder'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildTimeEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListTile(
          tileColor: AppColors.borderLight(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          leading: Icon(AppIcons.time()),
          title: Text(selectedTime.format(context)),
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: selectedTime,
            );
            if (time != null) {
              setState(() => selectedTime = time);
            }
          },
        ),
      ],
    );
  }

  Widget _buildMealEditor(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);
    
    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Text('User profile not available');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meal Selection',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            
            const Text(
              'Meal Timing',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MealTiming>(
              initialValue: selectedMealTiming,
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
                  setState(() => selectedMealTiming = value);
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Calculated times preview
            if (selectedMeals.isNotEmpty) ...[
              const Text(
                'Calculated Reminder Times',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
    final isSelected = selectedMeals.contains(meal);
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
            selectedMeals.add(meal);
          } else {
            selectedMeals.remove(meal);
          }
        });
      },
      selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primaryGreen,
    );
  }

  List<Widget> _buildCalculatedTimesPreview(UserModel user) {
    final preview = <Widget>[];

    for (final meal in selectedMeals) {
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
      final adjustedMinute = minute + flexibilityWindow;
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
              value: isTimezoneAware,
              onChanged: (value) {
                setState(() => isTimezoneAware = value);
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
                      '${flexibilityWindow >= 0 ? "+" : ""}$flexibilityWindow min',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: flexibilityWindow.toDouble(),
                  min: -30,
                  max: 60,
                  divisions: 18,
                  label: '${flexibilityWindow >= 0 ? "+" : ""}$flexibilityWindow min',
                  onChanged: (value) {
                    setState(() => flexibilityWindow = value.round());
                  },
                ),
                Text(
                  'Reminder can be ±${flexibilityWindow >= 0 ? flexibilityWindow : -flexibilityWindow} minutes from scheduled time',
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
}
