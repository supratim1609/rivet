// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_gen_example.dart';

// **************************************************************************
// Generator: ClientGeneratorBuilder
// **************************************************************************

class _MyApiClient {
  final String baseUrl;
  final http.Client _client;
  final Map<String, String> _defaultHeaders;

  _MyApiClient(
    this.baseUrl, {
    http.Client? client,
    Map<String, String>? defaultHeaders,
  }) : _client = client ?? http.Client(),
       _defaultHeaders = defaultHeaders ?? {};

  Future<RivetResponse> get() async {
    var url = Uri.parse('$baseUrl/');

    final headers = {..._defaultHeaders};

    final response = await _client.get(url, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return RivetResponse.fromJson(json);
    } else {
      throw RivetClientException(response.statusCode, response.body);
    }
  }

  Future<RivetResponse> get() async {
    var url = Uri.parse('$baseUrl/');

    final headers = {..._defaultHeaders};

    final response = await _client.get(url, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return RivetResponse.fromJson(json);
    } else {
      throw RivetClientException(response.statusCode, response.body);
    }
  }

  Future<RivetResponse> post() async {
    var url = Uri.parse('$baseUrl/');

    final headers = {..._defaultHeaders};

    final response = await _client.post(url, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return RivetResponse.fromJson(json);
    } else {
      throw RivetClientException(response.statusCode, response.body);
    }
  }

  void close() {
    _client.close();
  }
}

class RivetClientException implements Exception {
  final int statusCode;
  final String body;

  RivetClientException(this.statusCode, this.body);

  @override
  String toString() => 'RivetClientException($statusCode): $body';
}
