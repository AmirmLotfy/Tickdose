import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/models/medicine_model.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/features/medicines/providers/medicine_provider.dart';
import 'package:tickdose/features/medicines/widgets/medicine_form.dart';
import 'package:tickdose/features/medicines/services/medicine_camera_service.dart';
import 'package:tickdose/core/utils/logger.dart';

class EditMedicineScreen extends ConsumerStatefulWidget {
  final MedicineModel medicine;

  const EditMedicineScreen({
    super.key,
    required this.medicine,
  });

  @override
  ConsumerState<EditMedicineScreen> createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends ConsumerState<EditMedicineScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: Column(
        children: [
          // Sticky Header
          _buildHeader(context),
          // Scrollable form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: MedicineForm(
                initialMedicine: widget.medicine,
                onSave: (name, strength, form, dosage, frequency, notes, image, doctorId, sideEffects, refillReminderDays, barcode) async {
                  String? imageUrl = widget.medicine.imageUrl;
                  if (image != null) {
                     try {
                        // Upload new image
                        final cameraService = MedicineCameraService();
                        imageUrl = await cameraService.uploadMedicineImage(
                           image, 
                           widget.medicine.userId, 
                           widget.medicine.id
                        );
                     } catch (e) {
                        Logger.error('Failed to upload updated image: $e');
                     }
                  }

                  final updatedMedicine = widget.medicine.copyWith(
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
                    notificationId: widget.medicine.notificationId == 0 
                        ? (DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF) 
                        : widget.medicine.notificationId,
                    barcode: barcode,
                    updatedAt: DateTime.now(),
                  );

                  await ref.read(medicineControllerProvider.notifier).updateMedicine(updatedMedicine);
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderLight(context)
                : AppColors.borderLight(context),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, size: 24),
                color: AppColors.textSecondary(context),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                'Edit Medicine',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                  letterSpacing: -0.015,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Save action - handled by form
                },
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
