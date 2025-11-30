import '../http/request.dart';
import '../http/response.dart';
import '../utils/exception.dart';
import 'middleware.dart';
import 'dart:async';
import 'dart:io';

/// Global error-handling middleware
MiddlewareHandler errorHandler =
    (RivetRequest req, FutureOr<dynamic> Function() next) async {
      try {
        return await next();
      } on RivetException catch (e) {
        final acceptsJson =
            req.headers.value('accept')?.contains('application/json') ?? false;

        if (acceptsJson) {
          return RivetResponse.json({
            'error': e.message,
            'statusCode': e.statusCode,
            if (e.details != null) 'details': e.details,
          }, statusCode: e.statusCode);
        } else {
          return RivetResponse.text(e.message, statusCode: e.statusCode);
        }
      } catch (e, stack) {
        print('[RIVET ERROR] $e\n$stack');
        return RivetResponse.text('Internal Server Error', statusCode: 500);
      }
    };

RivetResponse _errorResponse(
  RivetRequest req,
  String message,
  int statusCode, [
  Map<String, dynamic>? details,
]) {
  final accept = req.headers.value(HttpHeaders.acceptHeader) ?? '';

  if (accept.contains('application/json')) {
    return RivetResponse.json({
      'error': message,
      if (details != null) 'details': details,
    }, statusCode: statusCode);
  } else {
    return RivetResponse.text(message, statusCode: statusCode);
  }
}
