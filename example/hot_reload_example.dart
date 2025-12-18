import 'package:rivet/rivet.dart';

/// Hot Reload Example
/// 
/// Demonstrates automatic server restart on file changes.
/// 
/// Try this:
/// 1. Run this file: `dart run example/hot_reload_example.dart`
/// 2. Edit the message below and save
/// 3. Watch the server automatically restart!

void main() async {
  final app = RivetServer();

  // Simple route - try changing the message!
  app.get('/', (req) {
    return RivetResponse.json({
      'message': 'Hello from Rivet with Hot Reload! 🔥',
      'timestamp': DateTime.now().toIso8601String(),
      'tip': 'Edit this message and save to see hot reload in action!',
    });
  });

  // Another route to test
  app.get('/status', (req) {
    return RivetResponse.json({
      'status': 'running',
      'uptime': DateTime.now().toIso8601String(),
      'features': ['hot-reload', 'auto-restart', 'instant-feedback'],
    });
  });

  // POST endpoint
  app.post('/echo', (req) {
    final body = req.jsonBody ?? {};
    return RivetResponse.json({
      'echo': body,
      'receivedAt': DateTime.now().toIso8601String(),
    });
  });

  // Start server with hot reload enabled
  await app.listen(
    port: 3000,
    hotReload: true, // 🔥 Enable hot reload!
  );

  print('');
  print('🎯 Try these commands:');
  print('');
  print('# Test the endpoint');
  print('curl http://localhost:3000');
  print('');
  print('# Test status');
  print('curl http://localhost:3000/status');
  print('');
  print('# Test POST');
  print('curl -X POST http://localhost:3000/echo -H "Content-Type: application/json" -d \'{"test":"data"}\'');
  print('');
  print('💡 Now edit this file and save - watch the magic happen!');
}
