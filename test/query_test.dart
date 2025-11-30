import 'dart:io';
import 'package:test/test.dart';
import 'package:rivet/src/http/request.dart';

class StubHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Stub HttpRequest to test RivetRequest
class StubHttpRequest implements HttpRequest {
  @override
  final Uri uri;

  @override
  final String method;

  @override
  final HttpHeaders headers;

  StubHttpRequest(this.uri, {this.method = 'GET'})
    : headers = StubHttpHeaders();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Helper to create RivetRequest from URI
RivetRequest createRequest(String url) {
  final uri = Uri.parse(url);
  return RivetRequest.from(StubHttpRequest(uri));
}

void main() {
  group('RivetRequest Query Helpers', () {
    test('parses single query parameter', () {
      final req = createRequest('http://localhost/search?q=hello');
      expect(req.query['q'], equals('hello'));
    });

    test('parses multiple values for same key', () {
      final req = createRequest('http://localhost/filter?ids=1&ids=2');
      expect(req.queryAll['ids'], equals(['1', '2']));
      // Uri.queryParameters uses the last value for duplicates
      expect(req.query['ids'], equals('2'));
    });

    test('getInt returns integer or null', () {
      final req = createRequest('http://localhost/?page=10&bad=abc');
      expect(req.getInt('page'), equals(10));
      expect(req.getInt('bad'), isNull);
      expect(req.getInt('missing'), isNull);
    });

    test('getDouble returns double or null', () {
      final req = createRequest('http://localhost/?score=9.5&bad=abc');
      expect(req.getDouble('score'), equals(9.5));
      expect(req.getDouble('bad'), isNull);
    });

    test('getBool returns boolean', () {
      final req = createRequest(
        'http://localhost/?active=true&flag=1&off=false',
      );
      expect(req.getBool('active'), isTrue);
      expect(req.getBool('flag'), isTrue);
      expect(req.getBool('off'), isFalse);
      expect(req.getBool('missing'), isNull);
    });
  });
}
