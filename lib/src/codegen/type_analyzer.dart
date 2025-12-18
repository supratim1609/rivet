import 'dart:mirrors';
import 'metadata.dart';

/// Analyzes Dart types for client generation
class TypeAnalyzer {
  /// Analyze a Type and return metadata
  TypeMetadata analyzeType(Type type) {
    final mirror = reflectType(type);
    
    if (mirror is ClassMirror) {
      return _analyzeClassMirror(mirror);
    }
    
    return TypeMetadata(
      name: type.toString(),
      isBuiltin: _isBuiltinType(type),
    );
  }

  /// Analyze a ClassMirror
  TypeMetadata _analyzeClassMirror(ClassMirror mirror) {
    final name = MirrorSystem.getName(mirror.simpleName);
    
    // Check for generic types
    if (name == 'List') {
      final genericType = mirror.typeArguments.isNotEmpty
          ? _analyzeTypeMirror(mirror.typeArguments.first)
          : null;
      return TypeMetadata(
        name: 'List',
        isList: true,
        genericType: genericType,
      );
    }
    
    if (name == 'Future') {
      final genericType = mirror.typeArguments.isNotEmpty
          ? _analyzeTypeMirror(mirror.typeArguments.first)
          : null;
      return TypeMetadata(
        name: 'Future',
        isFuture: true,
        genericType: genericType,
      );
    }
    
    if (name == 'Map') {
      return TypeMetadata(
        name: 'Map',
        isMap: true,
        isBuiltin: true,
      );
    }
    
    // Extract fields for custom classes
    final fields = _extractFields(mirror);
    
    return TypeMetadata(
      name: name,
      isBuiltin: _isBuiltinType(mirror.reflectedType),
      fields: fields,
    );
  }

  /// Analyze a TypeMirror
  TypeMetadata _analyzeTypeMirror(TypeMirror mirror) {
    if (mirror is ClassMirror) {
      return _analyzeClassMirror(mirror);
    }
    
    return TypeMetadata(
      name: mirror.toString(),
      isBuiltin: true,
    );
  }

  /// Extract fields from a class
  List<FieldMetadata> _extractFields(ClassMirror mirror) {
    final fields = <FieldMetadata>[];
    
    mirror.declarations.forEach((symbol, declaration) {
      if (declaration is VariableMirror && !declaration.isStatic) {
        final fieldName = MirrorSystem.getName(symbol);
        final fieldType = _analyzeTypeMirror(declaration.type);
        
        // Assume all fields are required by default
        // In a real implementation, you'd check for nullable types
        fields.add(FieldMetadata(
          name: fieldName,
          type: fieldType,
          isRequired: true,
        ));
      }
    });
    
    return fields;
  }

  /// Check if a type is a builtin Dart type
  bool _isBuiltinType(Type type) {
    return type == String ||
        type == int ||
        type == double ||
        type == num ||
        type == bool ||
        type == dynamic ||
        type == Object;
  }

  /// Generate serialization code for a type
  String generateSerializer(TypeMetadata type, String varName) {
    if (type.isSimple) {
      return varName;
    }
    
    if (type.isList && type.genericType != null) {
      if (type.genericType!.isSimple) {
        return varName;
      }
      return '$varName.map((e) => e.toJson()).toList()';
    }
    
    if (type.isMap) {
      return varName;
    }
    
    return '$varName.toJson()';
  }

  /// Generate deserialization code for a type
  String generateDeserializer(TypeMetadata type, String jsonVar) {
    if (type.isSimple) {
      return '$jsonVar as ${type.displayName}';
    }
    
    if (type.isList && type.genericType != null) {
      if (type.genericType!.isSimple) {
        return '($jsonVar as List<dynamic>).cast<${type.genericType!.displayName}>()';
      }
      return '($jsonVar as List<dynamic>).map((e) => ${type.genericType!.name}.fromJson(e)).toList()';
    }
    
    if (type.isMap) {
      return '$jsonVar as Map<String, dynamic>';
    }
    
    return '${type.name}.fromJson($jsonVar)';
  }
}
