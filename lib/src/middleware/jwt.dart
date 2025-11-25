import 'dart:async';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../http/request.dart';
import '../utils/exception.dart';
import 'middleware.dart';

class JWTPayload {
  final Map<String, dynamic> data;
  
  JWTPayload(this.data);
  
  String? get userId => data['userId'];
  String? get email => data['email'];
  List<String>? get roles => (data['roles'] as List?)?.cast<String>();
}

MiddlewareHandler jwt({
  required String secret,
  String header = 'Authorization',
  String scheme = 'Bearer',
  List<String>? requiredRoles,
}) {
  return (RivetRequest req, FutureOr<dynamic> Function() next) async {
    final authHeader = req.headers.value(header);
    
    if (authHeader == null) {
      throw RivetException('No authorization header', statusCode: 401);
    }

    if (!authHeader.startsWith('$scheme ')) {
      throw RivetException('Invalid authorization format', statusCode: 401);
    }

    final token = authHeader.substring(scheme.length + 1);

    try {
      final jwt = JWT.verify(token, SecretKey(secret));
      final payload = JWTPayload(jwt.payload as Map<String, dynamic>);
      
      // Check roles if required
      if (requiredRoles != null && requiredRoles.isNotEmpty) {
        final userRoles = payload.roles ?? [];
        final hasRole = requiredRoles.any((role) => userRoles.contains(role));
        
        if (!hasRole) {
          throw RivetException('Insufficient permissions', statusCode: 403);
        }
      }
      
      // Attach payload to request params
      req.params['__jwt_userId'] = payload.userId ?? '';
      req.params['__jwt_email'] = payload.email ?? '';
      
      return await next();
    } on JWTExpiredException {
      throw RivetException('Token expired', statusCode: 401);
    } on JWTException catch (e) {
      throw RivetException('Invalid token: ${e.message}', statusCode: 401);
    }
  };
}

// Helper to generate JWT tokens
String generateJWT({
  required String secret,
  required Map<String, dynamic> payload,
  Duration expiration = const Duration(hours: 24),
}) {
  final jwt = JWT(
    payload,
    issuer: 'rivet',
  );
  
  return jwt.sign(
    SecretKey(secret),
    expiresIn: expiration,
  );
}
