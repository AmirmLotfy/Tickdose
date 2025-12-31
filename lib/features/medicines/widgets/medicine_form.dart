import 'package:flutter/material.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/models/medicine_model.dart';
import 'package:tickdose/core/services/voice_service.dart';
import 'package:tickdose/features/medicines/services/medicine_camera_service.dart';
import 'package:tickdose/core/services/medicine_ocr_service.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/features/doctors/providers/doctor_provider.dart';
import 'package:tickdose/features/doctors/screens/add_doctor_screen.dart';
import 'package:tickdose/core/services/gemini_service.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/core/services/remote_config_service.dart';
import 'package:tickdose/features/medicines/services/barcode_service.dart';
import 'package:tickdose/core/services/translation_service.dart';
import 'package:tickdose/core/services/drug_interaction_service.dart' as drug_interaction_service;
import 'package:tickdose/features/medicines/providers/medicine_provider.dart';
import 'package:tickdose/features/medicines/screens/medicine_interaction_warning_screen.dart';
import 'package:tickdose/core/widgets/custom_toggle_switch.dart';
import 'package:tickdose/core/services/permission_service.dart';
import 'package:tickdose/core/widgets/permission_dialog.dart';

class MedicineForm extends ConsumerStatefulWidget {
  final Function(String name, String strength, String form, String dosage, String frequency, String notes, File? image, String? doctorId, List<String> sideEffects, int refillReminderDays, String? barcode) onSave;
  final MedicineModel? initialMedicine;

  const MedicineForm({
    super.key,
    required this.onSave,
    this.initialMedicine,
  });

  @override
  ConsumerState<MedicineForm> createState() => _MedicineFormState();
}

class _MedicineFormState extends ConsumerState<MedicineForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _genericNameController;
  late TextEditingController _strengthController;
  late TextEditingController _dosageController;
  late TextEditingController _manufacturerController;
  late TextEditingController _batchNumberController;
  late TextEditingController _prescribedByController; 
  late TextEditingController _notesController;
  final TextEditingController _sideEffectController = TextEditingController();
  
  // Voice Input
  final VoiceService _voiceService = VoiceService();
  bool _isListening = false;

  // Camera Input
  final MedicineCameraService _cameraService = MedicineCameraService();
  final MedicineOcrService _ocrService = MedicineOcrService();
  final BarcodeService _barcodeService = BarcodeService(); 
  final TranslationService _translationService = TranslationService(); // NEW
  final GeminiService _geminiService = GeminiService(); // For smart enrichment
  File? _capturedImage;
  bool _isEnrichingData = false;
  String _selectedForm = 'tablet';
  String _selectedFrequency = 'daily';
  String? _selectedDoctorId;
  final List<String> _sideEffects = [];
  final List<TimeOfDay> _selectedTimes = [];
  int _refillReminderDays = 0;
  String? _scannedBarcode;
  bool _refillReminderEnabled = false;
  drug_interaction_service.DrugInteractionResult? _interactionResult;
  bool _isCheckingInteractions = false; 

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialMedicine?.name ?? '');
    _genericNameController = TextEditingController(text: widget.initialMedicine?.genericName ?? '');
    _strengthController = TextEditingController(text: widget.initialMedicine?.strength ?? '');
    _dosageController = TextEditingController(text: widget.initialMedicine?.dosage ?? '');
    _manufacturerController = TextEditingController(text: widget.initialMedicine?.manufacturer ?? '');
    _batchNumberController = TextEditingController(text: widget.initialMedicine?.batchNumber ?? '');
    _prescribedByController = TextEditingController(text: widget.initialMedicine?.prescribedBy ?? '');
    _notesController = TextEditingController(text: widget.initialMedicine?.notes ?? '');
    
    if (widget.initialMedicine != null) {
      _selectedForm = widget.initialMedicine!.form;
      _selectedFrequency = widget.initialMedicine!.frequency;
      _selectedDoctorId = widget.initialMedicine!.doctorId;
      _sideEffects.addAll(widget.initialMedicine!.sideEffects);
      _refillReminderDays = widget.initialMedicine!.refillReminderDays;
      _refillReminderEnabled = widget.initialMedicine!.refillReminderDays > 0;
      _scannedBarcode = widget.initialMedicine!.barcode; 
    }
    
    // Check interactions when name is entered
    _nameController.addListener(_checkInteractions);
  }
  
  Future<void> _checkInteractions() async {
    if (_nameController.text.isEmpty) {
      setState(() => _interactionResult = null);
      return;
    }
    
    setState(() => _isCheckingInteractions = true);
    
    try {
      final medicinesAsync = ref.read(medicinesStreamProvider);
      final existingMedicines = medicinesAsync.value ?? [];
      
      if (existingMedicines.isEmpty) {
        setState(() {
          _interactionResult = drug_interaction_service.DrugInteractionResult.none();
          _isCheckingInteractions = false;
        });
        return;
      }
      
      // Create a temporary medicine model for checking
      final tempMedicine = MedicineModel(
        id: 'temp',
        userId: '',
        name: _nameController.text,
        strength: _strengthController.text,
        form: _selectedForm,
        dosage: _dosageController.text,
        frequency: _selectedFrequency,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final interactionService = drug_interaction_service.DrugInteractionService();
      final result = await interactionService.checkMedicineInteractions(
        medicines: [tempMedicine, ...existingMedicines],
      );
      
      if (mounted) {
        setState(() {
          _interactionResult = result;
          _isCheckingInteractions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _interactionResult = null;
          _isCheckingInteractions = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genericNameController.dispose();
    _strengthController.dispose();
    _dosageController.dispose();
    _manufacturerController.dispose();
    _batchNumberController.dispose();
    _prescribedByController.dispose();
    _notesController.dispose();
    _sideEffectController.dispose();
    _barcodeService.dispose(); 
    // _translationService.close(); // Models managed globally or via close() if stateful.
                                   // ML Kit translator needs close() per instance if created. 
                                   // Our service recreates translator per call, so it handles its own closing.
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _voiceService.stopListening();
      setState(() => _isListening = false);
    } else {
      final available = await _voiceService.initialize();
      if (available) {
        setState(() => _isListening = true);
        await _voiceService.startListening(
          onResult: (text) {
            setState(() {
              final current = _notesController.text;
              _notesController.text = current.isEmpty ? text : '$current $text';
            });
          },
          onStatus: (status) {
            if (status == 'done' || status == 'notListening') {
              setState(() => _isListening = false);
            }
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.speechNotAvailable)),
          );
        }
      }
    }
  }  

  void _addSideEffect() {
    final effect = _sideEffectController.text.trim();
    if (effect.isNotEmpty && !_sideEffects.contains(effect)) {
      setState(() {
        _sideEffects.add(effect);
        _sideEffectController.clear();
      });
    }
  }

  void _removeSideEffect(String effect) {
    setState(() {
      _sideEffects.remove(effect);
    });
  }

  // Barcode Scanning Logic
  Future<void> _scanBarcode() async {
    try {
      // Check and request camera permission first
      final permissionService = PermissionService();
      final hasPermission = await permissionService.requestCameraPermission();
      
      if (!hasPermission) {
        if (mounted) {
          await PermissionDialog.showCameraPermission(
            context,
            onGrant: () async {
              final granted = await permissionService.requestCameraPermission();
              if (granted && mounted) {
                await _scanBarcode();
              }
            },
            onDeny: () {},
          );
        }
        return;
      }
      
      // Reuse camera service to get image
      final image = await _cameraService.captureFromCamera();
      if (image == null) return;
      
      // Scan the image
      final code = await _barcodeService.scanFile(image.path);
      if (code != null) {
        setState(() {
          _scannedBarcode = code;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(AppLocalizations.of(context)!.barcodeScanned(code)), backgroundColor: AppColors.successGreen),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(AppLocalizations.of(context)!.noBarcodeFound)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorWithMessage(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsyncValue = ref.watch(doctorListProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEnrichingData)
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: LinearProgressIndicator(),
            ),
          // AI OCR Section - Redesigned
          _buildAIOCRSection(context),
          const SizedBox(height: 20),
          // Interaction Check Alert
          _buildInteractionCheckAlert(context),
          const SizedBox(height: 20),
          // Details Section Header
          Text(
            AppLocalizations.of(context)!.tabDetails,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildFormField(
            context,
            label: AppLocalizations.of(context)!.medicineNameLabel,
            controller: _nameController,
            hintText: AppLocalizations.of(context)!.medicineNameHint,
            validator: (value) {
              if (value == null || value.isEmpty) {
                if (_capturedImage != null) {
                  return null;
                }
                return AppLocalizations.of(context)!.medicineNameRequired;
              }
              return null;
            },
            showCheckIcon: _nameController.text.isNotEmpty,
            suffixIcon: IconButton(
              icon: Icon(Icons.qr_code_scanner, color: _scannedBarcode != null ? AppColors.successGreen : AppColors.primaryGreen),
              tooltip: AppLocalizations.of(context)!.scanBarcode,
              onPressed: _scanBarcode,
            ),
          ),
          if (_scannedBarcode != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                AppLocalizations.of(context)!.barcodeLabel(_scannedBarcode!),
                style: TextStyle(fontSize: 12, color: AppColors.successGreen, fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 16),
          _buildFormField(
            context,
            label: AppLocalizations.of(context)!.strengthLabel,
            controller: _strengthController,
            hintText: AppLocalizations.of(context)!.strengthHint,
            showCheckIcon: _strengthController.text.isNotEmpty,
          ),
          const SizedBox(height: 16),
          // Dosage and Unit Row
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  context,
                  label: AppLocalizations.of(context)!.dosageLabel,
                  controller: _dosageController,
                  hintText: '10',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.dosageRequired;
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  context,
                  label: AppLocalizations.of(context)!.selectUnit,
                  controller: TextEditingController(text: AppLocalizations.of(context)!.unitMg),
                  hintText: AppLocalizations.of(context)!.unitMg,
                  readOnly: true,
                  onTap: () {
                    // Show unit picker dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.selectUnit),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppLocalizations.of(context)!.unitMg,
                            AppLocalizations.of(context)!.unitG,
                            AppLocalizations.of(context)!.unitMl,
                            AppLocalizations.of(context)!.unitUnits,
                            AppLocalizations.of(context)!.unitTablets,
                            AppLocalizations.of(context)!.unitCapsules,
                          ].map((unit) => ListTile(
                                    title: Text(unit),
                                    onTap: () {
                                      Navigator.pop(context);
                                      // Update unit if controller exists
                                    },
                                  ))
                              .toList(),
                        ),
                      ),
                    );
                  },
                  suffixIcon: const Icon(Icons.expand_more),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Form Type Selector - Horizontal Chips
          _buildFormTypeSelector(context),
          const SizedBox(height: 20),
          // Divider
          Container(
            height: 1,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderLight(context)
                : AppColors.borderLight(context),
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          // Schedule Section
          Text(
            AppLocalizations.of(context)!.schedule,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          // Frequency Toggle
          _buildFrequencyToggle(context),
          const SizedBox(height: 16),
          // Time Picker Section
          _buildTimePickerSection(context),
          const SizedBox(height: 16),
          
          // Doctor Selection
          Text(
            AppLocalizations.of(context)!.prescribingDoctorLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          doctorsAsyncValue.when(
            data: (doctors) {
               final items = [
                 DropdownMenuItem<String>(value: null, child: Text(AppLocalizations.of(context)!.noneOption)),
                 ...doctors.map((d) => DropdownMenuItem<String>(
                   value: d.id,
                   child: Text(AppLocalizations.of(context)!.doctorDisplayFormat(d.name, d.specialization)),
                 )),
               ];
               
               if (_selectedDoctorId != null && !doctors.any((d) => d.id == _selectedDoctorId)) {
                 _selectedDoctorId = null;
               }

               return DropdownButtonFormField<String?>(
                initialValue: _selectedDoctorId,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.selectDoctorHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                items: items,
                onChanged: (value) => setState(() => _selectedDoctorId = value),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text(AppLocalizations.of(context)!.doctorLoadError(e), style: TextStyle(color: AppColors.errorRed)),
          ),
          // Add Doctor Shortcut
           Align(
             alignment: AlignmentDirectional.centerEnd,
             child: TextButton.icon(
               onPressed: () async {
                 final newDoctorId = await Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => const AddDoctorScreen()),
                 );
                 
                 if (newDoctorId != null && mounted) {
                   setState(() {
                     _selectedDoctorId = newDoctorId;
                   });
                 }
               },
               icon: const Icon(Icons.add, size: 18),
               label: Text(AppLocalizations.of(context)!.addDoctorTitle), 
             ),
           ),
          
          const SizedBox(height: 16),
          
          // Divider
          Container(
            height: 1,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderLight(context)
                : AppColors.borderLight(context),
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          // Refill Reminder Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.refillReminderLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.notifyLowStock,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              CustomToggleSwitch(
                value: _refillReminderEnabled,
                onChanged: (value) {
                  setState(() {
                    _refillReminderEnabled = value;
                    if (!value) {
                      _refillReminderDays = 0;
                    } else if (_refillReminderDays == 0) {
                      _refillReminderDays = 7; // Default to 7 days
                    }
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Known Side Effects
          Text(
            AppLocalizations.of(context)!.sideEffectsLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sideEffects.map((effect) => InputChip(
              label: Text(effect),
              onDeleted: () => _removeSideEffect(effect),
              deleteIcon: const Icon(Icons.close, size: 16),
            )).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _sideEffectController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.addSideEffectHint,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onSubmitted: (_) => _addSideEffect(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primaryGreen,
                ),
                icon: const Icon(Icons.add),
                onPressed: _addSideEffect,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.notesLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.notesHint,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.note),
              suffixIcon: IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? AppColors.errorRed : AppColors.primaryGreen,
                ),
                onPressed: _toggleListening,
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  String name = _nameController.text;
                  if (name.isEmpty && _capturedImage != null) {
                    final timeStr = "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";
                    name = AppLocalizations.of(context)!.medicineAutoName(_selectedForm, timeStr);
                  }

                  widget.onSave(
                    name,
                    _strengthController.text,
                    _selectedForm,
                    _dosageController.text,
                    _selectedFrequency,
                    _notesController.text,
                    _capturedImage,
                    _selectedDoctorId,
                    _sideEffects,
                    _refillReminderDays,
                    _scannedBarcode,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBackground
                    : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: AppColors.primaryGreen.withValues(alpha: 0.4),
              ),
              child: Text(
                widget.initialMedicine == null ? AppLocalizations.of(context)!.addMedicineButton : AppLocalizations.of(context)!.updateMedicineButton,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addMedicineImageTitle),
        content: Text(AppLocalizations.of(context)!.chooseImageSource),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: Text(AppLocalizations.of(context)!.cameraLabel),
            onPressed: () {
              Navigator.pop(context);
              _captureFromCamera();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.photo_library),
            label: Text(AppLocalizations.of(context)!.galleryLabel),
            onPressed: () {
              Navigator.pop(context);
              _pickFromGallery();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _captureFromCamera() async {
    try {
      // Check and request camera permission first
      final permissionService = PermissionService();
      final hasPermission = await permissionService.requestCameraPermission();
      
      if (!hasPermission) {
        if (mounted) {
          await PermissionDialog.showCameraPermission(
            context,
            onGrant: () async {
              final granted = await permissionService.requestCameraPermission();
              if (granted && mounted) {
                await _captureFromCamera();
              }
            },
            onDeny: () {},
          );
        }
        return;
      }
      
      final image = await _cameraService.captureFromCamera();
      if (image != null) {
        setState(() {
          _capturedImage = image;
        });
        await _processImageWithOCR(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.captureFailed(e))),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final image = await _cameraService.pickFromGallery();
      if (image != null) {
        setState(() {
          _capturedImage = image;
        });
        await _processImageWithOCR(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.pickFailed(e))),
        );
      }
    }
  }

  Future<void> _processImageWithOCR(File image) async {
    try {
      final text = await _ocrService.extractText(image);
      final result = await _ocrService.parseMedicineDetails(text);
      
      if (result.hasAnyData) {
        if (result.name != null && _nameController.text.isEmpty) {
          _nameController.text = result.name!;
        }
        if (result.strength != null && _strengthController.text.isEmpty) {
          _strengthController.text = result.strength!;
        }
        if (result.batchNumber != null && _batchNumberController.text.isEmpty) {
          _batchNumberController.text = result.batchNumber!;
        }
        
        // Smart AI Enrichment
        if (result.name != null) {
          _performSmartEnrichment(result.name!);
        }

        // Translation: If locale is Arabic and we have raw text
        if (mounted) {
           final locale = Localizations.localeOf(context).languageCode;
           if (locale == 'ar' && result.rawText.isNotEmpty) {
              _translateExtractedText(result.rawText);
           }
        }

        if (result.manufacturer != null && _manufacturerController.text.isEmpty) {
          _manufacturerController.text = result.manufacturer!;
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.extractedText(result.name ?? "medicine details")),
              backgroundColor: AppColors.successGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.extractFailed),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorLabel(e.toString())),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      // OCR processing complete
    }
  }

  Future<void> _translateExtractedText(String text) async {
    try {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.translating)),
          );
        }
        
        // Assume extracted text is English for now (ML Kit can detect language, but for MVP simplifying)
        final translated = await _translationService.translate(
           text: text, 
           sourceLanguage: 'en', 
           targetLanguage: 'ar'
        );
        
        if (translated != null && translated.isNotEmpty) {
           if (mounted) {
             setState(() {
               if (_notesController.text.isNotEmpty) {
                 _notesController.text += "\n\n${AppLocalizations.of(context)!.translationLabel}\n$translated";
               } else {
                 _notesController.text = translated;
               }
             });
           }
        }
    } catch (e) {
      Logger.error("Translation failed: $e");
    }
  }


  Future<void> _performSmartEnrichment(String medicineName) async {
    setState(() => _isEnrichingData = true);
    
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.aiEnrichmentInProgress),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
      }

      // Detect language primarily from locale
      final locale = Localizations.localeOf(context).languageCode;
      
      final remoteConfig = RemoteConfigService();
      final apiKey = remoteConfig.getGeminiApiKey();
      
      if (apiKey.isEmpty) {
        Logger.warn('Gemini API Key missing for enrichment');
        return;
      }

      final details = await _geminiService.getMedicineDetails(medicineName, language: locale, apiKey: apiKey);

      if (!mounted) return;

      if (details.isNotEmpty) {
        setState(() {
          // Add Side Effects
          if (details['side_effects'] != null) {
            final List<dynamic> effects = details['side_effects'];
            for (var effect in effects) {
              final strEffect = effect.toString();
              if (!_sideEffects.contains(strEffect)) {
                _sideEffects.add(strEffect);
              }
            }
          }

          // Add Common Uses to Notes
          if (details['common_uses'] != null) {
            final List<dynamic> uses = details['common_uses'];
            final usesText = "\n\n${AppLocalizations.of(context)!.commonUsesLabel}\n- ${uses.join('\n- ')}";
            
            if (_notesController.text.isEmpty) {
              _notesController.text = usesText.trim();
            } else if (!_notesController.text.contains(usesText.trim())) {
              _notesController.text += usesText;
            }
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.aiEnrichmentSuccess),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      Logger.error('Smart Enrichment Failed: $e');
    } finally {
      if (mounted) setState(() => _isEnrichingData = false);
    }
  }

  Widget _buildAIOCRSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderDark(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Container
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.textTertiary(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: _capturedImage != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.file(
                            _capturedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: AppColors.shadowColor(context),
                            child: IconButton(
                              icon: Icon(AppIcons.close(), color: AppColors.darkTextPrimary, size: 20),
                              onPressed: () => setState(() => _capturedImage = null),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor(context).withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryGreen.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.3),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.center_focus_strong,
                          color: AppColors.primaryGreen,
                          size: 24,
                        ),
                      ),
                    ),
            ),
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.scanLabel,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.primaryGreen.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: AppColors.textSecondary(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'AI-Powered',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Use AI to auto-fill details from your medication packaging.',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _captureFromCamera,
                        icon: const Icon(Icons.photo_camera, size: 18),
                        label: Text(AppLocalizations.of(context)!.takePhoto),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.backgroundColor(context),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                          shadowColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickFromGallery,
                        icon: const Icon(Icons.image, size: 18),
                        label: Text(AppLocalizations.of(context)!.upload),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary(context),
                          side: BorderSide(color: AppColors.borderDark(context)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionCheckAlert(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Stack(
        children: [
          // Background Icon
          Positioned(
            top: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.verified_user,
                size: 48,
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.interactionCheckActive,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.noKnownConflicts,
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
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () {
                    _showInteractionDetails(context);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.viewDetails,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: AppColors.primaryGreen,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormTypeSelector(BuildContext context) {
    final formTypes = [
      {'value': 'tablet', 'label': 'Pill', 'icon': Icons.medication},
      {'value': 'liquid', 'label': AppLocalizations.of(context)!.liquidForm, 'icon': Icons.water_drop},
      {'value': 'injection', 'label': AppLocalizations.of(context)!.injectionForm, 'icon': Icons.medical_services},
      {'value': 'drops', 'label': AppLocalizations.of(context)!.drops, 'icon': Icons.visibility},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Form',
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: formTypes.map((type) {
              final isSelected = _selectedForm == type['value'];
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type['icon'] as IconData,
                        size: 18,
                        color: isSelected
                            ? AppColors.textPrimary(context)
                            : AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 4),
                      Text(type['label'] as String),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedForm = type['value'] as String);
                    }
                  },
                  selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                  backgroundColor: AppColors.surfaceColor(context),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.borderDark(context),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.textPrimary(context)
                        : AppColors.textSecondary(context),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyToggle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final frequencies = ['daily', 'weekly', 'as_needed'];
    final frequencyLabels = {
      'daily': l10n.dailyFrequency,
      'weekly': l10n.weeklyFrequency,
      'as_needed': l10n.asNeededFrequency,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.frequencyLabel,
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderDark(context)),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: frequencies.map((freq) {
              final isSelected = _selectedFrequency == freq;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFrequency = freq),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.borderDark(context)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      frequencyLabels[freq]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.textPrimary(context)
                            : AppColors.textSecondary(context),
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
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

  Widget _buildTimePickerSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.timesLabel,
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        // Display selected times
        if (_selectedTimes.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedTimes.map((time) {
              return Chip(
                label: Text(time.format(context)),
                onDeleted: () {
                  setState(() {
                    _selectedTimes.remove(time);
                  });
                },
                deleteIcon: Icon(Icons.close, size: 18),
              );
            }).toList(),
          ),
        if (_selectedTimes.isNotEmpty) const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) {
              setState(() {
                if (!_selectedTimes.contains(picked)) {
                  _selectedTimes.add(picked);
                  _selectedTimes.sort((a, b) {
                    final aMinutes = a.hour * 60 + a.minute;
                    final bMinutes = b.hour * 60 + b.minute;
                    return aMinutes.compareTo(bMinutes);
                  });
                }
              });
            }
          },
          icon: const Icon(Icons.add_circle),
          label: Text(AppLocalizations.of(context)!.addTime),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary(context),
            side: BorderSide(
              color: AppColors.textSecondary(context).withValues(alpha: 0.5),
              style: BorderStyle.solid,
            ),
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  void _showInteractionDetails(BuildContext context) async {
    if (_interactionResult == null || !_interactionResult!.hasInteractions) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noInteractionsDetected),
        ),
      );
      return;
    }

    // Get all medicines to show interactions
    final medicinesAsync = ref.read(medicinesStreamProvider);
    medicinesAsync.when(
      data: (medicines) {
        // Create a temporary medicine model for the current form
        final currentMedicine = MedicineModel(
          id: '',
          userId: '',
          name: _nameController.text,
          strength: _strengthController.text,
          form: _selectedForm,
          dosage: _dosageController.text,
          frequency: _selectedFrequency,
          notes: _notesController.text,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Filter out the current medicine if it exists in the list
        final otherMedicines = medicines.where((m) => m.name != currentMedicine.name).toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MedicineInteractionWarningScreen(
              medicine: currentMedicine,
              existingMedicines: otherMedicines,
            ),
          ),
        );
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.loadingMedicines)),
        );
      },
      error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorOccurred(e)),
            backgroundColor: AppColors.errorRed,
          ),
        );
      },
    );
  }

  Widget _buildFormField(
    BuildContext context, {
    String? label,
    TextEditingController? controller,
    String? hintText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    bool showCheckIcon = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 10),
        ],
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppColors.textSecondary(context).withValues(alpha: 0.6),
              fontSize: 15,
            ),
            filled: true,
            fillColor: AppColors.cardColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.borderLight(context),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.borderLight(context),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryGreen,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.errorRed,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.errorRed,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            constraints: const BoxConstraints(
              minHeight: 52,
            ),
            suffixIcon: showCheckIcon
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryGreen,
                      size: 22,
                    ),
                  )
                : suffixIcon,
          ),
        ),
      ],
    );
  }
}
