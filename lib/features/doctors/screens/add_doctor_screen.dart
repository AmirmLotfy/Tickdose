import 'package:flutter/material.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:tickdose/core/services/doctor_service.dart';
import 'package:tickdose/features/doctors/models/doctor_model.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

class AddDoctorScreen extends ConsumerStatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  ConsumerState<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends ConsumerState<AddDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _uuid = const Uuid();
  
  String _phoneNumber = '';
  String _dialCode = '';
  String? _specialization;
  bool _isLoading = false;

  final List<String> _specializations = [
    'General Practitioner',
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Psychiatrist',
    'Endocrinologist',
    'Pediatrician',
    'Surgeon',
    'Dentist',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveDoctor() async {
    if (!_formKey.currentState!.validate()) return;
    if (_phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.phoneRequired)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not authenticated');

      final doctorId = _uuid.v4();
      final doctor = Doctor(
        id: doctorId,
        userId: user.uid,
        name: _nameController.text.trim(),
        phoneNumber: _phoneNumber,
        dialCode: _dialCode,
        specialization: _specialization ?? 'General',
        createdAt: DateTime.now(),
      );

      final doctorService = DoctorService(user.uid);
      await doctorService.addDoctor(doctor);

      if (mounted) {
        Navigator.pop(context, doctorId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.doctorAddedSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.doctorAddError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addDoctorTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.doctorNameLabel,
                  hintText: AppLocalizations.of(context)!.doctorNameHint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.doctorNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _specialization,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.specializationLabel,
                  border: OutlineInputBorder(),
                ),
                items: _specializations.map((spec) {
                  String label = spec;
                  final l10n = AppLocalizations.of(context)!;
                  if (spec == 'General Practitioner') {
                    label = l10n.specializationGeneral;
                  } else if (spec == 'Cardiologist') {
                    label = l10n.specializationCardiologist;
                  } else if (spec == 'Dermatologist') {
                    label = l10n.specializationDermatologist;
                  } else if (spec == 'Neurologist') {
                    label = l10n.specializationNeurologist;
                  } else if (spec == 'Psychiatrist') {
                    label = l10n.specializationPsychiatrist;
                  } else if (spec == 'Endocrinologist') {
                    label = l10n.specializationEndocrinologist;
                  } else if (spec == 'Pediatrician') {
                    label = l10n.specializationPediatrician;
                  } else if (spec == 'Surgeon') {
                    label = l10n.specializationSurgeon;
                  } else if (spec == 'Dentist') {
                    label = l10n.specializationDentist;
                  } else if (spec == 'Other') {
                    label = l10n.specializationOther;
                  }
                  
                  return DropdownMenuItem(
                    value: spec,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _specialization = value),
                validator: (value) => value == null ? AppLocalizations.of(context)!.specializationRequired : null,
              ),
              const SizedBox(height: 16),
              
              IntlPhoneField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.phoneNumberLabel,
                  border: const OutlineInputBorder(),
                ),
                initialCountryCode: 'US',
                onChanged: (phone) {
                  _phoneNumber = phone.completeNumber;
                  _dialCode = phone.countryCode;
                },
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveDoctor,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(AppLocalizations.of(context)!.addDoctorTitle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
