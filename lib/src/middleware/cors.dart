import 'dart:async';
import 'dart:io';
import '../http/request.dart';
import '../http/response.dart';
import 'middleware.dart';

MiddlewareHandler cors({
  dynamic origin = '*', // String or List<String>
  List<String> methods = const [
    'GET',
    'POST',
    'PUT',
    'DELETE',
    'OPTIONS',
    'PATCH'
  ],
  List<String> headers = const [
    'Origin',
    'X-Requested-With',
    'Content-Type',
    'Accept',
    'Authorization'
  ],
  bool credentials = false,
}) {
  return (RivetRequest req, FutureOr<dynamic> Function() next) async {
    final reqOrigin = req.headers.value('origin');
    String? allowOrigin;

    if (origin == '*') {
      allowOrigin = '*';
    } else if (origin is String) {
      allowOrigin = origin;
    } else if (origin is List<String>) {
      if (reqOrigin != null && origin.contains(reqOrigin)) {
        allowOrigin = reqOrigin;
      }
    }

    // Common headers for both preflight and normal requests
    final responseHeaders = <String, String>{};
    if (allowOrigin != null) {
      responseHeaders['Access-Control-Allow-Origin'] = allowOrigin;
    }
    if (credentials) {
      responseHeaders['Access-Control-Allow-Credentials'] = 'true';
    }

    // Handle Preflight (OPTIONS)
    if (req.method == 'OPTIONS') {
      responseHeaders['Access-Control-Allow-Methods'] = methods.join(', ');
      responseHeaders['Access-Control-Allow-Headers'] = headers.join(', ');
      
      return RivetResponse(
        null,
        statusCode: HttpStatus.noContent,
        headers: responseHeaders,
      );
    }

    // Handle Normal Request
    final res = await next();

    // If response is RivetResponse, add headers
    if (res is RivetResponse) {
      responseHeaders.forEach((key, value) {
        res.headers[key] = value;
      });
      return res;
    }

    return res;
  };
}
