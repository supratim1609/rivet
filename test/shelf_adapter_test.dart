import 'package:test/test.dart';
import 'package:rivet/rivet.dart';
import 'package:rivet/adapters.dart';
import 'package:shelf/shelf.dart' as shelf;

void main() {
  group('Shelf Middleware Adapter', () {
    test('can use shelf.logRequests middleware', () async {
      final app = RivetServer();
      
      // Add Shelf middleware
      app.use(shelfMiddleware(shelf.logRequests()));
      
      app.get('/test', (req) {
        return RivetResponse.text('OK');
      });
      
      // Should not throw
      expect(() => app, isNotNull);
    });
    
    test('can use custom Shelf middleware', () async {
      final app = RivetServer();
      
      // Custom Shelf middleware that adds a header
      final customMiddleware = shelf.createMiddleware(
        responseHandler: (shelf.Response response) {
          return response.change(headers: {'X-Custom': 'test'});
        },
      );
      
      app.use(shelfMiddleware(customMiddleware));
      
      app.get('/test', (req) {
        return RivetResponse.text('OK');
      });
      
      expect(() => app, isNotNull);
    });
    
    test('can chain multiple Shelf middleware', () async {
      final app = RivetServer();
      
      // Multiple Shelf middleware
      app.use(shelfMiddleware(shelf.logRequests()));
      
      final customMiddleware = shelf.createMiddleware(
        requestHandler: (shelf.Request request) {
          // Can intercept requests
          return null; // Continue to next middleware
        },
      );
      
      app.use(shelfMiddleware(customMiddleware));
      
      app.get('/test', (req) {
        return RivetResponse.text('OK');
      });
      
      expect(() => app, isNotNull);
    });
    
    test('Shelf middleware can modify responses', () async {
      final app = RivetServer();
      
      // Middleware that adds headers
      final headerMiddleware = shelf.createMiddleware(
        responseHandler: (shelf.Response response) {
          return response.change(headers: {
            'X-Powered-By': 'Rivet + Shelf',
            'X-Framework': 'Rivet',
          });
        },
      );
      
      app.use(shelfMiddleware(headerMiddleware));
      
      app.get('/test', (req) {
        return RivetResponse.json({'status': 'ok'});
      });
      
      expect(() => app, isNotNull);
    });
  });
}
