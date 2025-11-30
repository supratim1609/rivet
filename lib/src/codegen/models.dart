/// Data models for code generation
library;

/// Represents a single API route definition
class RouteDefinition {
  final String method; // GET, POST, PUT, DELETE, etc.
  final String path; // /user/:id
  final List<String> pathParams; // [id]
  final Map<String, String> queryParams; // {page: String, limit: String}
  final String? requestBodyType; // LoginRequest (for POST/PUT)
  final String responseType; // User, List<Post>, etc.
  final String handlerName; // For documentation

  RouteDefinition({
    required this.method,
    required this.path,
    required this.pathParams,
    this.queryParams = const {},
    this.requestBodyType,
    required this.responseType,
    this.handlerName = '',
  });

  /// Generate method name for the client
  /// Example: GET /user/:id -> getUser
  String get methodName {
    final cleanPath = path
        .replaceAll(RegExp(r':[^/]+'), '') // Remove :id, :name, etc.
        .replaceAll('/', '_')
        .replaceAll(RegExp(r'^_|_$'), ''); // Remove leading/trailing _

    final methodPrefix = method.toLowerCase();
    final pathPart = cleanPath.isEmpty ? '' : _capitalize(cleanPath);

    return '$methodPrefix$pathPart';
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  String toString() => 'RouteDefinition($method $path -> $responseType)';
}

/// Represents a Dart type/model definition
class TypeDefinition {
  final String name; // User, Post, LoginRequest
  final Map<String, FieldDefinition> fields; // {id: FieldDefinition(...)}
  final bool isList; // true if this is List<T>

  TypeDefinition({
    required this.name,
    required this.fields,
    this.isList = false,
  });

  @override
  String toString() => 'TypeDefinition($name with ${fields.length} fields)';
}

/// Represents a single field in a type
class FieldDefinition {
  final String name;
  final String dartType; // String, int, bool, User, List<Post>
  final bool isNullable;
  final bool isList;

  FieldDefinition({
    required this.name,
    required this.dartType,
    this.isNullable = false,
    this.isList = false,
  });

  String get fullType {
    var type = dartType;
    if (isList) type = 'List<$type>';
    if (isNullable) type = '$type?';
    return type;
  }

  @override
  String toString() => 'FieldDefinition($name: $fullType)';
}

/// Exception thrown during code generation
class CodeGenException implements Exception {
  final String message;
  final String? details;

  CodeGenException(this.message, [this.details]);

  @override
  String toString() {
    if (details != null) {
      return 'CodeGenException: $message\nDetails: $details';
    }
    return 'CodeGenException: $message';
  }
}
