import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:tickdose/core/services/gemini_service.dart';
import 'package:tickdose/core/services/remote_config_service.dart';
import 'package:tickdose/core/utils/logger.dart';

class MedicineOcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final GeminiService _geminiService = GeminiService();

  /// Extract all text from an image
  Future<String> extractText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      throw Exception('Failed to extract text: $e');
    }
  }

  /// Parse medicine details from extracted text or directly from image using AI
  Future<MedicineOcrResult> parseMedicineDetails(String text, {File? imageFile}) async {
    // 1. Try Gemini Vision first (if image is provided and key is available)
    if (imageFile != null) {
      try {
        final apiKey = RemoteConfigService().getGeminiApiKey();
        if (apiKey.isNotEmpty) {
          final geminiResult = await _geminiService.extractMedicineInfo(imageFile, apiKey: apiKey);
          
          if (geminiResult != null) {
            Logger.info('Gemini Vision OCR successful', tag: 'MedicineOCR');
            
            // Parse expiry date
            DateTime? expiry;
            if (geminiResult['expiry_date'] != null) {
              expiry = DateTime.tryParse(geminiResult['expiry_date']);
            }

            return MedicineOcrResult(
              name: geminiResult['name'],
              strength: geminiResult['strength'],
              expiryDate: expiry,
              batchNumber: geminiResult['batch_number'],
              manufacturer: geminiResult['manufacturer'],
              rawText: text, // Keep raw ML Kit text as backup/context
              source: 'Gemini Vision 2.5',
            );
          }
        }
      } catch (e) {
        Logger.warn('Gemini Vision OCR failed (falling back to regex): $e', tag: 'MedicineOCR');
      }
    }

    // 2. Fallback to Regex/ML Kit extraction
    Logger.info('Using Regex fallback for OCR', tag: 'MedicineOCR');
    final name = _extractMedicineName(text);
    final strength = _extractStrength(text);
    final expiryDate = _extractExpiryDate(text);
    final batchNumber = _extractBatchNumber(text);
    final manufacturer = _extractManufacturer(text);

    return MedicineOcrResult(
      name: name,
      strength: strength,
      expiryDate: expiryDate,
      batchNumber: batchNumber,
      manufacturer: manufacturer,
      rawText: text,
      source: 'Local ML Kit',
    );
  }

  /// Extract medicine name (usually first large/capitalized text)
  String? _extractMedicineName(String text) {
    final lines = text.split('\n');
    
    for (final line in lines) {
      final trimmed = line.trim();
      
      // Skip empty lines and common labels
      if (trimmed.isEmpty || _isCommonLabel(trimmed)) {
        continue;
      }
      
      // Look for all-caps words (medicine names are often capitalized)
      if (trimmed.length > 3 && trimmed.toUpperCase() == trimmed) {
        // Check if it contains letters (not just numbers)
        if (RegExp(r'[A-Z]').hasMatch(trimmed)) {
          return trimmed;
        }
      }
    }
    
    // Fallback: return first non-label line
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.length > 3 && !_isCommonLabel(trimmed)) {
        return trimmed;
      }
    }
    
    return null;
  }

  /// Extract strength (e.g., "500mg", "10ml")
  String? _extractStrength(String text) {
    // Patterns: "500mg", "500 mg", "10mg/5ml", "1g"
    final patterns = [
      RegExp(r'(\d+(?:\.\d+)?)\s*(mg|g|ml|mcg|iu|units?)(?:/\d+\s*(?:mg|g|ml))?', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(0);
      }
    }
    
    return null;
  }

  /// Extract expiry date
  DateTime? _extractExpiryDate(String text) {
    // Patterns: "EXP: 12/2025", "EXP 12-2025", "Expiry: Dec 2025", "12/25"
    final patterns = [
      RegExp(r'EXP[:\s]*(\d{2})[\/\-](\d{4})', caseSensitive: false),
      RegExp(r'EXPIRY[:\s]*(\d{2})[\/\-](\d{4})', caseSensitive: false),
      RegExp(r'(\d{2})[\/\-](\d{2,4})', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        var month = int.tryParse(match.group(1)!);
        var yearStr = match.group(2)!;
        
        // Handle 2-digit years (e.g., "12/25" -> 2025)
        var year = int.tryParse(yearStr);
        if (year != null && year < 100) {
          year += 2000;
        }
        
        if (month != null && year != null && month >= 1 && month <= 12) {
          return DateTime(year, month);
        }
      }
    }
    
    return null;
  }

  /// Extract batch/lot number
  String? _extractBatchNumber(String text) {
    // Patterns: "Batch: ABC123", "LOT: 123456", "B.No: ABC123"
    final patterns = [
      RegExp(r'BATCH[:\s]*([A-Z0-9]+)', caseSensitive: false),
      RegExp(r'LOT[:\s]*([A-Z0-9]+)', caseSensitive: false),
      RegExp(r'B\.?\s*NO\.?[:\s]*([A-Z0-9]+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1);
      }
    }
    
    return null;
  }

  /// Extract manufacturer
  String? _extractManufacturer(String text) {
    // Patterns: "Mfg: Company Name", "Manufactured by: Company"
    final patterns = [
      RegExp(r'MFG[:\s]*(.+?)(?:\n|$)', caseSensitive: false),
      RegExp(r'MANUFACTURED BY[:\s]*(.+?)(?:\n|$)', caseSensitive: false),
      RegExp(r'MANUFACTURER[:\s]*(.+?)(?:\n|$)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }
    
    return null;
  }

  /// Check if text is a common label (not medicine name)
  bool _isCommonLabel(String text) {
    final labels = [
      'MFG', 'EXP', 'BATCH', 'LOT', 'MRP', 'PRICE',
      'MANUFACTURED', 'EXPIRY', 'DATE', 'TABLET', 'CAPSULE',
      'SYRUP', 'SUSPENSION', 'CREAM', 'OINTMENT'
    ];
    
    final upperText = text.toUpperCase();
    return labels.any((label) => upperText.contains(label));
  }

  void dispose() {
    _textRecognizer.close();
  }
}

/// Result of OCR extraction
class MedicineOcrResult {
  final String? name;
  final String? strength;
  final DateTime? expiryDate;
  final String? batchNumber;
  final String? manufacturer;
  final String rawText;
  final String source; // 'Gemini Vision 2.5' or 'Local ML Kit'

  MedicineOcrResult({
    this.name,
    this.strength,
    this.expiryDate,
    this.batchNumber,
    this.manufacturer,
    required this.rawText,
    this.source = 'Local ML Kit',
  });

  bool get hasAnyData =>
      name != null ||
      strength != null ||
      expiryDate != null ||
      batchNumber != null ||
      manufacturer != null;
}
