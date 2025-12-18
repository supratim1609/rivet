import 'package:test/test.dart';
import 'package:rivet/rivet.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  group('Auth Middleware', () {
    late JwtService jwt;
    late RivetServer app;
    // ignore: unused_local_variable
    late int port;

    setUp(() async {
      jwt = JwtService(secret: 'test-secret');
      app = RivetServer(jwtService: jwt);
      
      app.registerController(TestController());

      // Start server on a specific test port to avoid "0" confusion in this specific test suite
      // Ideally we'd capture the ephemeral port, but without public API access, we use a fixed one.
      await app.listen(port: 4001, onStarted: () {});
      port = 4001; 
    });

    tearDown(() async {
      await app.close(force: true);
    });

    test('should allow request with valid token', () async {
      final token = jwt.sign({
        'userId': 1,
        'email': 'test@example.com',
        'roles': ['user'],
      });

      final response = await http.get(
        Uri.parse('http://localhost:4001/test/protected'),
        headers: {'authorization': 'Bearer $token'},
      );

      expect(response.statusCode, equals(200));
      expect(response.body, contains('userId'));
    });

    test('should reject request without token', () async {
      final response = await http.get(
        Uri.parse('http://localhost:4001/test/protected'),
      );

      expect(response.statusCode, equals(401));
      expect(response.body, contains('Missing authorization token'));
    });

    test('should reject request with invalid token', () async {
      final response = await http.get(
        Uri.parse('http://localhost:4001/test/protected'),
        headers: {'authorization': 'Bearer invalid.token.here'},
      );

      expect(response.statusCode, equals(401));
      expect(response.body, contains('Invalid or expired token'));
    });

    test('should reject request with expired token', () async {
      final token = jwt.sign(
        {'userId': 1},
        expiresIn: Duration(milliseconds: 1),
      );

      await Future.delayed(Duration(milliseconds: 100));

      final response = await http.get(
        Uri.parse('http://localhost:4001/test/protected'),
        headers: {'authorization': 'Bearer $token'},
      );

      expect(response.statusCode, equals(401));
    });

    test('should enforce role requirements', () async {
      final token = jwt.sign({
        'userId': 1,
        'roles': ['user'],
      });

      final response = await http.get(
        Uri.parse('http://localhost:4001/test/admin'),
        headers: {'authorization': 'Bearer $token'},
      );

      expect(response.statusCode, equals(403));
      expect(response.body, contains('Insufficient permissions'));
    });

    test('should allow request with correct role', () async {
      final token = jwt.sign({
        'userId': 1,
        'roles': ['admin'],
      });

      final response = await http.get(
        Uri.parse('http://localhost:4001/test/admin'),
        headers: {'authorization': 'Bearer $token'},
      );

      expect(response.statusCode, equals(200));
    });

    test('should handle optional auth with token', () async {
      final token = jwt.sign({'userId': 1});

      final response = await http.get(
        Uri.parse('http://localhost:4001/test/optional'),
        headers: {'authorization': 'Bearer $token'},
      );

      expect(response.statusCode, equals(200));
      expect(response.body, contains('authenticated'));
    });
    
    test('should handle optional auth without token', () async {
        final response = await http.get(
            Uri.parse('http://localhost:4001/test/optional'),
        );
    
        expect(response.statusCode, equals(200));
        expect(response.body, contains('anonymous'));
    });
  });
}

@RivetController()
class TestController {
  @Get('/test/protected')
  @Auth()
  Future<RivetResponse> protected(RivetRequest req) async {
    return RivetResponse.json({
      'message': 'Protected route',
      'user': req.user,
    });
  }

  @Get('/test/admin')
  @Auth(roles: ['admin'])
  Future<RivetResponse> admin(RivetRequest req) async {
    return RivetResponse.json({
      'message': 'Admin only',
      'user': req.user,
    });
  }

  @Get('/test/optional')
  @Auth(optional: true)
  Future<RivetResponse> optional(RivetRequest req) async {
    if (req.user != null) {
      return RivetResponse.json({
        'message': 'Hello authenticated user',
        'user': req.user,
      });
    } else {
      return RivetResponse.json({
        'message': 'Hello anonymous user',
      });
    }
  }
}
