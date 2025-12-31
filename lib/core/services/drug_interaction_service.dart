import 'package:tickdose/core/models/medicine_model.dart';
import 'package:tickdose/core/services/gemini_service.dart';
import 'package:tickdose/core/services/remote_config_service.dart';
import 'package:tickdose/core/utils/logger.dart';

/// Service for checking drug interactions
class DrugInteractionService {
  static final DrugInteractionService _instance = DrugInteractionService._internal();
  factory DrugInteractionService() => _instance;
  DrugInteractionService._internal();

  final GeminiService _geminiService = GeminiService();
  final RemoteConfigService _remoteConfig = RemoteConfigService();

  // Local cache for interaction results (to avoid repeated API calls)
  final Map<String, DrugInteractionResult> _interactionCache = {};

  /// Check medicine-medicine interactions
  /// 
  /// [medicines] - List of medicines to check for interactions
  /// Returns DrugInteractionResult with interaction details
  Future<DrugInteractionResult> checkMedicineInteractions({
    required List<MedicineModel> medicines,
  }) async {
    if (medicines.isEmpty || medicines.length == 1) {
      return DrugInteractionResult.none();
    }

    try {
      // Generate cache key from medicine IDs
      final cacheKey = medicines.map((m) => m.id).toList()..sort();
      final cacheKeyStr = cacheKey.join('_');

      // Check cache first
      if (_interactionCache.containsKey(cacheKeyStr)) {
        Logger.info('Using cached interaction result', tag: 'DrugInteraction');
        return _interactionCache[cacheKeyStr]!;
      }

      // Use Gemini API to check interactions
      final apiKey = _remoteConfig.getGeminiApiKey();
      if (apiKey.isEmpty) {
        Logger.warn('Gemini API key not available, using basic local checks', tag: 'DrugInteraction');
        return _checkLocalInteractions(medicines);
      }

      final geminiResult = await _geminiService.checkDrugInteractions(
        medicines,
        apiKey: apiKey,
      );

      // Convert Gemini result to our format
      final result = _convertGeminiResult(geminiResult, medicines);

      // Cache the result
      _interactionCache[cacheKeyStr] = result;

      return result;
    } catch (e) {
      Logger.error('Error checking medicine interactions: $e', tag: 'DrugInteraction');
      // Fallback to local checks
      return _checkLocalInteractions(medicines);
    }
  }

  /// Basic local interaction checking (fallback when API unavailable)
  DrugInteractionResult _checkLocalInteractions(List<MedicineModel> medicines) {
    final interactions = <InteractionDetail>[];
    
    // Known interaction patterns
    final medicineNames = medicines.map((m) => m.name.toLowerCase()).toList();

    // Check for blood thinner interactions
    final bloodThinners = ['warfarin', 'aspirin', 'clopidogrel', 'heparin', 'apixaban', 'rivaroxaban'];
    final foundThinners = medicineNames.where((name) => 
      bloodThinners.any((thinner) => name.contains(thinner))
    ).toList();

    if (foundThinners.length > 1) {
      interactions.add(InteractionDetail(
        medicineA: medicines.firstWhere((m) => medicineNames.contains(m.name.toLowerCase())).name,
        medicineB: medicines.firstWhere((m) => m.name.toLowerCase() != foundThinners[0]).name,
        severity: InteractionSeverity.high,
        description: 'Multiple blood thinners may increase risk of bleeding. Monitor closely.',
        recommendation: 'Consult your doctor before taking these medications together.',
      ));
    }

    // Check for NSAID + ACE inhibitor interactions
    final nsaids = ['ibuprofen', 'naproxen', 'diclofenac', 'nsaid'];
    final aceInhibitors = ['lisinopril', 'enalapril', 'ramipril', 'ace inhibitor'];
    
    final hasNSAID = medicineNames.any((name) => nsaids.any((nsaid) => name.contains(nsaid)));
    final hasACE = medicineNames.any((name) => aceInhibitors.any((ace) => name.contains(ace)));

    if (hasNSAID && hasACE) {
      interactions.add(InteractionDetail(
        medicineA: medicines.firstWhere((m) => nsaids.any((nsaid) => m.name.toLowerCase().contains(nsaid))).name,
        medicineB: medicines.firstWhere((m) => aceInhibitors.any((ace) => m.name.toLowerCase().contains(ace))).name,
        severity: InteractionSeverity.moderate,
        description: 'NSAIDs may reduce the effectiveness of ACE inhibitors.',
        recommendation: 'Take these medications as prescribed, but inform your doctor.',
      ));
    }

    if (interactions.isEmpty) {
      return DrugInteractionResult.none();
    }

    final maxSeverity = interactions.map((i) => i.severity).reduce((a, b) => 
      a.index > b.index ? a : b
    );

    return DrugInteractionResult(
      hasInteractions: true,
      interactions: interactions,
      severity: maxSeverity,
      recommendations: interactions.map((i) => i.recommendation).toList(),
      shouldConsultDoctor: maxSeverity.index >= InteractionSeverity.moderate.index,
    );
  }

  /// Check medicine-food interactions
  /// 
  /// [medicine] - Medicine to check
  /// Returns list of food interaction warnings
  Future<List<FoodInteraction>> checkFoodInteractions({
    required MedicineModel medicine,
  }) async {
    final interactions = <FoodInteraction>[];
    final medicineNameLower = medicine.name.toLowerCase();
    final genericNameLower = medicine.genericName.toLowerCase();

    // Grapefruit interactions
    final grapefruitMeds = ['warfarin', 'atorvastatin', 'simvastatin', 'felodipine', 'nifedipine', 'amlodipine'];
    if (grapefruitMeds.any((med) => medicineNameLower.contains(med) || genericNameLower.contains(med))) {
      interactions.add(FoodInteraction(
        food: 'Grapefruit',
        severity: InteractionSeverity.high,
        description: 'Grapefruit may increase the concentration of this medication in your blood.',
        recommendation: 'Avoid grapefruit and grapefruit juice while taking this medication.',
      ));
    }

    // Dairy interactions (tetracyclines)
    final tetracyclines = ['tetracycline', 'doxycycline', 'minocycline'];
    if (tetracyclines.any((med) => medicineNameLower.contains(med) || genericNameLower.contains(med))) {
      interactions.add(FoodInteraction(
        food: 'Dairy products',
        severity: InteractionSeverity.moderate,
        description: 'Dairy products may reduce the absorption of this medication.',
        recommendation: 'Take this medication 1-2 hours before or after consuming dairy products.',
      ));
    }

    // Alcohol interactions
    final alcoholMeds = ['metronidazole', 'disulfiram', 'warfarin', 'acetaminophen', 'paracetamol'];
    if (alcoholMeds.any((med) => medicineNameLower.contains(med) || genericNameLower.contains(med))) {
      interactions.add(FoodInteraction(
        food: 'Alcohol',
        severity: InteractionSeverity.high,
        description: 'Alcohol may interact with this medication and cause serious side effects.',
        recommendation: 'Avoid alcohol while taking this medication.',
      ));
    }

    return interactions;
  }

  /// Check medicine-alcohol interactions
  /// 
  /// [medicine] - Medicine to check
  /// Returns interaction warning if applicable
  Future<AlcoholInteraction?> checkAlcoholInteractions({
    required MedicineModel medicine,
  }) async {
    final alcoholInteractions = await checkFoodInteractions(medicine: medicine);
    final alcoholInteraction = alcoholInteractions.firstWhere(
      (i) => i.food.toLowerCase() == 'alcohol',
      orElse: () => FoodInteraction(
        food: 'Alcohol',
        severity: InteractionSeverity.none,
        description: '',
        recommendation: '',
      ),
    );

    if (alcoholInteraction.severity == InteractionSeverity.none) {
      return null;
    }

    return AlcoholInteraction(
      severity: alcoholInteraction.severity,
      description: alcoholInteraction.description,
      recommendation: alcoholInteraction.recommendation,
    );
  }

  /// Get interaction severity level
  /// 
  /// [interaction] - Interaction detail
  /// Returns severity enum
  InteractionSeverity getInteractionSeverity(InteractionDetail interaction) {
    return interaction.severity;
  }

  /// Convert Gemini service result to our detailed format
  DrugInteractionResult _convertGeminiResult(
    dynamic geminiResult,
    List<MedicineModel> medicines,
  ) {
    // If it's already our format, return as-is
    if (geminiResult is DrugInteractionResult) {
      return geminiResult;
    }

    // Convert from Gemini format (has List<String> interactions)
    final hasInteractions = geminiResult.hasInteractions ?? false;
    final interactionsList = geminiResult.interactions ?? <String>[];
    final severityStr = geminiResult.severity ?? 'none';
    final recommendations = geminiResult.recommendations ?? <String>[];
    final shouldConsult = geminiResult.consultDoctor ?? false;

    // Convert severity string to enum
    InteractionSeverity severity;
    switch (severityStr.toLowerCase()) {
      case 'severe':
      case 'critical':
        severity = InteractionSeverity.critical;
        break;
      case 'high':
        severity = InteractionSeverity.high;
        break;
      case 'moderate':
        severity = InteractionSeverity.moderate;
        break;
      case 'mild':
      case 'low':
        severity = InteractionSeverity.low;
        break;
      default:
        severity = InteractionSeverity.none;
    }

    // Parse interaction strings into InteractionDetail objects
    final interactions = <InteractionDetail>[];
    for (final interactionStr in interactionsList) {
      // Parse format: "[Medicine A] + [Medicine B]: [Severity] - [Description]"
      final parts = interactionStr.split(':');
      if (parts.length >= 2) {
        final medicinePart = parts[0].trim();
        final descriptionPart = parts.sublist(1).join(':').trim();
        
        final medicineMatch = RegExp(r'(.+?)\s+\+\s+(.+?)').firstMatch(medicinePart);
        if (medicineMatch != null) {
          interactions.add(InteractionDetail(
            medicineA: medicineMatch.group(1)?.trim() ?? '',
            medicineB: medicineMatch.group(2)?.trim() ?? '',
            severity: severity,
            description: descriptionPart,
            recommendation: recommendations.isNotEmpty ? recommendations.first : 'Consult your doctor.',
          ));
        }
      }
    }

    return DrugInteractionResult(
      hasInteractions: hasInteractions,
      interactions: interactions,
      severity: interactions.isNotEmpty 
          ? interactions.map((i) => i.severity).reduce((a, b) => a.index > b.index ? a : b)
          : severity,
      recommendations: recommendations,
      shouldConsultDoctor: shouldConsult,
    );
  }

  /// Clear interaction cache
  void clearCache() {
    _interactionCache.clear();
    Logger.info('Drug interaction cache cleared', tag: 'DrugInteraction');
  }
}

/// Drug interaction result
class DrugInteractionResult {
  final bool hasInteractions;
  final List<InteractionDetail> interactions;
  final InteractionSeverity severity;
  final List<String> recommendations;
  final bool shouldConsultDoctor;

  DrugInteractionResult({
    required this.hasInteractions,
    required this.interactions,
    required this.severity,
    required this.recommendations,
    required this.shouldConsultDoctor,
  });

  factory DrugInteractionResult.none() {
    return DrugInteractionResult(
      hasInteractions: false,
      interactions: [],
      severity: InteractionSeverity.none,
      recommendations: [],
      shouldConsultDoctor: false,
    );
  }

  factory DrugInteractionResult.error() {
    return DrugInteractionResult(
      hasInteractions: false,
      interactions: [],
      severity: InteractionSeverity.none,
      recommendations: ['Unable to check interactions. Please consult your doctor.'],
      shouldConsultDoctor: true,
    );
  }
}

/// Interaction detail
class InteractionDetail {
  final String medicineA;
  final String medicineB;
  final InteractionSeverity severity;
  final String description;
  final String recommendation;

  InteractionDetail({
    required this.medicineA,
    required this.medicineB,
    required this.severity,
    required this.description,
    required this.recommendation,
  });
}

/// Food interaction
class FoodInteraction {
  final String food;
  final InteractionSeverity severity;
  final String description;
  final String recommendation;

  FoodInteraction({
    required this.food,
    required this.severity,
    required this.description,
    required this.recommendation,
  });
}

/// Alcohol interaction
class AlcoholInteraction {
  final InteractionSeverity severity;
  final String description;
  final String recommendation;

  AlcoholInteraction({
    required this.severity,
    required this.description,
    required this.recommendation,
  });
}

/// Interaction severity levels
enum InteractionSeverity {
  none,
  low,
  moderate,
  high,
  critical,
}
