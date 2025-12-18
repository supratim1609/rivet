import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Service for JWT token generation and verification
class JwtService {
  final String secret;
  final Duration defaultExpiry;

  JwtService({
    required this.secret,
    this.defaultExpiry = const Duration(hours: 1),
  });

  /// Sign a JWT token with the given payload
  /// 
  /// [payload] - The data to encode in the token
  /// [expiresIn] - Optional custom expiry duration (defaults to [defaultExpiry])
  /// 
  /// Returns the signed JWT token as a string
  String sign(Map<String, dynamic> payload, {Duration? expiresIn}) {
    final expiry = expiresIn ?? defaultExpiry;
    final now = DateTime.now();
    
    final jwt = JWT(
      {
        ...payload,
        'iat': now.millisecondsSinceEpoch ~/ 1000,
        'exp': now.add(expiry).millisecondsSinceEpoch ~/ 1000,
      },
    );

    return jwt.sign(SecretKey(secret));
  }

  /// Verify a JWT token and return its payload
  /// 
  /// [token] - The JWT token to verify
  /// 
  /// Returns the decoded payload if valid, null if invalid or expired
  Map<String, dynamic>? verify(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(secret));
      return jwt.payload as Map<String, dynamic>;
    } on JWTExpiredException {
      return null;
    } on JWTException {
      return null;
    }
  }

  /// Refresh a JWT token by extending its expiry
  /// 
  /// [token] - The existing JWT token to refresh
  /// [expiresIn] - Optional custom expiry duration (defaults to [defaultExpiry])
  /// 
  /// Returns a new JWT token with extended expiry
  /// Throws [JWTException] if the token is invalid
  String refresh(String token, {Duration? expiresIn}) {
    final payload = verify(token);
    if (payload == null) {
      throw JWTException('Invalid or expired token');
    }

    // Remove old iat and exp claims
    payload.remove('iat');
    payload.remove('exp');

    return sign(payload, expiresIn: expiresIn);
  }

  /// Extract token from Authorization header
  /// 
  /// [authHeader] - The Authorization header value (e.g., "Bearer `<token>`")
  /// 
  /// Returns the token string or null if header is invalid
  static String? extractToken(String? authHeader) {
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return null;
    }
    return authHeader.substring(7);
  }
}
