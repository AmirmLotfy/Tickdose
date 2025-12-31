import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/models/medicine_model.dart';
import 'package:tickdose/core/services/drug_interaction_service.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/services/voice_reminder_service.dart';
import 'package:tickdose/core/providers/voice_settings_provider.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

class MedicineInteractionWarningScreen extends ConsumerStatefulWidget {
  final MedicineModel medicine;
  final List<MedicineModel> existingMedicines;
  final Function(bool proceed)? onDecision;

  const MedicineInteractionWarningScreen({
    super.key,
    required this.medicine,
    required this.existingMedicines,
    this.onDecision,
  });

  @override
  ConsumerState<MedicineInteractionWarningScreen> createState() => _MedicineInteractionWarningScreenState();
}

class _MedicineInteractionWarningScreenState extends ConsumerState<MedicineInteractionWarningScreen> {
  final DrugInteractionService _interactionService = DrugInteractionService();
  DrugInteractionResult? _interactionResult;
  bool _isLoading = true;
  bool _acknowledged = false;

  @override
  void initState() {
    super.initState();
    _checkInteractions();
  }

  Future<void> _checkInteractions() async {
    setState(() => _isLoading = true);

    try {
      final allMedicines = [widget.medicine, ...widget.existingMedicines];
      final result = await _interactionService.checkMedicineInteractions(
        medicines: allMedicines,
      );

      setState(() {
        _interactionResult = result;
        _isLoading = false;
      });

      // Play voice warning if critical or high severity
      if (result.severity == InteractionSeverity.critical || 
          result.severity == InteractionSeverity.high) {
        _playVoiceWarning();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playVoiceWarning() async {
    try {
      final voiceSettings = ref.read(voiceSettingsProvider);
      if (voiceSettings.useVoiceConfirmations == true) {
        // const warningText = 'Warning! This medicine has a serious interaction with your current medications. Talk to your doctor before taking.';
        
        final voiceReminderService = VoiceReminderService();
        await voiceReminderService.sendVoiceReminder(
          medicineName: widget.medicine.name,
          dosage: widget.medicine.dosage,
          voiceId: voiceSettings.selectedVoiceId.isNotEmpty 
              ? voiceSettings.selectedVoiceId 
              : 'default',
          reminderType: VoiceReminderType.emergency,
        );
      }
    } catch (e) {
      // Ignore voice errors
    }
  }

  Color _getSeverityColor(InteractionSeverity severity) {
    switch (severity) {
      case InteractionSeverity.critical:
        return AppColors.errorRed;
      case InteractionSeverity.high:
        return AppColors.warningOrange;
      case InteractionSeverity.moderate:
        return AppColors.warningOrange.withValues(alpha: 0.7);
      case InteractionSeverity.low:
        return AppColors.infoBlue;
      case InteractionSeverity.none:
        return AppColors.successGreen;
    }
  }

  String _getSeverityText(InteractionSeverity severity) {
    switch (severity) {
      case InteractionSeverity.critical:
        return 'CRITICAL';
      case InteractionSeverity.high:
        return 'HIGH';
      case InteractionSeverity.moderate:
        return 'MODERATE';
      case InteractionSeverity.low:
        return 'LOW';
      case InteractionSeverity.none:
        return 'NONE';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.interactionWarning),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _interactionResult == null || !_interactionResult!.hasInteractions
              ? _buildNoInteractionsView()
              : _buildInteractionsView(),
    );
  }

  Widget _buildNoInteractionsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 80,
              color: AppColors.successGreen,
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.noInteractionsDetected,
              style: AppTextStyles.h2(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.onDecision?.call(true);
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.darkTextPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
              child: Text(AppLocalizations.of(context)!.continueButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionsView() {
    final result = _interactionResult!;
    final severityColor = _getSeverityColor(result.severity);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Warning header
        Card(
          color: severityColor.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.warning,
                  size: 60,
                  color: severityColor,
                ),
                const SizedBox(height: 16),
                Text(
                  '${_getSeverityText(result.severity)} INTERACTION DETECTED',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: severityColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.thisMedicineInteracts,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Interactions list
        Text(
          AppLocalizations.of(context)!.interactionsFound,
          style: AppTextStyles.h3(context),
        ),
        const SizedBox(height: 12),
        ...result.interactions.map((interaction) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(interaction.severity).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getSeverityText(interaction.severity),
                          style: TextStyle(
                            color: _getSeverityColor(interaction.severity),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${interaction.medicineA} + ${interaction.medicineB}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    interaction.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.infoBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: AppColors.infoBlue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            interaction.recommendation,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.infoBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 24),

        // Recommendations
        if (result.recommendations.isNotEmpty) ...[
          Text(
            'Recommendations',
            style: AppTextStyles.h3(context),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: result.recommendations.map((rec) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            rec,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Acknowledgment checkbox
        Card(
          child: CheckboxListTile(
            title: Text(AppLocalizations.of(context)!.iUnderstandTheRisks),
            subtitle: Text(
              result.shouldConsultDoctor
                  ? 'I will consult my doctor before taking this medication'
                  : 'I have read and understood the interaction warnings',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
            value: _acknowledged,
            onChanged: (value) {
              setState(() => _acknowledged = value ?? false);
            },
            activeColor: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 24),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  widget.onDecision?.call(false);
                  Navigator.pop(context, false);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _acknowledged
                    ? () {
                        widget.onDecision?.call(true);
                        Navigator.pop(context, true);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: severityColor,
                  foregroundColor: AppColors.darkTextPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(AppLocalizations.of(context)!.proceedAnyway),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
