import '../http/request.dart';
import '../http/response.dart';
import 'middleware.dart';
import 'dart:convert';
import 'dart:async';

MiddlewareHandler jsonParser = (RivetRequest req, FutureOr<dynamic> Function() next) async {
  // Only parse if Content-Type is application/json
  final contentType = req.headers.contentType;
  if (contentType?.mimeType == 'application/json') {
    try {
      final body = await req.text();
      if (body.isNotEmpty) {
        req.jsonBody = jsonDecode(body);
      }
    } catch (e) {
      // If JSON parsing fails, just continue
      print('[JSON Parser] Failed to parse JSON: $e');
    }
  }

  return await next();
};
