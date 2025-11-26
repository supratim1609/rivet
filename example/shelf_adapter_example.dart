/// Example demonstrating Shelf adapter usage
/// 
/// This shows how to use Shelf middleware in Rivet
library;

import 'package:rivet/rivet.dart';
import 'package:rivet/adapters.dart';
import 'package:shelf/shelf.dart' as shelf;

void main() async {
  print('🔗 Shelf Adapter Example\n');
  
  final app = RivetServer();
  
  // Use Shelf's logRequests middleware in Rivet!
  app.use(shelfMiddleware(shelf.logRequests()));
  
  // Add Rivet routes
  app.get('/hello', (req) {
    return RivetResponse.json({'message': 'Hello from Rivet with Shelf middleware!'});
  });
  
  app.get('/user/:id', (req) {
    return RivetResponse.json({
      'id': req.params['id'],
      'name': 'User ${req.params['id']}'
    });
  });
  
  print('✅ Rivet server with Shelf middleware configured');
  print('   Routes:');
  print('   - GET /hello');
  print('   - GET /user/:id');
  print('   - Using shelf.logRequests() middleware\n');
  print('🎉 Shelf adapter working! Rivet can now use Shelf middleware.');
}
