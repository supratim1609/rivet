/// Simple type inference from JSON-like structures
library;

import 'models.dart';

/// Infers Dart types from JSON structures
class TypeInference {
  final Map<String, TypeDefinition> _knownTypes = {};

  /// Infer type from a Map (simulating JSON response)
  TypeDefinition inferFromMap(String typeName, Map<String, dynamic> json) {
    final fields = <String, FieldDefinition>{};

    json.forEach((key, value) {
      fields[key] = _inferField(key, value);
    });

    final typeDef = TypeDefinition(name: typeName, fields: fields);
    _knownTypes[typeName] = typeDef;
    return typeDef;
  }

  FieldDefinition _inferField(String name, dynamic value) {
    if (value == null) {
      return FieldDefinition(name: name, dartType: 'dynamic', isNullable: true);
    }

    if (value is String) {
      return FieldDefinition(name: name, dartType: 'String');
    }

    if (value is int) {
      return FieldDefinition(name: name, dartType: 'int');
    }

    if (value is double) {
      return FieldDefinition(name: name, dartType: 'double');
    }

    if (value is bool) {
      return FieldDefinition(name: name, dartType: 'bool');
    }

    if (value is List) {
      if (value.isEmpty) {
        return FieldDefinition(name: name, dartType: 'dynamic', isList: true);
      }

      final firstItem = value.first;
      if (firstItem is Map<String, dynamic>) {
        // Nested object - create a type for it
        final nestedTypeName = _capitalize(name);
        final nestedType = inferFromMap(nestedTypeName, firstItem);
        return FieldDefinition(
          name: name,
          dartType: nestedType.name,
          isList: true,
        );
      } else {
        // List of primitives
        final itemField = _inferField('item', firstItem);
        return FieldDefinition(
          name: name,
          dartType: itemField.dartType,
          isList: true,
        );
      }
    }

    if (value is Map<String, dynamic>) {
      // Nested object
      final nestedTypeName = _capitalize(name);
      final nestedType = inferFromMap(nestedTypeName, value);
      return FieldDefinition(name: name, dartType: nestedType.name);
    }

    // Fallback
    return FieldDefinition(name: name, dartType: 'dynamic');
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  /// Get all discovered types
  Map<String, TypeDefinition> get knownTypes => Map.unmodifiable(_knownTypes);

  /// Clear known types
  void clear() => _knownTypes.clear();
}
