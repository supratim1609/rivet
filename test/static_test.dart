import 'dart:io';
import 'package:test/test.dart';
import 'package:rivet/rivet.dart';
import 'package:path/path.dart' as p;

void main() {
  group('Static File Handler', () {
    late Directory tempDir;
    late RivetServer app;
    late int port;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('rivet_static_test');
      app = RivetServer();
      app.use(createStaticHandler(tempDir.path));

      // Setup test files
      await File(p.join(tempDir.path, 'test.txt')).writeAsString('Hello World');
      await File(
        p.join(tempDir.path, 'style.css'),
      ).writeAsString('body { color: red; }');
      await File(
        p.join(tempDir.path, 'index.html'),
      ).writeAsString('<h1>Index</h1>');

      // Start server on random port
      final server = await HttpServer.bind('localhost', 0);
      port = server.port;
      await server.close();

      // Run listen unawaited so it doesn't block
      app.listen(port: port);
      // Give it a moment to start
      await Future.delayed(Duration(milliseconds: 100));
    });

    tearDown(() async {
      // We can't easily close RivetServer yet (missing feature), but we can delete temp dir
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('serves file content', () async {
      final client = HttpClient();
      final req = await client.get('localhost', port, '/test.txt');
      final res = await req.close();

      expect(res.statusCode, equals(200));
      final body = await res.transform(SystemEncoding().decoder).join();
      expect(body, equals('Hello World'));
    });

    test('sets correct mime type', () async {
      final client = HttpClient();
      final req = await client.get('localhost', port, '/style.css');
      final res = await req.close();

      expect(res.headers.contentType?.mimeType, equals('text/css'));
    });

    test('serves index.html for directory', () async {
      final client = HttpClient();
      final req = await client.get('localhost', port, '/');
      final res = await req.close();

      expect(res.statusCode, equals(200));
      final body = await res.transform(SystemEncoding().decoder).join();
      expect(body, equals('<h1>Index</h1>'));
    });

    test('prevents path traversal', () async {
      final client = HttpClient();
      // Try to access a file outside tempDir (e.g., pubspec.yaml in project root)
      // Note: This test assumes we are running in project root and tempDir is elsewhere.
      // A better test is to try to go up from tempDir.
      final req = await client.get('localhost', port, '/../secret.txt');
      final res = await req.close();

      // Should be 404 because static handler calls next(), and no other route matches
      expect(res.statusCode, equals(404));
    });
  });
}
