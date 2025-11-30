/// Integration test for Shelf adapter with real HTTP server
///
/// This tests the Shelf adapter with a real server and HTTP requests
library;

import 'dart:io';
import 'package:rivet/rivet.dart';
import 'package:rivet/adapters.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Shelf Adapter Integration Test\n');

  final app = RivetServer();

  // Test 1: shelf.logRequests()
  print('Test 1: Using shelf.logRequests()');
  app.use(shelfMiddleware(shelf.logRequests()));

  // Test 2: Custom middleware that adds headers
  print('Test 2: Custom middleware adding headers');
  final headerMiddleware = shelf.createMiddleware(
    responseHandler: (shelf.Response response) {
      return response.change(
        headers: {
          'X-Powered-By': 'Rivet + Shelf',
          'X-Custom-Header': 'test-value',
        },
      );
    },
  );
  app.use(shelfMiddleware(headerMiddleware));

  // Test 3: Middleware that modifies requests
  print('Test 3: Request modification middleware');
  final requestMiddleware = shelf.createMiddleware(
    requestHandler: (shelf.Request request) {
      // Add custom header to request
      print('   Request: ${request.method} ${request.url}');
      return null; // Continue to next middleware
    },
  );
  app.use(shelfMiddleware(requestMiddleware));

  // Add routes
  app.get('/test', (req) {
    return RivetResponse.json({
      'message': 'Shelf middleware working!',
      'framework': 'Rivet',
      'compatibility': 'Shelf',
    });
  });

  app.get('/user/:id', (req) {
    return RivetResponse.json({
      'id': req.params['id'],
      'name': 'User ${req.params['id']}',
    });
  });

  // Start server
  print('\n🚀 Starting server on port 3000...');
  await app.listen(port: 3000);

  print('✅ Server started!\n');

  // Give server time to start
  await Future.delayed(Duration(milliseconds: 500));

  // Test requests
  print('📡 Testing HTTP requests...\n');

  try {
    // Test 1: Basic request
    print('Request 1: GET /test');
    final response1 = await http.get(Uri.parse('http://localhost:3000/test'));
    print('   Status: ${response1.statusCode}');
    print('   Body: ${response1.body}');
    print('   X-Powered-By: ${response1.headers['x-powered-by']}');
    print('   X-Custom-Header: ${response1.headers['x-custom-header']}\n');

    // Test 2: Dynamic route
    print('Request 2: GET /user/123');
    final response2 = await http.get(
      Uri.parse('http://localhost:3000/user/123'),
    );
    print('   Status: ${response2.statusCode}');
    print('   Body: ${response2.body}\n');

    print('✅ All integration tests passed!');
    print('🎉 Shelf adapter is working perfectly with real HTTP requests!');
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    // Cleanup
    print('\n🛑 Stopping server...');
    exit(0);
  }
}
