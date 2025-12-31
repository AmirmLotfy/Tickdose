import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/core/models/medicine_model.dart';
import 'package:tickdose/core/models/user_model.dart';
import 'package:tickdose/core/services/api_rate_limiter.dart';
import 'package:tickdose/core/services/api_error.dart';
import 'package:tickdose/core/services/api_analytics_service.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  // Gemini 3 stable models - Latest stable production models (December 2025)
  // Using only stable models from Gemini 3 family (verified stable as of December 2025)
  // 
  // Model Capabilities:
  // - gemini-3-flash: Fast, cost-effective, suitable for chat, OCR, quest generation
  //   - Context window: Up to 1M tokens
  //   - Best for: Real-time responses, image understanding, general tasks
  // 
  // - gemini-3-pro: Advanced reasoning, multimodal understanding, complex problem-solving
  //   - Context window: Up to 1M tokens  
  //   - Best for: Symptom analysis, drug interactions, complex medical reasoning
  //   - Supports: Text, images, video, audio, PDFs
  static const _defaultModel = 'gemini-3-flash'; // Stable Gemini 3 Flash: Fast, cost-effective
  static const _proModel = 'gemini-3-pro'; // Stable Gemini 3 Pro: Advanced reasoning for complex tasks
  final ApiRateLimiter _rateLimiter = ApiRateLimiter();
  final ApiAnalyticsService _analytics = ApiAnalyticsService();

  // Response caching for identical queries
  final Map<String, _CacheEntry> _responseCache = {};
  static const _cacheMaxAge = Duration(hours: 24); // Cache TTL: 24 hours for medical data
  static const _maxCacheSize = 100; // Maximum cache entries

  // Retry configuration
  static const _maxRetries = 3;
  static const _baseRetryDelay = Duration(seconds: 1);

  // Chat Session Management
  List<Content>? _currentChatHistory;
  UserModel? _currentUserProfile;
  
  /// Start or reset a chat session with system context
  void startChatSession({UserModel? userProfile}) {
    _currentChatHistory = [];
    _currentUserProfile = userProfile;
    Logger.info('Chat session started', tag: 'GeminiService');
  }
  
  /// Get current chat history for use in sendChatMessage
  List<Content>? getChatHistory() => _currentChatHistory;
  
  /// Add message to chat history
  void addToHistory(String userMessage, String aiResponse) {
    if (_currentChatHistory == null) {
      startChatSession();
    }
    _currentChatHistory!.add(Content.text(userMessage));
    _currentChatHistory!.add(Content.text(aiResponse));
  }
  
  /// Clear chat history
  void clearChatHistory() {
    _currentChatHistory = null;
    _currentUserProfile = null;
    Logger.info('Chat session cleared', tag: 'GeminiService');
  }

  /// Get default safety settings for medical applications
  List<SafetySetting> _getSafetySettings() {
    return [
      SafetySetting(
        category: HarmCategory.medical,
        threshold: HarmBlockThreshold.medium, // Block potentially harmful medical advice
      ),
      SafetySetting(
        category: HarmCategory.dangerousContent,
        threshold: HarmBlockThreshold.medium, // Block dangerous content
      ),
      SafetySetting(
        category: HarmCategory.harassment,
        threshold: HarmBlockThreshold.medium, // Block harassment
      ),
      SafetySetting(
        category: HarmCategory.hateSpeech,
        threshold: HarmBlockThreshold.medium, // Block hate speech
      ),
      SafetySetting(
        category: HarmCategory.sexuallyExplicit,
        threshold: HarmBlockThreshold.medium, // Block explicit content
      ),
    ];
  }
  
  /// Get GenerativeModel instance with enhanced configuration
  /// [useProModel] - Set to true for advanced reasoning tasks (symptom analysis, drug interactions)
  /// [enableGrounding] - Enable Google Search grounding for real-time data (default: false)
  /// 
  /// Note: Grounding enables real-time Google Search retrieval for up-to-date medical information
  /// This is particularly useful for medicine details, symptom analysis, and drug interactions
  Future<GenerativeModel> _getModel(
    String apiKey, {
    String? systemInstruction,
    bool useProModel = false,
    bool enableGrounding = false,
  }) async {
    final modelName = useProModel ? _proModel : _defaultModel;
    
    // Configure tools for grounding if enabled
    // Google Search grounding is available in google_generative_ai package 0.4.0+
    List<Tool>? tools;
    if (enableGrounding) {
      try {
        // Use GoogleSearchRetrieval tool for real-time web search
        // This enables the model to fetch current information from Google Search
        tools = [Tool.googleSearchRetrieval()];
        Logger.info('Google Search grounding enabled for model: $modelName', tag: 'GeminiService');
      } catch (e) {
        Logger.warn('Could not enable grounding tool: $e. Continuing without grounding.', tag: 'GeminiService');
        tools = null;
      }
    }
    
    return GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      systemInstruction: systemInstruction != null ? Content.system(systemInstruction) : null,
      safetySettings: _getSafetySettings(),
      tools: tools,
    );
  }

  /// Retry helper with exponential backoff
  Future<T> _retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxRetries = _maxRetries,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          Logger.error('Max retries reached: $e', tag: 'GeminiService');
          rethrow;
        }

        // Check if error is retryable
        if (shouldRetry != null && !shouldRetry(e)) {
          rethrow;
        }

        // Check if it's a network/server error (retryable)
        final errorString = e.toString().toLowerCase();
        final isRetryable = errorString.contains('network') ||
            errorString.contains('timeout') ||
            errorString.contains('500') ||
            errorString.contains('502') ||
            errorString.contains('503') ||
            errorString.contains('connection');

        if (!isRetryable) {
          rethrow;
        }

        // Exponential backoff: 1s, 2s, 4s
        final delay = _baseRetryDelay * pow(2, attempt - 1);
        Logger.info('Retrying after ${delay.inSeconds}s (attempt $attempt/$maxRetries)', tag: 'GeminiService');
        await Future.delayed(delay);
      }
    }
    throw Exception('Retry logic failed');
  }

  /// Generate cache key from prompt and context
  String _generateCacheKey(String prompt, {Map<String, dynamic>? context}) {
    final contextStr = context != null ? jsonEncode(context) : '';
    return '${prompt.hashCode}_${contextStr.hashCode}';
  }

  /// Get cached response if available and not expired
  T? _getCachedResponse<T>(String cacheKey) {
    final entry = _responseCache[cacheKey];
    if (entry == null) return null;

    if (DateTime.now().difference(entry.timestamp) > _cacheMaxAge) {
      _responseCache.remove(cacheKey);
      return null;
    }

    Logger.info('Using cached response', tag: 'GeminiService');
    return entry.data as T?;
  }

  /// Store response in cache
  void _cacheResponse<T>(String cacheKey, T data) {
    // Evict oldest entries if cache is full
    if (_responseCache.length >= _maxCacheSize) {
      final oldestKey = _responseCache.entries
          .reduce((a, b) => a.value.timestamp.isBefore(b.value.timestamp) ? a : b)
          .key;
      _responseCache.remove(oldestKey);
    }

    _responseCache[cacheKey] = _CacheEntry(data: data, timestamp: DateTime.now());
  }

  /// Clear expired cache entries
  void _cleanExpiredCache() {
    final now = DateTime.now();
    _responseCache.removeWhere((key, entry) => now.difference(entry.timestamp) > _cacheMaxAge);
  }

  /// Send a message in a multi-turn conversational context with retry logic
  /// Timeout: 30 seconds for chat messages
  Future<String> sendChatMessage(String message, {
    required String apiKey,
    List<Content>? history, // Pass history to maintain stateless service or Use internal state
    UserModel? userProfile,
  }) async {
    return _retryWithBackoff(() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _rateLimiter.recordApiCall(user.uid, 'gemini_chat');
      }

      // Build System Instruction
      final systemText = _buildSystemPrompt(userProfile);
      
      final model = await _getModel(apiKey, systemInstruction: systemText);
      final chat = model.startChat(history: history);
      
      // Apply 30 second timeout for chat messages
      final response = await chat.sendMessage(Content.text(message))
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw TimeoutException('Chat message request timed out after 30 seconds');
      });
      
      // Clean and sanitize response text
      final rawText = response.text ?? '';
      return _sanitizeText(rawText);
    });
  }

  /// Enhanced system prompt with XML-style structure and medical disclaimers
  String _buildSystemPrompt(UserModel? userProfile) {
    final buffer = StringBuffer();
    buffer.writeln('<role>');
    buffer.writeln('You are "Tickdose", an empathetic and knowledgeable AI medical assistant.');
    buffer.writeln('Your goal is to help users manage their medication and health.');
    buffer.writeln('</role>');
    
    buffer.writeln('<traits>');
    buffer.writeln('Professional, Warm, Concise, Safety-First');
    buffer.writeln('</traits>');
    
    buffer.writeln('<formatting>');
    buffer.writeln('Use Markdown. Specific sections like **Recommendations** are helpful.');
    buffer.writeln('</formatting>');
    
    if (userProfile != null) {
      buffer.writeln('<user_context>');
      if (userProfile.fullName.isNotEmpty) buffer.writeln('Name: ${userProfile.fullName}');
      // Add more context if safe/relevant
      buffer.writeln('</user_context>');
    }
    
    buffer.writeln('<safety_guardrails>');
    buffer.writeln('- NEVER provide definitive diagnoses.');
    buffer.writeln('- ALWAYS advise seeing a doctor for severe symptoms.');
    buffer.writeln('- If unsure, admit it.');
    buffer.writeln('- Always include medical disclaimer: "This is not medical advice. Consult a healthcare professional."');
    buffer.writeln('- Base recommendations on evidence-based medicine when possible.');
    buffer.writeln('</safety_guardrails>');
    
    buffer.writeln('<medical_disclaimer>');
    buffer.writeln('IMPORTANT: This AI assistant provides general health information only.');
    buffer.writeln('It is NOT a substitute for professional medical advice, diagnosis, or treatment.');
    buffer.writeln('Always seek the advice of qualified health providers with any questions.');
    buffer.writeln('</medical_disclaimer>');
    
    return buffer.toString();
  }

  /// Enhanced JSON Parser with schema validation and better error recovery
  /// Handles nested markdown, multiple JSON objects, and malformed JSON
  Map<String, dynamic> _robustJsonParse(String text) {
    try {
      // Step 1: Clean markdown code blocks (handle nested blocks)
      var clean = text;
      
      // Remove all markdown code block markers (handles nested blocks)
      while (clean.contains('```')) {
        clean = clean.replaceAll(RegExp(r'```json\s*', multiLine: true), '')
            .replaceAll(RegExp(r'```\s*', multiLine: true), '');
      }
      
      // Remove leading/trailing whitespace and newlines
      clean = clean.replaceAll(RegExp(r'^[\s\n\r]*'), '')
          .replaceAll(RegExp(r'[\s\n\r]*$'), '')
          .trim();

      // Step 2: Handle multiple JSON objects - extract the first/largest valid one
      final jsonStart = clean.indexOf('{');
      if (jsonStart == -1) {
        Logger.error('No JSON object found in text', tag: 'GeminiService');
        return {};
      }
      
      // Find matching closing brace (handle nested objects)
      int braceCount = 0;
      int jsonEnd = -1;
      for (int i = jsonStart; i < clean.length; i++) {
        if (clean[i] == '{') {
          braceCount++;
        } else if (clean[i] == '}') {
          braceCount--;
          if (braceCount == 0) {
            jsonEnd = i;
            break;
          }
        }
      }
      
      if (jsonEnd == -1 || jsonEnd <= jsonStart) {
        Logger.error('Invalid JSON structure: unmatched braces', tag: 'GeminiService');
        // Try fallback parsing
        return _fallbackJsonParse(text);
      }
      
      clean = clean.substring(jsonStart, jsonEnd + 1);

      // Step 3: Fix common JSON issues before parsing
      // Remove trailing commas
      clean = clean.replaceAll(RegExp(r',\s*}'), '}')
          .replaceAll(RegExp(r',\s*]'), ']');
      
      // Fix unquoted keys (basic attempt)
      clean = clean.replaceAll(RegExp(r'(\w+):'), r'"$1":');

      // Step 4: Parse JSON
      final parsed = jsonDecode(clean) as Map<String, dynamic>;
      
      // Step 5: Basic validation - ensure it's a map
      if (parsed is! Map<String, dynamic>) {
        Logger.error('Parsed JSON is not a map', tag: 'GeminiService');
        return {};
      }

      return parsed;
    } catch (e) {
      Logger.error('JSON Parse Error: $e\nText: ${text.substring(0, text.length > 200 ? 200 : text.length)}...', tag: 'GeminiService');
      return _fallbackJsonParse(text);
    }
  }
  
  /// Fallback JSON parsing with aggressive cleanup
  Map<String, dynamic> _fallbackJsonParse(String text) {
    try {
      // Try to fix common issues
      var fixed = text;
      
      // Remove all markdown
      while (fixed.contains('```')) {
        fixed = fixed.replaceAll(RegExp(r'```json\s*', multiLine: true), '')
            .replaceAll(RegExp(r'```\s*', multiLine: true), '');
      }
      
      // Extract JSON object boundaries
      final jsonStart = fixed.indexOf('{');
      final jsonEnd = fixed.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        fixed = fixed.substring(jsonStart, jsonEnd + 1);
      }
      
      // Fix trailing commas
      fixed = fixed.replaceAll(RegExp(r',\s*}'), '}')
          .replaceAll(RegExp(r',\s*]'), ']');
      
      // Remove comments (JSON doesn't support comments)
      fixed = fixed.replaceAll(RegExp(r'//.*'), '')
          .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
      
      return jsonDecode(fixed) as Map<String, dynamic>;
    } catch (e2) {
      Logger.error('Fallback JSON parse also failed: $e2', tag: 'GeminiService');
      return {};
    }
  }

  /// Enhanced list JSON parser
  List<dynamic> _robustJsonParseList(String text) {
    try {
      var clean = text.replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```'), '')
          .trim();

      final jsonStart = clean.indexOf('[');
      final jsonEnd = clean.lastIndexOf(']');
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        clean = clean.substring(jsonStart, jsonEnd + 1);
      }

      final parsed = jsonDecode(clean);
      if (parsed is List) {
        return parsed;
      }
      return [];
    } catch (e) {
      Logger.error('JSON List Parse Error: $e\nText: $text', tag: 'GeminiService');
      return [];
    }
  }

  /// Drug Interaction Check with enhanced prompt and retry logic
  Future<Map<String, dynamic>> checkDrugInteractions(List<MedicineModel> medicines, {required String apiKey}) async {
    return _retryWithBackoff(() async {
      try {
        final medsList = medicines.map((m) => "${m.name} (${m.dosage != null ? m.dosage! : 'unknown dose'})").join(', ');
        
        // Enhanced prompt with XML structure
        final prompt = '''
<task>
Analyze drug interactions for these medicines: $medsList
</task>

<output_format>
Output STRICT JSON:
{
  "hasInteractions": true/false,
  "interactions": ["Med A + Med B: Severity - Description"],
  "severity": "low/moderate/high/severe",
  "recommendations": ["Render medical advice"],
  "consultDoctor": true/false
}
</output_format>

<instructions>
- Use evidence-based medical sources
- Prioritize safety
- Be specific about interaction mechanisms when known
</instructions>
''';

        // Use Pro model for safety-critical drug interaction analysis
        // Timeout: 60 seconds for complex medical reasoning
        final model = await _getModel(apiKey, useProModel: true, enableGrounding: true);
        final response = await model.generateContent(
          [Content.text(prompt)],
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            temperature: 1.0, // Optimal for Gemini 3 models
          ),
        ).timeout(const Duration(seconds: 60), onTimeout: () {
          throw TimeoutException('Drug interaction check request timed out after 60 seconds');
        });
        
        final jsonMap = _robustJsonParse(response.text ?? '');
        if (jsonMap.isEmpty) return {'hasInteractions': false, 'error': true};
        return _validateDrugInteractionResponse(jsonMap);
      } catch (e) {
        Logger.error('Interactions check failed: $e');
        return {'hasInteractions': false, 'error': true};
      }
    });
  }

  /// Vision extraction with enhanced prompt
  Future<Map<String, dynamic>?> extractMedicineInfo(File image, {required String apiKey}) async {
    return _retryWithBackoff(() async {
      try {
        final bytes = await image.readAsBytes();
        final content = Content.multi([
          TextPart('''
<task>
Extract medicine details from this image.
</task>

<output_format>
Output STRICT JSON only:
{
  "name": "...",
  "strength": "...",
  "expiry_date": "YYYY-MM-DD",
  "batch_number": "...",
  "manufacturer": "..."
}
</output_format>

<instructions>
- Extract all visible text accurately
- Parse dates in YYYY-MM-DD format
- If information is not visible, use null
</instructions>
'''),
          DataPart('image/jpeg', bytes),
        ]);

        // Timeout: 45 seconds for OCR tasks
        final model = await _getModel(apiKey); 
        final response = await model.generateContent(
          [content],
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            temperature: 0.2, // Lower temperature for OCR accuracy
          ),
        ).timeout(const Duration(seconds: 45), onTimeout: () {
          throw TimeoutException('OCR request timed out after 45 seconds');
        });
        
        final text = response.text ?? '';
        if (text.isEmpty) return null;
        
        return _robustJsonParse(text);
      } catch (e) {
        Logger.error('Extract Medicine Info failed: $e');
        return null;
      }
    });
  }

  /// Check symptom for voice screen with enhanced prompt
  Future<String> checkSymptom({
    required String symptom,
    required List<String> userMedicines,
    required String apiKey,
  }) async {
    return _retryWithBackoff(() async {
      // Enhanced prompt with XML structure
      final prompt = '''
<context>
User Symptom: $symptom
Current Medicines: ${userMedicines.join(', ')}
</context>

<task>
Provide a brief, empathetic response suitable for text-to-speech.
</task>

<instructions>
- Mention if this could be a side effect
- Check for potential interactions
- Keep it short (2-3 sentences)
- Include medical disclaimer
</instructions>
''';
      
      try {
        // Timeout: 30 seconds for symptom check
        final model = await _getModel(apiKey);
        final response = await model.generateContent([Content.text(prompt)])
            .timeout(const Duration(seconds: 30), onTimeout: () {
          throw TimeoutException('Symptom check request timed out after 30 seconds');
        });
        final rawText = response.text ?? '';
        return _sanitizeText(rawText);
      } catch (e) {
        Logger.error('Check Symptom failed: $e', tag: 'GeminiService');
        throw ApiError.fromException(e);
      }
    });
  }

  /// Get medicine details with caching and enhanced prompt
  Future<Map<String, dynamic>> getMedicineDetails(String medicineName, {required String apiKey, String language = 'en'}) async {
    // Check cache first
    final cacheKey = _generateCacheKey('medicine_details', context: {'name': medicineName, 'lang': language});
    final cached = _getCachedResponse<Map<String, dynamic>>(cacheKey);
    if (cached != null) return cached;

    return _retryWithBackoff(() async {
      try {
        // Enhanced prompt with XML structure
        final prompt = '''
<task>
Provide details for medicine "$medicineName" in $language
</task>

<output_format>
JSON:
{
  "side_effects": [],
  "generic_name": "",
  "manufacturer": ""
}
</output_format>

<instructions>
- Use evidence-based information
- Include common side effects
- Provide generic name if available
- Include manufacturer information
</instructions>
''';
        
        // Timeout: 30 seconds for medicine details
        final model = await _getModel(apiKey, enableGrounding: true);
        final response = await model.generateContent(
          [Content.text(prompt)],
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            temperature: 1.0,
          ),
        ).timeout(const Duration(seconds: 30), onTimeout: () {
          throw TimeoutException('Medicine details request timed out after 30 seconds');
        });
         
        final text = response.text ?? '';
        final jsonMap = _robustJsonParse(text);
        if (jsonMap.isEmpty) return {};
        
        // Validate and sanitize response
        final result = _validateMedicineDetailsResponse(jsonMap);
        
        // Cache the result
        _cacheResponse(cacheKey, result);
        
        return result;
      } catch (e) {
        Logger.error('Enrichment failed: $e');
        return {};
      }
    });
  }

  /// Analyze symptoms with enhanced prompt, caching, and retry logic
  Future<SymptomAnalysisResponse> analyzeSymptoms(
    String symptomDescription, {
    List<MedicineModel>? currentMedicines,
    UserModel? userProfile,
    required String apiKey,
    String language = 'en',
  }) async {
    return _retryWithBackoff(() async {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final rateLimitResult = await _rateLimiter.checkGeminiLimit(user.uid);
          if (!rateLimitResult.allowed) return SymptomAnalysisResponse.rateLimitExceeded(rateLimitResult);
        }

        // Build context
        final medicinesContext = currentMedicines != null && currentMedicines.isNotEmpty
            ? '\n\n<current_medicines>\n${currentMedicines.map((m) => "- ${m.name}").join('\n')}\n</current_medicines>'
            : '';

        // Enhanced prompt with XML structure
        final prompt = '''
<task>
Analyze these symptoms: $symptomDescription
</task>

<context>
Language: $language$medicinesContext
</context>

<output_format>
Output STRICT JSON:
{
  "summary": "...",
  "possible_causes": ["..."],
  "recommendations": ["..."],
  "urgency_level": "low/medium/high/emergency",
  "suggest_doctor_visit": true/false
}
</output_format>

<instructions>
- Use evidence-based medical knowledge
- Consider current medications in analysis
- Prioritize safety
- Be specific but cautious
- Always recommend doctor visit for severe symptoms
</instructions>
''';

        // Use Pro model for complex medical symptom analysis with grounding
        // Timeout: 60 seconds for complex reasoning tasks
        final stopwatch = Stopwatch()..start();
        final model = await _getModel(apiKey, useProModel: true, enableGrounding: true);
        final response = await model.generateContent(
          [Content.text(prompt)],
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            temperature: 1.0, // Optimal for Gemini 3 models
          ),
        ).timeout(const Duration(seconds: 60), onTimeout: () {
          throw TimeoutException('Symptom analysis request timed out after 60 seconds');
        });
        
        stopwatch.stop();
        
        final text = response.text ?? '';
        // Record call and analytics
        if (user != null) {
          await _rateLimiter.recordApiCall(user.uid, 'gemini');
          await _analytics.recordApiCall(
            apiType: 'gemini',
            success: true,
            responseTimeMs: stopwatch.elapsedMilliseconds,
            model: 'pro',
          );
        }
        
        final jsonMap = _robustJsonParse(text);
        if (jsonMap.isEmpty) return SymptomAnalysisResponse.error();

        // Validate and sanitize response schema
        final validatedMap = _validateSymptomAnalysisResponse(jsonMap);

        return SymptomAnalysisResponse(
          summary: validatedMap['summary'] as String,
          possibleCauses: List<String>.from(validatedMap['possible_causes'] as List),
          recommendations: List<String>.from(validatedMap['recommendations'] as List),
          urgencyLevel: validatedMap['urgency_level'] as String,
          suggestDoctorVisit: validatedMap['suggest_doctor_visit'] as bool,
        );
      } catch (e) {
        Logger.error('Analysis failed: $e', tag: 'GeminiService');
        return SymptomAnalysisResponse.error();
      }
    });
  }

  /// Generate personalized quests with enhanced prompt and caching
  Future<List<Map<String, dynamic>>> generatePersonalizedQuests({
    required UserModel userProfile,
    required String apiKey,
    String language = 'en',
  }) async {
    return _retryWithBackoff(() async {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final rateLimitResult = await _rateLimiter.checkGeminiLimit(user.uid);
          if (!rateLimitResult.allowed) return []; 
        }

        // Enhanced prompt with XML structure
        final prompt = '''
<role>
You are a gamified health coach.
</role>

<task>
Create 3 personalized daily quests for this user.
</task>

<user_context>
- Age: ${userProfile.age ?? 'Unknown'}
- Conditions: ${userProfile.healthConditions.join(", ")}
- Goal: Improve adherence and well-being.
</user_context>

<instructions>
1. Create 3 simple, achievable quests (e.g. "Drink water", "Walk 10 mins", "Meditate").
2. Assign XP (20-50 XP).
3. Make quests relevant to user's health conditions
4. Ensure quests are safe and appropriate
</instructions>

<output_format>
Output STRICT JSON list:
[
  {
    "id": "quest_id_string",
    "title": "Quest Title in $language",
    "description": "Short description in $language",
    "xp_reward": 50,
    "type": "daily"
  }
]
</output_format>
''';

        // Flash model is sufficient for creative quest generation
        // Timeout: 30 seconds for quest generation
        final model = await _getModel(apiKey, useProModel: false);
        final response = await model.generateContent(
          [Content.text(prompt)],
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            temperature: 1.0, // Optimal for Gemini 3 models
          ),
        ).timeout(const Duration(seconds: 30), onTimeout: () {
          throw TimeoutException('Quest generation request timed out after 30 seconds');
        });

        final text = response.text ?? '';
        if (user != null) await _rateLimiter.recordApiCall(user.uid, 'gemini_quests');

        final list = _robustJsonParseList(text);
        if (list.isNotEmpty) {
          return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        }
        return [];

      } catch (e) {
        Logger.error('Quest generation failed: $e', tag: 'GeminiService');
        return [];
      }
    });
  }

  /// Clear all cached responses
  void clearCache() {
    _responseCache.clear();
    Logger.info('Response cache cleared', tag: 'GeminiService');
  }

  /// Clean expired cache entries (call periodically)
  void cleanExpiredCache() {
    _cleanExpiredCache();
  }
}

/// Cache entry for response caching
class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  _CacheEntry({required this.data, required this.timestamp});
}

// Response Models
class SymptomAnalysisResponse {
  final String summary;
  final List<String> possibleCauses;
  final List<String> recommendations;
  final String urgencyLevel;
  final bool suggestDoctorVisit;

  SymptomAnalysisResponse({
    required this.summary,
    required this.possibleCauses,
    required this.recommendations,
    required this.urgencyLevel,
    required this.suggestDoctorVisit,
  });

  factory SymptomAnalysisResponse.error() {
    return SymptomAnalysisResponse(
      summary: 'Unable to analyze symptoms. Please try again.',
      possibleCauses: [],
      recommendations: ['Consult a healthcare professional'],
      urgencyLevel: 'medium',
      suggestDoctorVisit: true,
    );
  }

  factory SymptomAnalysisResponse.rateLimitExceeded(RateLimitResult rateLimit) {
    return SymptomAnalysisResponse(
      summary: rateLimit.message ?? 'API rate limit reached. Please try again later.',
      possibleCauses: [],
      recommendations: [
        'Please wait before trying again',
        'Consider consulting a healthcare professional directly',
      ],
      urgencyLevel: 'medium',
      suggestDoctorVisit: true,
    );
  }
}

class DrugInteractionResult {
  final bool hasInteractions;
  final List<String> interactions;
  final String severity;
  final List<String> recommendations;
  final bool consultDoctor;

  DrugInteractionResult({
    required this.hasInteractions,
    required this.interactions,
    required this.severity,
    required this.recommendations,
    required this.consultDoctor,
  });

  factory DrugInteractionResult.none() {
    return DrugInteractionResult(
      hasInteractions: false,
      interactions: [],
      severity: 'none',
      recommendations: [],
      consultDoctor: false,
    );
  }

  factory DrugInteractionResult.error() {
    return DrugInteractionResult(
      hasInteractions: false,
      interactions: ['Unable to check interactions'],
      severity: 'unknown',
      recommendations: ['Consult a pharmacist or doctor'],
      consultDoctor: true,
    );
  }

  factory DrugInteractionResult.rateLimitExceeded() {
    return DrugInteractionResult(
      hasInteractions: false,
      interactions: ['Rate limit reached. Please try again later.'],
      severity: 'unknown',
      recommendations: ['Consult a pharmacist or doctor for immediate advice'],
      consultDoctor: true,
    );
  }
}

class AdherenceInsight {
  final String insight;
  final List<String> tips;
  final String motivation;
  final String goal;

  AdherenceInsight({
    required this.insight,
    required this.tips,
    required this.motivation,
    required this.goal,
  });

  factory AdherenceInsight.error() {
    return AdherenceInsight(
      insight: 'Keep taking your medicines as prescribed',
      tips: ['Set reminder alarms', 'Take medicines at the same time daily'],
      motivation: 'Every dose counts towards your health!',
      goal: 'Maintain consistent adherence',
    );
  }
}
