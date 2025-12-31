import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/core/models/user_model.dart';
import 'package:tickdose/features/profile/providers/profile_provider.dart';

class HealthInfoScreen extends ConsumerStatefulWidget {
  const HealthInfoScreen({super.key});

  @override
  ConsumerState<HealthInfoScreen> createState() => _HealthInfoScreenState();
}

class _HealthInfoScreenState extends ConsumerState<HealthInfoScreen> {
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _conditionController.dispose();
    _allergyController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _initializeFields(UserModel user) {
    if (user.age != null) {
      _ageController.text = user.age.toString();
    }
    if (user.weight != null) {
      _weightController.text = user.weight.toString();
    }
    if (user.height != null) {
      _heightController.text = user.height.toString();
    }
    _selectedGender = user.gender;
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Health Information', style: TextStyle(color: AppColors.textPrimary(context))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('No user data'));

          if (_ageController.text.isEmpty && user.age != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeFields(user);
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Health Information
                Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Age
                TextField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    hintText: 'Enter your age',
                    border: OutlineInputBorder(),
                    suffixText: 'years',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final age = int.tryParse(value);
                    if (age != null) {
                      ref.read(profileControllerProvider.notifier).updateProfile(
                        user.copyWith(age: age),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Gender
                DropdownButtonFormField<String>(
                  initialValue: _selectedGender ?? user.gender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                    DropdownMenuItem(value: 'prefer_not_to_say', child: Text('Prefer not to say')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedGender = value);
                    if (value != null) {
                      ref.read(profileControllerProvider.notifier).updateProfile(
                        user.copyWith(gender: value),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Weight
                TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    hintText: 'Enter your weight',
                    border: OutlineInputBorder(),
                    suffixText: 'kg',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final weight = double.tryParse(value);
                    if (weight != null) {
                      ref.read(profileControllerProvider.notifier).updateProfile(
                        user.copyWith(weight: weight),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Height
                TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Height',
                    hintText: 'Enter your height',
                    border: OutlineInputBorder(),
                    suffixText: 'cm',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final height = double.tryParse(value);
                    if (height != null) {
                      ref.read(profileControllerProvider.notifier).updateProfile(
                        user.copyWith(height: height),
                      );
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Health Conditions
                Text(
                  'Health Conditions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: user.healthConditions
                      .map((condition) => Chip(
                            label: Text(condition),
                            deleteIcon: Icon(AppIcons.close(), size: 18),
                            onDeleted: () {
                              final updated = List<String>.from(user.healthConditions)..remove(condition);
                              ref.read(profileControllerProvider.notifier).updateProfile(
                                    user.copyWith(healthConditions: updated),
                                  );
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _conditionController,
                        decoration: const InputDecoration(
                          hintText: 'Add condition',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_conditionController.text.isNotEmpty) {
                          final updated = List<String>.from(user.healthConditions)
                            ..add(_conditionController.text);
                          ref.read(profileControllerProvider.notifier).updateProfile(
                                user.copyWith(healthConditions: updated),
                              );
                          _conditionController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Allergies',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: user.allergies
                      .map((allergy) => Chip(
                            label: Text(allergy),
                            backgroundColor: AppColors.errorRed.withValues(alpha: 0.1),
                            deleteIcon: Icon(AppIcons.close(), size: 18),
                            onDeleted: () {
                              final updated = List<String>.from(user.allergies)..remove(allergy);
                              ref.read(profileControllerProvider.notifier).updateProfile(
                                    user.copyWith(allergies: updated),
                                  );
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _allergyController,
                        decoration: const InputDecoration(
                          hintText: 'Add allergy',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_allergyController.text.isNotEmpty) {
                          final updated = List<String>.from(user.allergies)
                            ..add(_allergyController.text);
                          ref.read(profileControllerProvider.notifier).updateProfile(
                                user.copyWith(allergies: updated),
                              );
                          _allergyController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                      child: const Text('Add'),
                    ),
                  ],
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
}
