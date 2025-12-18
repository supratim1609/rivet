import '../http/request.dart';
import '../http/response.dart';
import '../middleware/middleware.dart';
import 'jwt_service.dart';

/// Create an authentication middleware that validates JWT tokens
/// 
/// [jwtService] - The JWT service to use for token verification
/// [requiredRoles] - Optional list of roles required to access the route
/// [optional] - If true, allows requests without tokens (but still validates if present)
/// 
/// Returns a middleware function that:
/// - Extracts JWT from Authorization header
/// - Verifies the token
/// - Attaches user data to req.user
/// - Checks role requirements
MiddlewareHandler createAuthMiddleware({
  required JwtService jwtService,
  List<String>? requiredRoles,
  bool optional = false,
}) {
  return (RivetRequest req, next) async {
    // Extract token from Authorization header
    final authHeader = req.headers.value('authorization');
    final token = JwtService.extractToken(authHeader);

    // If no token and auth is optional, continue
    if (token == null) {
      if (optional) {
        return next();
      }
      return RivetResponse.unauthorized('Missing authorization token');
    }

    // Verify token
    final payload = jwtService.verify(token);
    if (payload == null) {
      return RivetResponse.unauthorized('Invalid or expired token');
    }

    // Attach user to request
    req.user = payload;

    // Check role requirements
    if (requiredRoles != null && requiredRoles.isNotEmpty) {
      final userRoles = payload['roles'] as List<dynamic>?;
      if (userRoles == null) {
        return RivetResponse.forbidden('User has no roles');
      }

      final hasRequiredRole = requiredRoles.any(
        (role) => userRoles.contains(role),
      );

      if (!hasRequiredRole) {
        return RivetResponse.forbidden(
          'Insufficient permissions. Required roles: ${requiredRoles.join(", ")}',
        );
      }
    }

    return next();
  };
}

/// Middleware to require authentication (shorthand)
MiddlewareHandler requireAuth(JwtService jwtService) {
  return createAuthMiddleware(jwtService: jwtService);
}

/// Middleware to require specific roles
MiddlewareHandler requireRoles(JwtService jwtService, List<String> roles) {
  return createAuthMiddleware(jwtService: jwtService, requiredRoles: roles);
}

/// Middleware for optional authentication (validates if present, but doesn't require)
MiddlewareHandler optionalAuth(JwtService jwtService) {
  return createAuthMiddleware(jwtService: jwtService, optional: true);
}

