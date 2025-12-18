import 'package:rivet/rivet.dart';
import 'package:rivet/src/codegen/metadata_extractor.dart';
import 'package:rivet/src/codegen/dart_client_generator.dart';
import 'dart:io';

/// Example demonstrating automatic Dart client generation
/// 
/// This example shows how to:
/// 1. Create a controller with routes
/// 2. Extract metadata from the controller
/// 3. Generate a type-safe Dart client
/// 4. Use the generated client

void main() async {
  print('🎨 Rivet Client Generation Example');
  print('===================================');
  print('');
  
  // Create a sample controller
  final controller = UserController();
  
  // Extract metadata from controller
  print('📝 Extracting metadata from controller...');
  final extractor = ControllerMetadataExtractor();
  final metadata = extractor.extractFromController(controller);
  
  print('   Found ${metadata.routes.length} routes in ${metadata.name}');
  for (final route in metadata.routes) {
    print('   - ${route.method} ${route.path}');
  }
  print('');
  
  // Generate Dart client
  print('🚀 Generating Dart client...');
  final generator = DartClientGenerator(
    controllers: [metadata],
    className: 'UserApiClient',
    baseUrl: 'http://localhost:3000',
    includeRiverpod: true,
  );
  
  final clientCode = generator.generate();
  
  // Save to file
  final outputFile = File('lib/generated/user_api_client.dart');
  await outputFile.parent.create(recursive: true);
  await outputFile.writeAsString(clientCode);
  
  print('   ✅ Client generated: ${outputFile.path}');
  print('   📦 Lines of code: ${clientCode.split('\n').length}');
  print('');
  
  print('🎉 Client generation complete!');
  print('');
  print('Usage in Flutter:');
  print('');
  print('  final client = UserApiClient();');
  print('  client.setAuthToken("your-jwt-token");');
  print('  ');
  print('  final users = await client.getUsers();');
  print('  final user = await client.getUser("123");');
  print('  ');
  print('  // With Riverpod:');
  print('  final users = ref.watch(getUsersProvider);');
}

// ============================================================================
// Sample Controller
// ============================================================================

@RivetController(path: '/api/users')
class UserController {
  @Get('/')
  Future<List<User>> getUsers() async {
    return [
      User(id: '1', email: 'john@example.com', name: 'John Doe'),
      User(id: '2', email: 'jane@example.com', name: 'Jane Smith'),
    ];
  }
  
  @Get('/:id')
  Future<User> getUser(RivetRequest req) async {
    final id = req.params['id']!;
    return User(id: id, email: 'user@example.com', name: 'User $id');
  }
  
  @Post('/')
  @Auth()
  Future<User> createUser(RivetRequest req) async {
    final body = req.jsonBody!;
    return User(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      email: body['email'],
      name: body['name'],
    );
  }
  
  @Put('/:id')
  @Auth()
  Future<User> updateUser(RivetRequest req) async {
    final id = req.params['id']!;
    final body = req.jsonBody!;
    return User(
      id: id,
      email: body['email'],
      name: body['name'],
    );
  }
  
  @Delete('/:id')
  @Auth(roles: ['admin'])
  Future<void> deleteUser(RivetRequest req) async {
    final id = req.params['id']!;
    print('Deleting user: $id');
  }
}

// ============================================================================
// Shared Types
// ============================================================================

class User {
  final String id;
  final String email;
  final String name;
  
  User({
    required this.id,
    required this.email,
    required this.name,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
  };
  
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    name: json['name'],
  );
}
