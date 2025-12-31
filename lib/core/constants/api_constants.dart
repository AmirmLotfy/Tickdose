class ApiConstants {
  // OpenStreetMap Nominatim API
  static const String osmBaseUrl = 'https://nominatim.openstreetmap.org';
  static const String osmSearchEndpoint = '/search';
  static const String osmUserAgent = 'TickdoseApp/1.0';
  
  // Search Parameters
  static const int pharmacySearchRadius = 5000; // 5km in meters
  static const int defaultSearchLimit = 20;
  
  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Gemini API (for future use)
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com';
  // Model name moved to GeminiService - using gemini-3-flash as default (stable Gemini 3)
  // Note: This constant is currently unused; model selection is handled in GeminiService
  @Deprecated('Use GeminiService instead - model selection is handled there')
  static const String geminiModel = 'gemini-3-flash';
  
  // Note: Add API keys via environment variables, never hardcode them
  // Use flutter_dotenv or similar package for API key management
}
