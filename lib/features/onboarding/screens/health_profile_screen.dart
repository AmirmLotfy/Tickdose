import 'package:flutter/material.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/widgets/custom_toggle_switch.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

class HealthProfileScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  
  const HealthProfileScreen({
    super.key,
    this.currentStep = 2,
    this.totalSteps = 4,
  });

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  
  final List<String> _allergies = [];
  final List<String> _conditions = [];
  bool _noAllergies = false;
  String? _selectedBloodType;
  
  final List<String> _commonConditions = ['Diabetes', 'Hypertension', 'Asthma'];

  @override
  void dispose() {
    _allergyController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  void _addAllergy(String allergy) {
    if (allergy.trim().isNotEmpty && !_allergies.contains(allergy.trim())) {
      setState(() {
        _allergies.add(allergy.trim());
        _allergyController.clear();
      });
    }
  }

  void _removeAllergy(String allergy) {
    setState(() {
      _allergies.remove(allergy);
    });
  }

  void _addCondition(String condition) {
    if (condition.trim().isNotEmpty && !_conditions.contains(condition.trim())) {
      setState(() {
        _conditions.add(condition.trim());
        _conditionController.clear();
      });
    }
  }

  void _removeCondition(String condition) {
    setState(() {
      _conditions.remove(condition);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Progress Bar
            _buildProgressBar(context),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const SizedBox(height: 8),
                    // Headline
                  Text(
                      AppLocalizations.of(context)!.medicalBackground,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                  ),
                  const SizedBox(height: 8),
                    // Body Text
                  Text(
                      AppLocalizations.of(context)!.aiAnalyzeSymptoms,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                        fontSize: 16,
                        height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                    // Allergies Section
                    _buildAllergiesSection(context),
                    const SizedBox(height: 32),
                    // Divider
                    Container(
                      height: 1,
                      color: AppColors.borderLight(context),
                    ),
                    const SizedBox(height: 32),
                    // Chronic Conditions Section
                    _buildConditionsSection(context),
                    const SizedBox(height: 32),
                    // Blood Type Section
                    _buildBloodTypeSection(context),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
            // Sticky Footer
            _buildFooterButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
            color: AppColors.textPrimary(context),
          ),
          Text(
            'Step ${widget.currentStep}/${widget.totalSteps}',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(widget.totalSteps, (index) {
          final isActive = index < widget.currentStep;
          return Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsetsDirectional.only(end: index < widget.totalSteps - 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryGreen
                    : Theme.of(context).brightness == Brightness.dark
                        ? AppColors.borderLight(context)
                        : AppColors.borderLight(context),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAllergiesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.doYouHaveAllergies,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
                  ),
                  const SizedBox(height: 16),
        // Search Input
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColorLight(context),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _allergyController,
            enabled: !_noAllergies,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Search allergies (e.g., Peanuts)',
              hintStyle: TextStyle(
                color: AppColors.textSecondary(context),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.textSecondary(context),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onSubmitted: _noAllergies ? null : _addAllergy,
          ),
                  ),
                  const SizedBox(height: 12),
        // Selected Chips
        if (_allergies.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
            children: _allergies.map((allergy) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      allergy,
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _removeAllergy(allergy),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                        );
                      }).toList(),
                    ),
        const SizedBox(height: 12),
        // "No Allergies" Toggle
                  Row(
                    children: [
            CustomToggleSwitch(
              value: _noAllergies,
              onChanged: (value) {
                              setState(() {
                  _noAllergies = value;
                  if (value) {
                    _allergies.clear();
                  }
                });
              },
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.noKnownAllergies,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
                      ),
                    ],
                  ),
      ],
    );
  }

  Widget _buildConditionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                  Text(
          AppLocalizations.of(context)!.chronicConditions,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        // Search Input
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColorLight(context),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _conditionController,
                    style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Search conditions (e.g., Asthma)',
              hintStyle: TextStyle(
                color: AppColors.textSecondary(context),
              ),
              prefixIcon: Icon(
                Icons.favorite,
                color: AppColors.textSecondary(context),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onSubmitted: _addCondition,
          ),
        ),
        const SizedBox(height: 12),
        // Suggestion Buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
          children: _commonConditions.map((condition) {
            final isSelected = _conditions.contains(condition);
            return GestureDetector(
              onTap: () {
                if (isSelected) {
                  _removeCondition(condition);
                } else {
                  _addCondition(condition);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreen.withValues(alpha: 0.2)
                      : Theme.of(context).brightness == Brightness.dark
                          ? AppColors.borderLight(context)
                          : AppColors.borderLight(context).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(
                          color: AppColors.primaryGreen.withValues(alpha: 0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Text(
                  condition,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.textSecondary(context),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
                        );
                      }).toList(),
                    ),
        // Selected Conditions
        if (_conditions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _conditions.where((c) => !_commonConditions.contains(c)).map((condition) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                    children: [
                    Text(
                      condition,
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _removeCondition(condition),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.primaryGreen,
                      ),
                  ),
                ],
              ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildBloodTypeSection(BuildContext context) {
    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
                children: [
              const TextSpan(text: 'Blood Type '),
              TextSpan(
                text: '(Optional)',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: bloodTypes.map((type) {
              final isSelected = _selectedBloodType == type;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBloodType = isSelected ? null : type;
                  });
                },
                child: Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsetsDirectional.only(end: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : Theme.of(context).brightness == Brightness.dark
                            ? AppColors.surfaceColor(context)
                            : AppColors.surfaceColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : Theme.of(context).brightness == Brightness.dark
                              ? AppColors.borderLight(context)
                              : AppColors.borderLight(context),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      type,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.backgroundColor(context)
                            : AppColors.textSecondary(context),
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.backgroundColor(context),
            AppColors.backgroundColor(context).withValues(alpha: 0.0),
          ],
          stops: const [0.8, 1.0],
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.25),
              blurRadius: 14,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'allergies': _noAllergies ? [] : _allergies,
              'conditions': _conditions,
              'bloodType': _selectedBloodType,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: AppColors.backgroundColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                size: 20,
                color: AppColors.backgroundColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
