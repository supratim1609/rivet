import 'package:test/test.dart';
import 'package:rivet/rivet.dart';

void main() {
  group('JwtService', () {
    late JwtService jwt;

    setUp(() {
      jwt = JwtService(
        secret: 'test-secret-key',
        defaultExpiry: Duration(hours: 1),
      );
    });

    test('should sign and verify a valid token', () {
      final payload = {
        'userId': 123,
        'email': 'test@example.com',
        'roles': ['user'],
      };

      final token = jwt.sign(payload);
      expect(token, isNotEmpty);

      final decoded = jwt.verify(token);
      expect(decoded, isNotNull);
      expect(decoded!['userId'], equals(123));
      expect(decoded['email'], equals('test@example.com'));
      expect(decoded['roles'], equals(['user']));
    });

    test('should include iat and exp claims', () {
      final payload = {'userId': 123};
      final token = jwt.sign(payload);
      final decoded = jwt.verify(token);

      expect(decoded, isNotNull);
      expect(decoded!['iat'], isA<int>());
      expect(decoded['exp'], isA<int>());
      expect(decoded['exp'], greaterThan(decoded['iat']));
    });

    test('should reject expired token', () {
      final payload = {'userId': 123};
      final token = jwt.sign(payload, expiresIn: Duration(milliseconds: 1));

      // Wait for token to expire
      sleep(Duration(milliseconds: 100));

      final decoded = jwt.verify(token);
      expect(decoded, isNull);
    });

    test('should reject invalid token', () {
      final decoded = jwt.verify('invalid.token.here');
      expect(decoded, isNull);
    });

    test('should reject token with wrong secret', () {
      final otherJwt = JwtService(secret: 'different-secret');
      final token = otherJwt.sign({'userId': 123});

      final decoded = jwt.verify(token);
      expect(decoded, isNull);
    });

    test('should refresh a valid token', () {
      final payload = {'userId': 123, 'email': 'test@example.com'};
      final oldToken = jwt.sign(payload);

      // Wait a moment to ensure different timestamp
      sleep(Duration(seconds: 1));

      final newToken = jwt.refresh(oldToken);
      expect(newToken, isNotEmpty);
      expect(newToken, isNot(equals(oldToken)));

      final decoded = jwt.verify(newToken);
      expect(decoded, isNotNull);
      expect(decoded!['userId'], equals(123));
      expect(decoded['email'], equals('test@example.com'));
    });

    test('should throw on refresh of invalid token', () {
      expect(
        () => jwt.refresh('invalid.token'),
        throwsA(isA<Exception>()),
      );
    });

    test('should extract token from Bearer header', () {
      final token = JwtService.extractToken('Bearer abc123');
      expect(token, equals('abc123'));
    });

    test('should return null for invalid auth header', () {
      expect(JwtService.extractToken(null), isNull);
      expect(JwtService.extractToken(''), isNull);
      expect(JwtService.extractToken('Basic abc123'), isNull);
      expect(JwtService.extractToken('abc123'), isNull);
    });

    test('should support custom expiry', () {
      final token = jwt.sign(
        {'userId': 123},
        expiresIn: Duration(seconds: 30),
      );

      final decoded = jwt.verify(token);
      expect(decoded, isNotNull);

      final iat = decoded!['iat'] as int;
      final exp = decoded['exp'] as int;
      expect(exp - iat, equals(30));
    });
  });

  group('PasswordHasher', () {
    test('should hash a password', () {
      final hash = PasswordHasher.hash('password123');
      expect(hash, isNotEmpty);
      expect(hash.length, greaterThan(50)); // Bcrypt hashes are long
      expect(hash.startsWith('\$2'), isTrue); // Bcrypt prefix
    });

    test('should verify correct password', () {
      final password = 'mySecurePassword123!';
      final hash = PasswordHasher.hash(password);

      final isValid = PasswordHasher.verify(password, hash);
      expect(isValid, isTrue);
    });

    test('should reject incorrect password', () {
      final hash = PasswordHasher.hash('correct-password');
      final isValid = PasswordHasher.verify('wrong-password', hash);
      expect(isValid, isFalse);
    });

    test('should generate different hashes for same password', () {
      final password = 'test123';
      final hash1 = PasswordHasher.hash(password);
      final hash2 = PasswordHasher.hash(password);

      expect(hash1, isNot(equals(hash2))); // Different salts
      expect(PasswordHasher.verify(password, hash1), isTrue);
      expect(PasswordHasher.verify(password, hash2), isTrue);
    });

    test('should handle empty password', () {
      final hash = PasswordHasher.hash('');
      expect(hash, isNotEmpty);
      expect(PasswordHasher.verify('', hash), isTrue);
      expect(PasswordHasher.verify('not-empty', hash), isFalse);
    });

    test('should handle special characters', () {
      final password = 'p@ssw0rd!#\$%^&*()';
      final hash = PasswordHasher.hash(password);
      expect(PasswordHasher.verify(password, hash), isTrue);
    });

    test('should return false for invalid hash format', () {
      final isValid = PasswordHasher.verify('password', 'invalid-hash');
      expect(isValid, isFalse);
    });
  });
}

void sleep(Duration duration) {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    // Busy wait
  }
}
