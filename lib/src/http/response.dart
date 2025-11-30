import 'dart:convert';

class RivetResponse {
  final int statusCode;
  final Map<String, String> headers;
  final dynamic body;

  RivetResponse(
    this.body, {
    this.statusCode = 200,
    Map<String, String>? headers,
  }) : headers = headers ?? {};

  /// Factory for JSON response
  factory RivetResponse.json(dynamic data, {int statusCode = 200}) {
    return RivetResponse(
      jsonEncode(data),
      statusCode: statusCode,
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Factory from JSON (for client)
  factory RivetResponse.fromJson(dynamic data, {int statusCode = 200}) {
    return RivetResponse(
      data, // Keep as object/map/list, don't encode
      statusCode: statusCode,
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Factory for plain text response
  factory RivetResponse.text(String text, {int statusCode = 200}) {
    return RivetResponse(
      text,
      statusCode: statusCode,
      headers: {'Content-Type': 'text/plain'},
    );
  }

  /// 200 OK with JSON
  factory RivetResponse.ok(Map<String, dynamic> data) =>
      RivetResponse.json(data, statusCode: 200);

  /// 201 Created
  factory RivetResponse.created(Map<String, dynamic> data) =>
      RivetResponse.json(data, statusCode: 201);

  /// 204 No Content
  factory RivetResponse.noContent() => RivetResponse(null, statusCode: 204);

  /// 400 Bad Request
  factory RivetResponse.badRequest(String message) =>
      RivetResponse.json({'error': message}, statusCode: 400);

  /// 401 Unauthorized
  factory RivetResponse.unauthorized(String message) =>
      RivetResponse.json({'error': message}, statusCode: 401);

  /// 403 Forbidden
  factory RivetResponse.forbidden(String message) =>
      RivetResponse.json({'error': message}, statusCode: 403);

  /// 404 Not Found
  factory RivetResponse.notFound(String message) =>
      RivetResponse.json({'error': message}, statusCode: 404);

  /// 500 Internal Server Error
  factory RivetResponse.internalError(String message) =>
      RivetResponse.json({'error': message}, statusCode: 500);
}
