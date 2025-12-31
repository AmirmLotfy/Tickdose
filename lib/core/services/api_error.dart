import 'package:tickdose/l10n/generated/app_localizations.dart';

/// API Error types for consistent error handling across services
enum ApiErrorType {
  rateLimitExceeded,
  apiKeyInvalid,
  networkError,
  serverError,
  unknownError,
  audioGenerationFailed,
  invalidResponseFormat,
  modelUnavailable,
}

/// API Error class that carries both type and original exception
class ApiError implements Exception {
  final ApiErrorType type;
  final String? originalMessage;
  
  const ApiError(this.type, [this.originalMessage]);
  
  @override
  String toString() => originalMessage ?? type.toString();
  
  /// Create ApiError from exception, detecting type automatically
  factory ApiError.fromException(dynamic exception) {
    final errorString = exception.toString().toLowerCase();
    
    if (errorString.contains('rate limit') || 
        errorString.contains('quota') ||
        errorString.contains('429')) {
      return ApiError(ApiErrorType.rateLimitExceeded, exception.toString());
    } else if (errorString.contains('api key') || 
               errorString.contains('authentication') ||
               errorString.contains('401') ||
               errorString.contains('403')) {
      return ApiError(ApiErrorType.apiKeyInvalid, exception.toString());
    } else if (errorString.contains('network') || 
               errorString.contains('connection') ||
               errorString.contains('timeout')) {
      return ApiError(ApiErrorType.networkError, exception.toString());
    } else if (errorString.contains('500') || 
               errorString.contains('502') ||
               errorString.contains('503') ||
               errorString.contains('server')) {
      return ApiError(ApiErrorType.serverError, exception.toString());
    } else if (errorString.contains('audio') && 
               (errorString.contains('generation') || 
                errorString.contains('invalid') ||
                errorString.contains('corrupt'))) {
      return ApiError(ApiErrorType.audioGenerationFailed, exception.toString());
    } else if (errorString.contains('invalid') && 
               (errorString.contains('response') || 
                errorString.contains('format') ||
                errorString.contains('json'))) {
      return ApiError(ApiErrorType.invalidResponseFormat, exception.toString());
    } else if (errorString.contains('model') && 
               (errorString.contains('unavailable') || 
                errorString.contains('not found'))) {
      return ApiError(ApiErrorType.modelUnavailable, exception.toString());
    } else {
      return ApiError(ApiErrorType.unknownError, exception.toString());
    }
  }
}

/// Extension to get localized error messages from ApiError
extension ApiErrorLocalization on ApiErrorType {
  String getLocalizedMessage(AppLocalizations l10n) {
    switch (this) {
      case ApiErrorType.rateLimitExceeded:
        return l10n.apiRateLimitExceeded;
      case ApiErrorType.apiKeyInvalid:
        return l10n.apiInitializationFailed;
      case ApiErrorType.networkError:
        return l10n.apiGenericError; // Could add specific network error if needed
      case ApiErrorType.serverError:
        return l10n.apiGenericError;
      case ApiErrorType.audioGenerationFailed:
        return 'Audio generation failed. Please try again.';
      case ApiErrorType.invalidResponseFormat:
        return 'Invalid response format. Please try again.';
      case ApiErrorType.modelUnavailable:
        return 'Voice model unavailable. Please try a different model.';
      case ApiErrorType.unknownError:
        return l10n.apiGenericError;
    }
  }
}
