import 'dart:io';
import 'dart:convert';

import 'package:mime/mime.dart';
import 'file.dart';

class RivetRequest {
  final String method;
  final String path;
  final Uri uri;
  final HttpHeaders headers;
  final HttpRequest raw;

  // Middleware / router can populate these
  Map<String, String> params = {}; // dynamic route params e.g., /user/:id
  Map<String, String> query = {}; // query params e.g., ?q=search
  Map<String, List<String>> queryAll =
      {}; // all query params e.g., ?ids=1&ids=2
  Map<String, dynamic>? jsonBody; // parsed JSON from middleware

  // Form data
  Map<String, String> formFields = {};
  List<UploadedFile> files = [];

  RivetRequest._(this.method, this.path, this.uri, this.headers, this.raw) {
    query = uri.queryParameters;
    queryAll = uri.queryParametersAll;
  }

  static RivetRequest from(HttpRequest raw) {
    return RivetRequest._(raw.method, raw.uri.path, raw.uri, raw.headers, raw);
  }

  /// Parse body based on Content-Type
  Future<void> parseBody() async {
    final contentType = headers.contentType;
    if (contentType == null) return;

    if (contentType.mimeType == 'multipart/form-data') {
      final boundary = contentType.parameters['boundary'];
      if (boundary == null) return;

      final transformer = MimeMultipartTransformer(boundary);
      final parts = raw.cast<List<int>>().transform(transformer);

      await for (final part in parts) {
        final contentDisposition = part.headers['content-disposition'];
        if (contentDisposition == null) continue;

        final header = HeaderValue.parse(contentDisposition);
        final name = header.parameters['name'] ?? '';
        final filename = header.parameters['filename'];

        if (filename != null) {
          // It's a file
          final data = await part.fold<List<int>>([], (p, e) => p..addAll(e));
          files.add(
            UploadedFile(
              name: name,
              filename: filename,
              contentType: ContentType.parse(
                part.headers['content-type'] ?? 'application/octet-stream',
              ),
              data: data,
            ),
          );
        } else {
          // It's a field
          final value = await utf8.decodeStream(part);
          formFields[name] = value;
        }
      }
    } else if (contentType.mimeType == 'application/x-www-form-urlencoded') {
      final body = await text();
      formFields.addAll(Uri.splitQueryString(body));
    }
  }

  /// Parse JSON body
  Future<Map<String, dynamic>> json() async {
    if (jsonBody != null) return jsonBody!;
    final bodyString = await utf8.decoder.bind(raw).join();
    jsonBody = jsonDecode(bodyString);
    return jsonBody!;
  }

  /// Raw text body
  Future<String> text() async {
    return await utf8.decoder.bind(raw).join();
  }

  // Typed helpers
  int? getInt(String key) {
    final val = query[key];
    if (val == null) return null;
    return int.tryParse(val);
  }

  double? getDouble(String key) {
    final val = query[key];
    if (val == null) return null;
    return double.tryParse(val);
  }

  bool? getBool(String key) {
    final val = query[key]?.toLowerCase();
    if (val == null) return null;
    return val == 'true' || val == '1';
  }
}
