/// Metadata about a controller for client generation
class ControllerMetadata {
  final String name;
  final String basePath;
  final List<RouteMetadata> routes;
  final String? clientClassName;

  ControllerMetadata({
    required this.name,
    required this.basePath,
    required this.routes,
    this.clientClassName,
  });

  @override
  String toString() => 'ControllerMetadata($name, $basePath, ${routes.length} routes)';
}

/// Metadata about a single route
class RouteMetadata {
  final String method; // GET, POST, PUT, DELETE, PATCH
  final String path;
  final String functionName;
  final List<ParameterMetadata> parameters;
  final TypeMetadata? returnType;
  final bool requiresAuth;
  final List<String> requiredRoles;

  RouteMetadata({
    required this.method,
    required this.path,
    required this.functionName,
    this.parameters = const [],
    this.returnType,
    this.requiresAuth = false,
    this.requiredRoles = const [],
  });

  /// Extract path parameters from route path
  /// e.g., "/users/:id" -> ["id"]
  List<String> get pathParameters {
    final regex = RegExp(r':(\w+)');
    final matches = regex.allMatches(path);
    return matches.map((m) => m.group(1)!).toList();
  }

  /// Get clean path for URL building
  /// e.g., "/users/:id" -> "/users/\$id"
  String get interpolatedPath {
    var result = path;
    for (final param in pathParameters) {
      result = result.replaceAll(':$param', '\$$param');
    }
    return result;
  }

  @override
  String toString() => 'RouteMetadata($method $path -> $functionName)';
}

/// Metadata about a function parameter
class ParameterMetadata {
  final String name;
  final TypeMetadata type;
  final bool isRequired;
  final bool isPathParam;
  final bool isQueryParam;
  final bool isBodyParam;

  ParameterMetadata({
    required this.name,
    required this.type,
    this.isRequired = true,
    this.isPathParam = false,
    this.isQueryParam = false,
    this.isBodyParam = false,
  });

  @override
  String toString() => 'ParameterMetadata($name: ${type.name})';
}

/// Metadata about a Dart type
class TypeMetadata {
  final String name;
  final bool isBuiltin;
  final bool isList;
  final bool isMap;
  final bool isFuture;
  final bool isNullable;
  final TypeMetadata? genericType; // For List<T>, Future<T>
  final List<FieldMetadata> fields;

  TypeMetadata({
    required this.name,
    this.isBuiltin = false,
    this.isList = false,
    this.isMap = false,
    this.isFuture = false,
    this.isNullable = false,
    this.genericType,
    this.fields = const [],
  });

  /// Get the actual type name for code generation
  String get displayName {
    if (isFuture && genericType != null) {
      return genericType!.displayName;
    }
    if (isList && genericType != null) {
      return 'List<${genericType!.displayName}>';
    }
    return name;
  }

  /// Check if this is a simple type (String, int, bool, etc.)
  bool get isSimple => isBuiltin || name == 'String' || name == 'int' || 
                       name == 'bool' || name == 'double' || name == 'num';

  @override
  String toString() => 'TypeMetadata($displayName)';
}

/// Metadata about a class field
class FieldMetadata {
  final String name;
  final TypeMetadata type;
  final bool isRequired;

  FieldMetadata({
    required this.name,
    required this.type,
    this.isRequired = true,
  });

  @override
  String toString() => 'FieldMetadata($name: ${type.name})';
}
