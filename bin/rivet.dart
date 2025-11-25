#!/usr/bin/env dart

import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    printHelp();
    exit(1);
  }

  final command = args[0];

  switch (command) {
    case 'create':
      if (args.length < 2) {
        print('Error: Project name required');
        print('Usage: rivet create <project-name>');
        exit(1);
      }
      await createProject(args[1]);
      break;
    case 'generate':
    case 'g':
      if (args.length < 2) {
        print('Error: Type required');
        print('Usage: rivet generate <type> [name]');
        exit(1);
      }
      final type = args[1];
      final name = args.length > 2 ? args[2] : '';
      await generate(type, name);
      break;
    case 'help':
    case '--help':
    case '-h':
      printHelp();
      break;
    default:
      print('Unknown command: $command');
      printHelp();
      exit(1);
  }
}

void printHelp() {
  print('''
Rivet CLI - The Ultimate Dart Backend Framework

Usage:
  rivet <command> [arguments]

Commands:
  create <name>              Create a new Rivet project
  generate <type> [name]     Generate code
    - controller <name>      Generate a controller
    - middleware <name>      Generate middleware
    - model <name>           Generate a model
    - client                 Generate Flutter API client
  help                       Show this help message

Examples:
  rivet create my-api
  rivet generate controller users
  rivet generate middleware auth
  rivet generate client --output lib/api_client.dart
''');
}

Future<void> createProject(String name) async {
  print('🚀 Creating Rivet project: $name');

  final dir = Directory(name);
  if (await dir.exists()) {
    print('❌ Error: Directory $name already exists');
    exit(1);
  }

  await dir.create();
  
  // Create directory structure
  await Directory('$name/lib').create();
  await Directory('$name/lib/controllers').create();
  await Directory('$name/lib/middleware').create();
  await Directory('$name/lib/models').create();
  await Directory('$name/test').create();

  // Create pubspec.yaml
  await File('$name/pubspec.yaml').writeAsString('''
name: $name
description: A Rivet backend application
version: 1.0.0

environment:
  sdk: ^3.0.0

dependencies:
  rivet: ^1.0.0

dev_dependencies:
  test: ^1.24.0
''');

  // Create main server file
  await File('$name/lib/server.dart').writeAsString('''
import 'package:rivet/rivet.dart';

void main() async {
  final app = RivetServer();

  // Middleware
  app.use(cors());
  app.use(requestLogger());

  // Routes
  app.get('/', (req) {
    return RivetResponse.json({'message': 'Welcome to $name!'});
  });

  await app.listen(port: 3000);
}
''');

  // Create README
  await File('$name/README.md').writeAsString('''
# $name

A Rivet backend application.

## Getting Started

```bash
dart run lib/server.dart
```

## Build

```bash
dart compile exe lib/server.dart -o build/server
```
''');

  print('✅ Project created successfully!');
  print('');
  print('Next steps:');
  print('  cd $name');
  print('  dart pub get');
  print('  dart run lib/server.dart');
}

Future<void> generate(String type, String name) async {
  switch (type) {
    case 'controller':
      await generateController(name);
      break;
    case 'middleware':
      await generateMiddleware(name);
      break;
    case 'model':
      await generateModel(name);
      break;
    case 'client':
      await generateClient();
      break;
    default:
      print('Unknown type: $type');
      print('Available types: controller, middleware, model, client');
      exit(1);
  }
}

Future<void> generateController(String name) async {
  final fileName = 'lib/controllers/${name}_controller.dart';
  final className = '${name[0].toUpperCase()}${name.substring(1)}Controller';

  await File(fileName).writeAsString('''
import 'package:rivet/rivet.dart';

class $className {
  static void register(RivetServer app) {
    app.get('/$name', index);
    app.get('/$name/:id', show);
    app.post('/$name', create);
    app.put('/$name/:id', update);
    app.delete('/$name/:id', destroy);
  }

  static RivetResponse index(RivetRequest req) {
    return RivetResponse.json({'message': 'List all $name'});
  }

  static RivetResponse show(RivetRequest req) {
    final id = req.params['id'];
    return RivetResponse.json({'message': 'Show $name', 'id': id});
  }

  static RivetResponse create(RivetRequest req) {
    return RivetResponse.created({'message': '$name created'});
  }

  static RivetResponse update(RivetRequest req) {
    final id = req.params['id'];
    return RivetResponse.json({'message': '$name updated', 'id': id});
  }

  static RivetResponse destroy(RivetRequest req) {
    final id = req.params['id'];
    return RivetResponse.noContent();
  }
}
''');

  print('✅ Controller created: $fileName');
}

Future<void> generateMiddleware(String name) async {
  final fileName = 'lib/middleware/${name}_middleware.dart';

  await File(fileName).writeAsString('''
import 'dart:async';
import 'package:rivet/rivet.dart';

MiddlewareHandler ${name}Middleware() {
  return (RivetRequest req, FutureOr<dynamic> Function() next) async {
    // Add your middleware logic here
    print('[${name.toUpperCase()}] Processing request');
    
    return await next();
  };
}
''');

  print('✅ Middleware created: $fileName');
}

Future<void> generateModel(String name) async {
  final fileName = 'lib/models/${name}_model.dart';
  final className = '${name[0].toUpperCase()}${name.substring(1)}';

  await File(fileName).writeAsString('''
class $className {
  final int? id;
  final String name;
  final DateTime createdAt;

  $className({
    this.id,
    required this.name,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory $className.fromJson(Map<String, dynamic> json) {
    return $className(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
''');

  print('✅ Model created: $fileName');
}

Future<void> generateClient() async {
  print('🔍 Generating Flutter API client...');
  
  final outputPath = 'lib/api_client.dart';
  
  final clientCode = '''
// AUTO-GENERATED CODE - DO NOT EDIT
// Generated by Rivet Code Generator
// Generated at: ${DateTime.now()}

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Auto-generated API client for your Rivet backend
/// 
/// Usage:
/// ```dart
/// final client = RivetClient('http://localhost:3000');
/// final result = await client.get('/endpoint');
/// ```
class RivetClient {
  final String baseUrl;
  final http.Client _client;
  final Map<String, String> _defaultHeaders;

  RivetClient(
    this.baseUrl, {
    http.Client? client,
    Map<String, String>? defaultHeaders,
  })  : _client = client ?? http.Client(),
        _defaultHeaders = defaultHeaders ?? {};

  /// Make a GET request
  Future<Map<String, dynamic>> get(String path, {Map<String, String>? queryParams}) async {
    var url = Uri.parse('\\\$baseUrl\\\$path');
    
    if (queryParams != null && queryParams.isNotEmpty) {
      url = url.replace(queryParameters: queryParams);
    }

    final headers = {..._defaultHeaders};
    final response = await _client.get(url, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw RivetClientException(response.statusCode, response.body);
    }
  }

  /// Make a POST request
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('\\\$baseUrl\\\$path');
    final headers = {..._defaultHeaders, 'Content-Type': 'application/json'};

    final response = await _client.post(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw RivetClientException(response.statusCode, response.body);
    }
  }

  /// Make a PUT request
  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('\\\$baseUrl\\\$path');
    final headers = {..._defaultHeaders, 'Content-Type': 'application/json'};

    final response = await _client.put(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw RivetClientException(response.statusCode, response.body);
    }
  }

  /// Make a DELETE request
  Future<void> delete(String path) async {
    final url = Uri.parse('\\\$baseUrl\\\$path');
    final headers = {..._defaultHeaders};

    final response = await _client.delete(url, headers: headers);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RivetClientException(response.statusCode, response.body);
    }
  }

  /// Close the HTTP client
  void close() {
    _client.close();
  }
}

/// Exception thrown when an API request fails
class RivetClientException implements Exception {
  final int statusCode;
  final String body;

  RivetClientException(this.statusCode, this.body);

  @override
  String toString() => 'RivetClientException(\\\$statusCode): \\\$body';
}
''';

  await File(outputPath).writeAsString(clientCode);
  
  print('✅ Client generated: \$outputPath');
  print('');
  print('Usage in your Flutter app:');
  print("  final client = RivetClient('http://localhost:3000');");
  print("  final data = await client.get('/api/users');");
  print('');
  print('💡 Tip: Add http package to your Flutter app:');
  print('  flutter pub add http');
}

