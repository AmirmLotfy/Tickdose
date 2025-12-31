import 'package:tickdose/core/models/user_model.dart';
import 'package:tickdose/core/models/medicine_model.dart';

/// Service for health profile validation and medication safety checks
class HealthProfileService {
  static final HealthProfileService _instance = HealthProfileService._internal();
  factory HealthProfileService() => _instance;
  HealthProfileService._internal();

  /// Validate if medication is age-appropriate
  /// 
  /// [medicine] - Medicine to validate
  /// [user] - User with age information
  /// Returns true if appropriate, false otherwise with reason
  ValidationResult validateAgeAppropriateMedication({
    required MedicineModel medicine,
    required UserModel user,
  }) {
    if (user.age == null) {
      return ValidationResult(
        isValid: true,
        warning: 'Age not provided. Unable to verify age-appropriateness.',
      );
    }

    final age = user.age!;

    // Check for pediatric restrictions (some meds are 18+ only)
    final adultOnlyMedications = [
      'warfarin',
      'coumadin',
      'aspirin', // Low-dose aspirin generally safe, but check with doctor
    ];

    final medicineNameLower = medicine.name.toLowerCase();
    final isAdultOnly = adultOnlyMedications.any((med) => medicineNameLower.contains(med));

    if (age < 18 && isAdultOnly) {
      return ValidationResult(
        isValid: false,
        warning: 'This medication is typically not recommended for patients under 18 years old. Please consult with a healthcare provider.',
        severity: ValidationSeverity.high,
      );
    }

    // Check for geriatric considerations (65+)
    if (age >= 65) {
      // Some medications require dose adjustments for elderly
      final geriatricAdjustments = [
        'digoxin',
        'warfarin',
        'insulin',
      ];

      if (geriatricAdjustments.any((med) => medicineNameLower.contains(med))) {
        return ValidationResult(
          isValid: true,
          warning: 'This medication may require dose adjustment for patients 65 and older. Please ensure your doctor has adjusted the dosage.',
          severity: ValidationSeverity.medium,
        );
      }
    }

    return ValidationResult(isValid: true);
  }

  /// Check for allergy conflicts
  /// 
  /// [medicine] - Medicine to check
  /// [user] - User with allergy information
  /// Returns ValidationResult with conflict information
  ValidationResult checkAllergyConflicts({
    required MedicineModel medicine,
    required UserModel user,
  }) {
    if (user.allergies.isEmpty) {
      return ValidationResult(isValid: true);
    }

    final medicineNameLower = medicine.name.toLowerCase();
    final genericNameLower = medicine.genericName.toLowerCase().toLowerCase();
    
    // Check if medicine name or generic name contains any allergen
    for (final allergy in user.allergies) {
      final allergyLower = allergy.toLowerCase();
      
      // Direct name match
      if (medicineNameLower.contains(allergyLower) || genericNameLower.contains(allergyLower)) {
        return ValidationResult(
          isValid: false,
          warning: 'WARNING: This medicine contains or is related to "$allergy" which you are allergic to. DO NOT take this medication without consulting your doctor.',
          severity: ValidationSeverity.critical,
        );
      }

      // Common cross-allergies
      if (_checkCrossAllergies(allergyLower, medicineNameLower, genericNameLower)) {
        return ValidationResult(
          isValid: false,
          warning: 'WARNING: This medicine may cause cross-reaction with your "$allergy" allergy. Consult your doctor before taking.',
          severity: ValidationSeverity.high,
        );
      }
    }

    return ValidationResult(isValid: true);
  }

  /// Check for cross-allergies (e.g., penicillin and cephalosporins)
  bool _checkCrossAllergies(String allergy, String medicineName, String genericName) {
    final crossAllergyMap = {
      'penicillin': ['cephalosporin', 'amoxicillin', 'ampicillin'],
      'aspirin': ['ibuprofen', 'naproxen', 'nsaid'],
      'sulfa': ['sulfonamide', 'sulfamethoxazole'],
    };

    for (final entry in crossAllergyMap.entries) {
      if (allergy.contains(entry.key)) {
        for (final crossMed in entry.value) {
          if (medicineName.contains(crossMed) || genericName.contains(crossMed)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Calculate recommended dose based on age/weight
  /// 
  /// [medicine] - Medicine to calculate dose for
  /// [user] - User with age and weight information
  /// Returns suggested dose or null if calculation not possible
  String? calculateRecommendedDose({
    required MedicineModel medicine,
    required UserModel user,
  }) {
    // This is a simplified calculation - real medical apps should use proper dosing databases
    if (user.weight == null) {
      return null;
    }

    // final weight = user.weight!; // TODO: Use weight for dosage calculations
    final age = user.age;

    // Example: Calculate pediatric dose (simplified - NOT for real medical use)
    if (age != null && age < 18) {
      // Typical pediatric dosing is weight-based
      // This is a placeholder - actual calculations should use medical databases
      return 'Consult with pediatrician for weight-based dosing';
    }

    return null; // Standard adult dosing
  }

  /// Flag contraindications based on health conditions
  /// 
  /// [medicine] - Medicine to check
  /// [user] - User with health conditions
  /// Returns list of contraindication warnings
  List<String> flagContraindications({
    required MedicineModel medicine,
    required UserModel user,
  }) {
    final warnings = <String>[];

    if (user.healthConditions.isEmpty) {
      return warnings;
    }

    final medicineNameLower = medicine.name.toLowerCase();
    final genericNameLower = medicine.genericName.toLowerCase();

    // Check common contraindications
    for (final condition in user.healthConditions) {
      final conditionLower = condition.toLowerCase();

      // Diabetes + certain medications
      if (conditionLower.contains('diabetes')) {
        if (medicineNameLower.contains('steroid') || genericNameLower.contains('corticosteroid')) {
          warnings.add('This medication may affect blood sugar levels. Monitor closely if you have diabetes.');
        }
      }

      // Hypertension + NSAIDs
      if (conditionLower.contains('hypertension') || conditionLower.contains('high blood pressure')) {
        if (medicineNameLower.contains('ibuprofen') || 
            medicineNameLower.contains('naproxen') || 
            genericNameLower.contains('nsaid')) {
          warnings.add('NSAIDs may increase blood pressure. Use with caution if you have hypertension.');
        }
      }

      // Kidney disease
      if (conditionLower.contains('kidney') || conditionLower.contains('renal')) {
        if (medicineNameLower.contains('nsaid') || 
            genericNameLower.contains('nsaid') ||
            medicineNameLower.contains('aspirin')) {
          warnings.add('This medication may affect kidney function. Use with caution if you have kidney disease.');
        }
      }

      // Liver disease
      if (conditionLower.contains('liver') || conditionLower.contains('hepatic')) {
        warnings.add('This medication may affect liver function. Consult your doctor if you have liver disease.');
      }

      // Pregnancy (if applicable - would need gender check)
      if (conditionLower.contains('pregnant') || conditionLower.contains('pregnancy')) {
        warnings.add('Pregnancy warning: Consult your doctor before taking this medication during pregnancy.');
      }
    }

    return warnings;
  }

  /// Comprehensive validation combining all checks
  /// 
  /// Returns ValidationResult with all warnings and errors
  ComprehensiveValidationResult validateMedicineForUser({
    required MedicineModel medicine,
    required UserModel user,
  }) {
    final ageValidation = validateAgeAppropriateMedication(medicine: medicine, user: user);
    final allergyValidation = checkAllergyConflicts(medicine: medicine, user: user);
    final contraindications = flagContraindications(medicine: medicine, user: user);

    final allWarnings = <String>[];
    ValidationSeverity maxSeverity = ValidationSeverity.none;

    if (!ageValidation.isValid) {
      allWarnings.add(ageValidation.warning ?? 'Age validation failed');
      if (ageValidation.severity.index > maxSeverity.index) {
        maxSeverity = ageValidation.severity;
      }
    }

    if (!allergyValidation.isValid) {
      allWarnings.add(allergyValidation.warning ?? 'Allergy conflict detected');
      if (allergyValidation.severity.index > maxSeverity.index) {
        maxSeverity = allergyValidation.severity;
      }
    }

    allWarnings.addAll(contraindications);

    return ComprehensiveValidationResult(
      isValid: ageValidation.isValid && allergyValidation.isValid,
      warnings: allWarnings,
      severity: maxSeverity,
      recommendedDose: calculateRecommendedDose(medicine: medicine, user: user),
    );
  }
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final String? warning;
  final ValidationSeverity severity;

  ValidationResult({
    required this.isValid,
    this.warning,
    this.severity = ValidationSeverity.none,
  });
}

/// Comprehensive validation result
class ComprehensiveValidationResult {
  final bool isValid;
  final List<String> warnings;
  final ValidationSeverity severity;
  final String? recommendedDose;

  ComprehensiveValidationResult({
    required this.isValid,
    required this.warnings,
    required this.severity,
    this.recommendedDose,
  });
}

/// Validation severity levels
enum ValidationSeverity {
  none,
  low,
  medium,
  high,
  critical,
}
