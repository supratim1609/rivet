import 'dart:async';
import 'dart:io';

class RivetTestClient {
  final String baseUrl;
  final HttpClient _client = HttpClient();

  RivetTestClient({this.baseUrl = 'http://localhost'});

  Future<TestResponse> get(String path, {Map<String, String>? headers}) async {
    return _request('GET', path, headers: headers);
  }

  Future<TestResponse> post(
    String path, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return _request('POST', path, headers: headers, body: body);
  }

  Future<TestResponse> put(
    String path, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return _request('PUT', path, headers: headers, body: body);
  }

  Future<TestResponse> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    return _request('DELETE', path, headers: headers);
  }

  Future<TestResponse> _request(
    String method,
    String path, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _client.openUrl(method, uri);

    // Set headers
    headers?.forEach((key, value) {
      request.headers.set(key, value);
    });

    // Set body
    if (body != null) {
      if (body is String) {
        request.write(body);
      } else if (body is Map) {
        request.headers.contentType = ContentType.json;
        request.write(body.toString());
      }
    }

    final response = await request.close();
    final responseBody = await response
        .transform(SystemEncoding().decoder)
        .join();

    return TestResponse(
      statusCode: response.statusCode,
      body: responseBody,
      headers: response.headers,
    );
  }

  void close() {
    _client.close();
  }
}

class TestResponse {
  final int statusCode;
  final String body;
  final HttpHeaders headers;

  TestResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
  });

  TestResponse expect(int expectedStatus) {
    if (statusCode != expectedStatus) {
      throw Exception('Expected status $expectedStatus but got $statusCode');
    }
    return this;
  }

  TestResponse expectBody(String expectedBody) {
    if (body != expectedBody) {
      throw Exception('Expected body "$expectedBody" but got "$body"');
    }
    return this;
  }

  TestResponse expectBodyContains(String substring) {
    if (!body.contains(substring)) {
      throw Exception('Expected body to contain "$substring" but got "$body"');
    }
    return this;
  }

  TestResponse expectHeader(String key, String value) {
    final headerValue = headers.value(key);
    if (headerValue != value) {
      throw Exception(
        'Expected header $key to be "$value" but got "$headerValue"',
      );
    }
    return this;
  }
}
