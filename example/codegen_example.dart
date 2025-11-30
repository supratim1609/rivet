/// Example demonstrating the auto-generated Flutter client
///
/// This shows how to use the code generation system
library;

import 'package:rivet/src/codegen/models.dart';
import 'package:rivet/src/codegen/type_inference.dart';
import 'package:rivet/src/codegen/client_generator.dart';

void main() {
  // Example: Simulating route analysis
  // In real implementation, this would parse actual Dart code

  // Define routes (would be extracted from RivetServer code)
  final routes = [
    RouteDefinition(
      method: 'GET',
      path: '/user/:id',
      pathParams: ['id'],
      responseType: 'User',
    ),
    RouteDefinition(
      method: 'POST',
      path: '/login',
      pathParams: [],
      requestBodyType: 'LoginRequest',
      responseType: 'LoginResponse',
    ),
    RouteDefinition(
      method: 'GET',
      path: '/posts',
      pathParams: [],
      queryParams: {'page': 'int', 'limit': 'int'},
      responseType: 'List<Post>',
    ),
  ];

  // Infer types from example responses
  final inference = TypeInference();

  // User type
  final userType = inference.inferFromMap('User', {
    'id': '123',
    'name': 'John Doe',
    'email': 'john@example.com',
  });

  // LoginRequest type
  final loginRequestType = inference.inferFromMap('LoginRequest', {
    'email': 'user@example.com',
    'password': 'secret',
  });

  // LoginResponse type
  final loginResponseType = inference.inferFromMap('LoginResponse', {
    'token': 'jwt-token-here',
    'user': {'id': '123', 'name': 'John Doe', 'email': 'john@example.com'},
  });

  // Post type
  final postType = inference.inferFromMap('Post', {
    'id': '1',
    'title': 'Hello World',
    'content': 'This is a post',
    'author': {'id': '123', 'name': 'John Doe'},
  });

  // Get all types
  final types = inference.knownTypes.values.toList();

  // Generate client
  final generator = ClientGenerator();
  final clientCode = generator.generate(routes: routes, types: types);

  // Print generated code
  print(clientCode);
}
