import 'dart:async';
import 'dart:io';
import '../http/request.dart';
import '../http/response.dart';
import 'middleware.dart';

enum LogLevel { debug, info, warn, error }

class Logger {
  final LogLevel level;
  final bool colors;

  Logger({this.level = LogLevel.info, this.colors = true});

  void debug(String message) => _log(LogLevel.debug, message, '\x1B[36m');
  void info(String message) => _log(LogLevel.info, message, '\x1B[32m');
  void warn(String message) => _log(LogLevel.warn, message, '\x1B[33m');
  void error(String message) => _log(LogLevel.error, message, '\x1B[31m');

  void _log(LogLevel msgLevel, String message, String color) {
    if (msgLevel.index < level.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = msgLevel.toString().split('.').last.toUpperCase();
    final colorReset = '\x1B[0m';

    if (colors && stdout.supportsAnsiEscapes) {
      print('$color[$timestamp] $levelStr:$colorReset $message');
    } else {
      print('[$timestamp] $levelStr: $message');
    }
  }
}

// Global logger instance
final logger = Logger();

MiddlewareHandler requestLogger({
  LogLevel level = LogLevel.info,
  bool includeBody = false,
}) {
  final log = Logger(level: level);

  return (RivetRequest req, FutureOr<dynamic> Function() next) async {
    final startTime = DateTime.now();
    
    // Log request
    log.info('→ ${req.method} ${req.path}');
    
    if (level == LogLevel.debug) {
      log.debug('  Headers: ${req.headers.toString()}');
      log.debug('  Query: ${req.query}');
    }

    try {
      final result = await next();
      
      final duration = DateTime.now().difference(startTime);
      final statusCode = result is RivetResponse ? result.statusCode : 200;
      
      // Determine log level based on status code
      if (statusCode >= 500) {
        log.error('← ${req.method} ${req.path} $statusCode ${duration.inMilliseconds}ms');
      } else if (statusCode >= 400) {
        log.warn('← ${req.method} ${req.path} $statusCode ${duration.inMilliseconds}ms');
      } else {
        log.info('← ${req.method} ${req.path} $statusCode ${duration.inMilliseconds}ms');
      }
      
      return result;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      log.error('← ${req.method} ${req.path} ERROR ${duration.inMilliseconds}ms: $e');
      rethrow;
    }
  };
}

// Structured JSON logging
MiddlewareHandler jsonLogger() {
  return (RivetRequest req, FutureOr<dynamic> Function() next) async {
    final startTime = DateTime.now();
    
    try {
      final result = await next();
      final duration = DateTime.now().difference(startTime);
      final statusCode = result is RivetResponse ? result.statusCode : 200;
      
      final logEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'method': req.method,
        'path': req.path,
        'statusCode': statusCode,
        'duration': duration.inMilliseconds,
        'ip': req.raw.connectionInfo?.remoteAddress.address,
      };
      
      print(logEntry);
      return result;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      
      final logEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'method': req.method,
        'path': req.path,
        'statusCode': 500,
        'duration': duration.inMilliseconds,
        'error': e.toString(),
        'ip': req.raw.connectionInfo?.remoteAddress.address,
      };
      
      print(logEntry);
      rethrow;
    }
  };
}
