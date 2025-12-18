/// Controller scanner using dart:mirrors for reflection
library;

import 'dart:mirrors';
import '../annotations.dart';
import '../http/response.dart';
import '../middleware/middleware.dart';
import '../utils/cache.dart';
import '../auth/jwt_service.dart';
import '../auth/auth_middleware.dart';
import 'validators.dart';

/// Scans a controller and extracts route definitions
class ControllerScanner {
  final JwtService? jwtService;

  ControllerScanner({this.jwtService});

  /// Scan a controller instance and return route definitions
  List<RouteDefinition> scanController(Object controller) {
    final routes = <RouteDefinition>[];
    final mirror = reflect(controller);
    final classMirror = mirror.type;

    // Scan all public methods
    for (final declaration in classMirror.declarations.values) {
      if (declaration is! MethodMirror) continue;
      if (declaration.isPrivate) continue;
      if (declaration.isStatic) continue;

      final routeInfo = _extractRouteInfo(declaration);
      if (routeInfo != null) {
        routes.add(RouteDefinition(
          method: routeInfo.httpMethod,
          path: routeInfo.path,
          handler: (req) async {
            // Invoke the method on the controller instance
            final result = mirror.invoke(declaration.simpleName, [req]);
            final reflectee = result.reflectee;
            // Handle both sync and async returns
            if (reflectee is Future) {
              return await reflectee;
            }
            return reflectee;
          },
          middleware: _extractMiddleware(declaration),
          validators: _extractValidators(declaration),
        ));
      }
    }

    return routes;
  }

  /// Extract route information from method annotations
  _RouteInfo? _extractRouteInfo(MethodMirror method) {
    for (final metadata in method.metadata) {
      final instance = metadata.reflectee;
      if (instance is Get) return _RouteInfo('GET', instance.path);
      if (instance is Post) return _RouteInfo('POST', instance.path);
      if (instance is Put) return _RouteInfo('PUT', instance.path);
      if (instance is Delete) return _RouteInfo('DELETE', instance.path);
      if (instance is Patch) return _RouteInfo('PATCH', instance.path);
    }
    return null;
  }

  /// Extract middleware from method annotations
  List<MiddlewareHandler> _extractMiddleware(MethodMirror method) {
    final middleware = <MiddlewareHandler>[];

    for (final metadata in method.metadata) {
      final instance = metadata.reflectee;

      if (instance is Auth) {
        // Create auth middleware using JWT service
        if (jwtService == null) {
          throw Exception(
            '@Auth decorator requires JwtService to be provided to ControllerScanner',
          );
        }
        middleware.add(
          createAuthMiddleware(
            jwtService: jwtService!,
            requiredRoles: instance.roles.isEmpty ? null : instance.roles,
            optional: instance.optional,
          ),
        );
      }

      if (instance is UseMiddleware) {
        // Add custom middleware
        for (final mw in instance.middleware) {
          if (mw is MiddlewareHandler) {
            middleware.add(mw);
          }
        }
      }

      if (instance is CacheResponse) {
        // Add cache middleware
        middleware.add(_createCacheMiddleware(instance.ttl, instance.key));
      }
    }

    return middleware;
  }

  /// Extract validators from method annotations
  List<Validator> _extractValidators(MethodMirror method) {
    for (final metadata in method.metadata) {
      final instance = metadata.reflectee;
      if (instance is Validate) {
        // Convert annotation validators to actual validators
        return instance.validators.map((v) {
          if (v is Required) {
            return RequiredValidator(v.field, message: v.message);
          } else if (v is Email) {
            return EmailValidator(v.field, message: v.message);
          } else if (v is MinLength) {
            return MinLengthValidator(v.field, v.length, message: v.message);
          } else if (v is MaxLength) {
            return MaxLengthValidator(v.field, v.length, message: v.message);
          } else if (v is Min) {
            return MinValidator(v.field, v.value, message: v.message);
          } else if (v is Max) {
            return MaxValidator(v.field, v.value, message: v.message);
          }
          throw Exception('Unknown validator type: ${v.runtimeType}');
        }).toList();
      }
    }
    return [];
  }

  /// Create cache middleware
  MiddlewareHandler _createCacheMiddleware(int ttlSeconds, String? customKey) {
    return (req, next) async {
      // Generate cache key
      final key = customKey ?? '${req.method}:${req.path}:${req.query}';

      // Try to get from cache
      final cached = await cache.get<RivetResponse>(key);
      if (cached != null) {
        return cached;
      }

      // Execute handler
      final response = await next();

      // Cache successful responses only
      if (response is RivetResponse && response.statusCode >= 200 && response.statusCode < 300) {
        await cache.set(
          key,
          response,
          ttl: Duration(seconds: ttlSeconds),
        );
      }

      return response;
    };
  }
}


/// Internal class to hold route information
class _RouteInfo {
  final String httpMethod;
  final String path;
  _RouteInfo(this.httpMethod, this.path);
}

/// Route definition extracted from controller
class RouteDefinition {
  final String method;
  final String path;
  final Function handler;
  final List<MiddlewareHandler> middleware;
  final List<Validator> validators;

  RouteDefinition({
    required this.method,
    required this.path,
    required this.handler,
    this.middleware = const [],
    this.validators = const [],
  });
}
