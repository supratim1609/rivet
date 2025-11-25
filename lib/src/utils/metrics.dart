import 'dart:async';
import 'package:rivet/rivet.dart';

class Metrics {
  int totalRequests = 0;
  int successfulRequests = 0;
  int failedRequests = 0;
  final Map<int, int> statusCodes = {};
  final Map<String, int> pathCounts = {};
  final List<int> responseTimes = [];
  
  void recordRequest(String path, int statusCode, int durationMs) {
    totalRequests++;
    
    if (statusCode >= 200 && statusCode < 400) {
      successfulRequests++;
    } else {
      failedRequests++;
    }
    
    statusCodes[statusCode] = (statusCodes[statusCode] ?? 0) + 1;
    pathCounts[path] = (pathCounts[path] ?? 0) + 1;
    responseTimes.add(durationMs);
  }
  
  double get averageResponseTime {
    if (responseTimes.isEmpty) return 0;
    return responseTimes.reduce((a, b) => a + b) / responseTimes.length;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'totalRequests': totalRequests,
      'successfulRequests': successfulRequests,
      'failedRequests': failedRequests,
      'averageResponseTime': averageResponseTime,
      'statusCodes': statusCodes,
      'topPaths': pathCounts,
    };
  }
}

final metrics = Metrics();

MiddlewareHandler metricsCollector() {
  return (RivetRequest req, FutureOr<dynamic> Function() next) async {
    final startTime = DateTime.now();
    
    try {
      final result = await next();
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      final statusCode = result is RivetResponse ? result.statusCode : 200;
      
      metrics.recordRequest(req.path, statusCode, duration);
      
      return result;
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      metrics.recordRequest(req.path, 500, duration);
      rethrow;
    }
  };
}

// Prometheus-style metrics endpoint
String prometheusMetrics() {
  final buffer = StringBuffer();
  
  buffer.writeln('# HELP http_requests_total Total HTTP requests');
  buffer.writeln('# TYPE http_requests_total counter');
  buffer.writeln('http_requests_total ${metrics.totalRequests}');
  buffer.writeln();
  
  buffer.writeln('# HELP http_request_duration_ms Average response time');
  buffer.writeln('# TYPE http_request_duration_ms gauge');
  buffer.writeln('http_request_duration_ms ${metrics.averageResponseTime}');
  buffer.writeln();
  
  buffer.writeln('# HELP http_requests_by_status Requests by status code');
  buffer.writeln('# TYPE http_requests_by_status counter');
  metrics.statusCodes.forEach((code, count) {
    buffer.writeln('http_requests_by_status{code="$code"} $count');
  });
  
  return buffer.toString();
}
