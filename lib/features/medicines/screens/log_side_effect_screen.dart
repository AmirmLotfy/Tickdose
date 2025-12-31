import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/core/models/medicine_model.dart';
import 'package:tickdose/core/models/side_effect_log_model.dart';
import 'package:tickdose/features/medicines/providers/side_effect_provider.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:uuid/uuid.dart';

class LogSideEffectScreen extends ConsumerStatefulWidget {
  final MedicineModel medicine;

  const LogSideEffectScreen({super.key, required this.medicine});

  @override
  ConsumerState<LogSideEffectScreen> createState() => _LogSideEffectScreenState();
}

class _LogSideEffectScreenState extends ConsumerState<LogSideEffectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _effectController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedSeverity = 'mild';
  DateTime _selectedDateTime = DateTime.now();

  final List<String> _commonEffects = [
    'Nausea',
    'Headache',
    'Dizziness',
    'Stomach pain',
    'Drowsiness',
    'Insomnia',
    'Rash',
    'Fatigue',
    'Other (specify below)',
  ];

  @override
  void dispose() {
    _effectController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitSideEffect() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final sideEffect = SideEffectLog(
      id: const Uuid().v4(),
      userId: user.uid,
      medicineId: widget.medicine.id,
      medicineName: widget.medicine.name,
      symptom: _effectController.text.trim(),
      severity: _selectedSeverity,
      occurredAt: _selectedDateTime,
      notes: _notesController.text.trim(),
    );

    await ref.read(sideEffectControllerProvider.notifier).logSideEffect(sideEffect);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.sideEffectLoggedSuccess),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.logSideEffectTitle, style: TextStyle(color: AppColors.textPrimary(context))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Medicine name display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medicine',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    Text(
                      widget.medicine.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    if (widget.medicine.strength.isNotEmpty)
                      Text(
                        widget.medicine.strength,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Common effects chips
              Text(
                'Common Side Effects',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _commonEffects.map((effect) {
                  final isSelected = _effectController.text == effect;
                  return ChoiceChip(
                    label: Text(effect),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _effectController.text = selected ? effect : '';
                      });
                    },
                    selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary(context),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Effect name input
              TextFormField(
                controller: _effectController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.effectNameLabel,
                  hintText: AppLocalizations.of(context)!.effectNameHint,
                  prefixIcon: Icon(AppIcons.medical()),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the side effect';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Severity selector
              Text(
                'Severity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SeverityButton(
                      label: 'Mild',
                      icon: AppIcons.sentiment(),
                      color: AppColors.successGreen,
                      isSelected: _selectedSeverity == 'mild',
                      onTap: () => setState(() => _selectedSeverity = 'mild'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SeverityButton(
                      label: 'Moderate',
                      icon: AppIcons.sentiment(),
                      color: Colors.orange,
                      isSelected: _selectedSeverity == 'moderate',
                      onTap: () => setState(() => _selectedSeverity = 'moderate'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SeverityButton(
                      label: 'Severe',
                      icon: AppIcons.warning(),
                      color: AppColors.errorRed,
                      isSelected: _selectedSeverity == 'severe',
                      onTap: () => setState(() => _selectedSeverity = 'severe'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date/time selector
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                leading: Icon(AppIcons.time(), color: AppColors.primaryBlue),
                title: Text(AppLocalizations.of(context)!.whenDidThisOccur),
                subtitle: Text(
                  '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} at ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(AppIcons.edit()),
                onTap: _selectDateTime,
              ),
              const SizedBox(height: 20),

              // Notes input
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.notesOptionalLabel,
                  hintText: AppLocalizations.of(context)!.notesOptionalHint,
                  prefixIcon: Icon(AppIcons.note()),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _submitSideEffect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.logSideEffectTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeverityButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SeverityButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary(context),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
