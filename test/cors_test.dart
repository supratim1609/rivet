import 'dart:io';
import 'package:test/test.dart';
import 'package:rivet/rivet.dart';

void main() {
  group('CORS Middleware', () {
    late RivetServer app;
    late int port;

    setUp(() async {
      app = RivetServer();
      
      // Get random available port
      final server = await HttpServer.bind('localhost', 0);
      port = server.port;
      await server.close();
    });

    test('allows all origins by default', () async {
      app.use(cors());
      app.get('/', (req) => RivetResponse.text('ok'));

      app.listen(port: port);
      await Future.delayed(Duration(milliseconds: 200));

      final client = HttpClient();
      final req = await client.get('localhost', port, '/');
      req.headers.set('Origin', 'http://example.com');
      final res = await req.close();
      
      expect(res.headers.value('Access-Control-Allow-Origin'), equals('*'));
      
      await app.close();
    });

    test('handles preflight OPTIONS request', () async {
      app.use(cors());
      
      app.listen(port: port);
      await Future.delayed(Duration(milliseconds: 200));
      
      final client = HttpClient();
      final req = await client.open('OPTIONS', 'localhost', port, '/');
      req.headers.set('Origin', 'http://example.com');
      req.headers.set('Access-Control-Request-Method', 'POST');
      final res = await req.close();
      
      expect(res.statusCode, equals(204));
      expect(res.headers.value('Access-Control-Allow-Methods'), contains('POST'));
      expect(res.headers.value('Access-Control-Allow-Headers'), contains('Content-Type'));
      
      await app.close();
    });

    test('allows specific origin', () async {
      app.use(cors(origin: 'http://trusted.com'));
      app.get('/', (req) => RivetResponse.text('ok'));

      app.listen(port: port);
      await Future.delayed(Duration(milliseconds: 200));

      final client = HttpClient();
      final req = await client.get('localhost', port, '/');
      req.headers.set('Origin', 'http://trusted.com');
      final res = await req.close();
      
      expect(res.headers.value('Access-Control-Allow-Origin'), equals('http://trusted.com'));
      
      await app.close();
    });

    test('blocks unknown origin when list provided', () async {
      app.use(cors(origin: ['http://trusted.com']));
      app.get('/', (req) => RivetResponse.text('ok'));

      app.listen(port: port);
      await Future.delayed(Duration(milliseconds: 200));

      final client = HttpClient();
      final req = await client.get('localhost', port, '/');
      req.headers.set('Origin', 'http://evil.com');
      final res = await req.close();
      
      // Should NOT have the header
      expect(res.headers.value('Access-Control-Allow-Origin'), isNull);
      
      await app.close();
    });

    test('supports credentials', () async {
      app.use(cors(credentials: true));
      app.get('/', (req) => RivetResponse.text('ok'));

      app.listen(port: port);
      await Future.delayed(Duration(milliseconds: 200));

      final client = HttpClient();
      final req = await client.get('localhost', port, '/');
      final res = await req.close();
      
      expect(res.headers.value('Access-Control-Allow-Credentials'), equals('true'));
      
      await app.close();
    });
  });
}
