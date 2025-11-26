import 'package:shelf/shelf.dart' as shelf;
import '../middleware/middleware.dart';
import '../http/request.dart';
import '../http/response.dart';

/// Adapter to use Shelf middleware in Rivet
/// 
/// This allows you to use any Shelf middleware package in Rivet.
class ShelfMiddlewareAdapter {
  /// Convert a Shelf Middleware to a Rivet MiddlewareHandler
  /// 
  /// Example:
  /// ```dart
  /// app.use(shelfMiddleware(shelf.logRequests()));
  /// ```
  static MiddlewareHandler fromShelf(shelf.Middleware shelfMiddleware) {
    return (RivetRequest req, next) async {
      // Create a simple Shelf request from Rivet request
      final shelfReq = shelf.Request(
        req.method,
        req.uri,
        headers: _convertHeaders(req.headers),
      );
      
      // Create Shelf handler from Rivet next function
      shelf.Handler shelfNext = (shelf.Request request) async {
        // Call Rivet next
        final rivetRes = await next();
        
        // Convert Rivet response to Shelf response
        if (rivetRes is RivetResponse) {
          return shelf.Response(
            rivetRes.statusCode,
            body: rivetRes.body,
            headers: rivetRes.headers,
          );
        }
        
        // Fallback
        return shelf.Response.ok('');
      };
      
      // Apply Shelf middleware
      final wrappedHandler = shelfMiddleware(shelfNext);
      final shelfRes = await wrappedHandler(shelfReq);
      
      // Convert Shelf response back to Rivet response
      final body = await shelfRes.readAsString();
      return RivetResponse(
        body,
        statusCode: shelfRes.statusCode,
        headers: shelfRes.headers,
      );
    };
  }
  
  /// Convert HttpHeaders to Map<String, String>
  static Map<String, String> _convertHeaders(dynamic headers) {
    final map = <String, String>{};
    headers.forEach((name, values) {
      if (values is List && values.isNotEmpty) {
        map[name] = values.first.toString();
      }
    });
    return map;
  }
}

/// Helper function to use Shelf middleware in Rivet
/// 
/// Example:
/// ```dart
/// import 'package:shelf/shelf.dart' as shelf;
/// import 'package:rivet/adapters.dart';
/// 
/// app.use(shelfMiddleware(shelf.logRequests()));
/// ```
MiddlewareHandler shelfMiddleware(shelf.Middleware middleware) {
  return ShelfMiddlewareAdapter.fromShelf(middleware);
}
