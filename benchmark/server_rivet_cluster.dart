import 'dart:io';
import 'package:rivet/rivet.dart';

// Top-level setup function required for cluster mode
void appSetup(RivetServer app) {
  // Simple JSON
  app.get('/hello', (req) {
    return RivetResponse.json({'message': 'Hello, World!'});
  });

  // Dynamic Route
  app.get('/user/:id', (req) {
    return RivetResponse.json({
      'id': req.params['id'],
      'name': 'John Doe',
      'email': 'john@example.com'
    });
  });
}

void main() {
  // Use all available cores
  final workers = Platform.numberOfProcessors;
  
  RivetServer.cluster(
    builder: appSetup,
    workers: workers,
    port: 3000,
  );
}
