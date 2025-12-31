import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/core/models/medicine_model.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/features/medicines/providers/medicine_provider.dart';
import 'package:tickdose/features/medicines/widgets/medicine_form.dart';
import 'package:tickdose/features/medicines/services/medicine_camera_service.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

class AddMedicineScreen extends ConsumerStatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: Column(
        children: [
          // Sticky header matching design
          _buildHeader(context),
          // Scrollable form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: MedicineForm(
                onSave: (name, strength, form, dosage, frequency, notes, image, doctorId, sideEffects, refillReminderDays, barcode) async {
                  if (_isSaving) return; // Prevent double submission
                  
                  setState(() => _isSaving = true);
                  
                  try {
                    final user = ref.read(authStateProvider).value;
                    if (user == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.pleaseLogin),
                            backgroundColor: AppColors.errorRed,
                          ),
                        );
                      }
                      return;
                    }

                    // Generate ID first for image upload
                    final medicineId = const Uuid().v4();

                    // Upload image if captured
                    String? imageUrl;
                    if (image != null) {
                      try {
                        final cameraService = MedicineCameraService();
                        imageUrl = await cameraService.uploadMedicineImage(
                          image,
                          user.uid,
                          medicineId,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.failedToUploadImage(e)),
                              backgroundColor: AppColors.warningOrange,
                            ),
                          );
                        }
                        // Continue without image
                      }
                    }
                    final notificationId = DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF;

                    final newMedicine = MedicineModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: user.uid,
                      name: name,
                      strength: strength,
                      form: form,
                      dosage: dosage,
                      frequency: frequency,
                      notes: notes,
                      imageUrl: imageUrl,
                      doctorId: doctorId,
                      sideEffects: sideEffects,
                      refillReminderDays: refillReminderDays,
                      notificationId: notificationId,
                      barcode: barcode,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    await ref.read(medicineControllerProvider.notifier).addMedicine(newMedicine);
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.medicineAddedSuccessfully),
                          backgroundColor: AppColors.successGreen,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${AppLocalizations.of(context)!.errorOccurred(e)}: $e'),
                          backgroundColor: AppColors.errorRed,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isSaving = false);
                    }
                  }
                },
              ),
            ),
          ),
          // Loading indicator
          if (_isSaving)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor(context),
                border: Border(
                  top: BorderSide(
                    color: AppColors.borderLight(context),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.saving,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(context).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight(context),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 24,
                  color: AppColors.textPrimary(context),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                l10n.addMedicineTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 48), // Spacer for centering
            ],
          ),
        ),
      ),
    );
  }
}
