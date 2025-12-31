import 'package:firebase_performance/firebase_performance.dart';
import 'package:tickdose/core/utils/logger.dart';

/// Service for Firebase Performance Monitoring
class PerformanceMonitoringService {
  static final PerformanceMonitoringService _instance = PerformanceMonitoringService._internal();
  factory PerformanceMonitoringService() => _instance;
  PerformanceMonitoringService._internal();

  final FirebasePerformance _performance = FirebasePerformance.instance;
  bool _enabled = false;

  /// Initialize performance monitoring
  Future<void> initialize() async {
    try {
      _enabled = await _performance.isPerformanceCollectionEnabled();
      if (!_enabled) {
        await _performance.setPerformanceCollectionEnabled(true);
        _enabled = true;
      }
      Logger.info('Performance monitoring enabled', tag: 'Performance');
    } catch (e) {
      Logger.error('Failed to enable performance monitoring: $e', tag: 'Performance', error: e);
      _enabled = false;
    }
  }

  /// Start a trace for a custom operation
  Future<Trace> startTrace(String traceName) async {
    if (!_enabled) {
      // Return a no-op trace if disabled
      return _NoOpTrace();
    }
    try {
      return _performance.newTrace(traceName);
    } catch (e) {
      Logger.error('Failed to start trace: $e', tag: 'Performance', error: e);
      return _NoOpTrace();
    }
  }

  /// Start an HTTP request trace
  Future<HttpMetric> startHttpMetric(String url, HttpMethod method) async {
    if (!_enabled) {
      return _NoOpHttpMetric();
    }
    try {
      return _performance.newHttpMetric(url, method);
    } catch (e) {
      Logger.error('Failed to start HTTP metric: $e', tag: 'Performance', error: e);
      return _NoOpHttpMetric();
    }
  }

  /// Check if performance monitoring is enabled
  bool get isEnabled => _enabled;
}

/// No-op trace implementation for when performance monitoring is disabled
class _NoOpTrace implements Trace {
  @override
  Future<void> start() async {}
  
  @override
  Future<void> stop() async {}
  
  @override
  void incrementMetric(String name, int value) {}
  
  @override
  void setMetric(String name, int value) {}
  
  @override
  int getMetric(String name) => 0;
  
  @override
  void putAttribute(String name, String value) {}
  
  @override
  String? getAttribute(String name) => null;
  
  @override
  void removeAttribute(String name) {}
  
  @override
  Map<String, String> getAttributes() => {};
}

/// No-op HTTP metric implementation
class _NoOpHttpMetric implements HttpMetric {
  int? _httpResponseCode;
  int? _requestPayloadSize;
  int? _responsePayloadSize;
  String? _responseContentType;
  final Map<String, String> _attributes = {};
  
  @override
  Future<void> start() async {}
  
  @override
  Future<void> stop() async {}
  
  @override
  int? get httpResponseCode => _httpResponseCode;
  
  @override
  set httpResponseCode(int? code) {
    _httpResponseCode = code;
  }
  
  @override
  int? get requestPayloadSize => _requestPayloadSize;
  
  @override
  set requestPayloadSize(int? bytes) {
    _requestPayloadSize = bytes;
  }
  
  @override
  int? get responsePayloadSize => _responsePayloadSize;
  
  @override
  set responsePayloadSize(int? bytes) {
    _responsePayloadSize = bytes;
  }
  
  @override
  String? get responseContentType => _responseContentType;
  
  @override
  set responseContentType(String? contentType) {
    _responseContentType = contentType;
  }
  
  @override
  void putAttribute(String name, String value) {
    _attributes[name] = value;
  }
  
  @override
  String? getAttribute(String name) => _attributes[name];
  
  @override
  void removeAttribute(String name) {
    _attributes.remove(name);
  }
  
  @override
  Map<String, String> getAttributes() => Map.unmodifiable(_attributes);
}
