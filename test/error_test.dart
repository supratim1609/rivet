import 'dart:io';
import 'package:test/test.dart';
import 'package:rivet/rivet.dart';

void main() {
  group('Global Error Handling', () {
    late RivetServer app;
    late int port;

    setUp(() async {
      app = RivetServer();

      // Start server on random port
      final server = await HttpServer.bind('localhost', 0);
      port = server.port;
      await server.close();

      // Run listen unawaited
      app.listen(port: port);
      await Future.delayed(Duration(milliseconds: 100));
    });

    test('catches RivetException and returns correct status', () async {
      app.get('/controlled', (req) {
        throw RivetException('Not Allowed', statusCode: 403);
      });

      final client = HttpClient();
      final req = await client.get('localhost', port, '/controlled');
      final res = await req.close();

      expect(res.statusCode, equals(403));
      final body = await res.transform(SystemEncoding().decoder).join();
      expect(body, equals('Not Allowed'));
    });

    test('catches unknown exception and returns 500', () async {
      app.get('/crash', (req) {
        throw Exception('Boom');
      });

      final client = HttpClient();
      final req = await client.get('localhost', port, '/crash');
      final res = await req.close();

      expect(res.statusCode, equals(500));
      final body = await res.transform(SystemEncoding().decoder).join();
      expect(body, equals('Internal Server Error'));
    });

    test('returns JSON when requested', () async {
      app.get('/json-error', (req) {
        throw RivetException(
          'Bad Input',
          statusCode: 400,
          details: {'field': 'email'},
        );
      });

      final client = HttpClient();
      final req = await client.get('localhost', port, '/json-error');
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final res = await req.close();

      expect(res.statusCode, equals(400));
      expect(res.headers.contentType?.mimeType, equals('application/json'));

      final body = await res.transform(SystemEncoding().decoder).join();

      expect(body, contains('"error":"Bad Input"'));
      expect(body, contains('"details":{"field":"email"}'));
    });
  });
}
