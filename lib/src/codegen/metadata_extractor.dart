import 'dart:mirrors';
import 'metadata.dart';
import 'type_analyzer.dart';
import '../annotations.dart';

/// Scans controllers and extracts metadata for client generation
class ControllerMetadataExtractor {
  final TypeAnalyzer _typeAnalyzer = TypeAnalyzer();

  /// Extract metadata from a controller instance
  ControllerMetadata extractFromController(Object controller) {
    final mirror = reflect(controller);
    final classMirror = mirror.type;
    
    // Get controller annotation
    final controllerAnnotation = _getControllerAnnotation(classMirror);
    if (controllerAnnotation == null) {
      throw Exception('Controller must have @RivetController annotation');
    }
    
    final basePath = controllerAnnotation.path;
    final className = MirrorSystem.getName(classMirror.simpleName);
    
    // Extract routes from methods
    final routes = <RouteMetadata>[];
    
    classMirror.declarations.forEach((symbol, declaration) {
      if (declaration is MethodMirror && !declaration.isStatic) {
        final route = _extractRoute(declaration, basePath);
        if (route != null) {
          routes.add(route);
        }
      }
    });
    
    return ControllerMetadata(
      name: className,
      basePath: basePath,
      routes: routes,
    );
  }

  /// Get @RivetController annotation
  RivetController? _getControllerAnnotation(ClassMirror mirror) {
    for (final metadata in mirror.metadata) {
      final instance = metadata.reflectee;
      if (instance is RivetController) {
        return instance;
      }
    }
    return null;
  }

  /// Extract route metadata from a method
  RouteMetadata? _extractRoute(MethodMirror method, String basePath) {
    String? httpMethod;
    String? path;
    bool requiresAuth = false;
    List<String> requiredRoles = [];
    
    // Check for route annotations
    for (final metadata in method.metadata) {
      final instance = metadata.reflectee;
      
      if (instance is Get) {
        httpMethod = 'GET';
        path = instance.path;
      } else if (instance is Post) {
        httpMethod = 'POST';
        path = instance.path;
      } else if (instance is Put) {
        httpMethod = 'PUT';
        path = instance.path;
      } else if (instance is Delete) {
        httpMethod = 'DELETE';
        path = instance.path;
      } else if (instance is Patch) {
        httpMethod = 'PATCH';
        path = instance.path;
      } else if (instance is Auth) {
        requiresAuth = true;
        requiredRoles = instance.roles;
      }
    }
    
    if (httpMethod == null || path == null) {
      return null;
    }
    
    final functionName = MirrorSystem.getName(method.simpleName);
    final fullPath = basePath + path;
    
    // Analyze return type
    TypeMetadata? returnType;
    if (method.returnType is ClassMirror) {
      returnType = _typeAnalyzer.analyzeType(
        (method.returnType as ClassMirror).reflectedType,
      );
    }
    
    // Extract parameters
    final parameters = _extractParameters(method, fullPath);
    
    return RouteMetadata(
      method: httpMethod,
      path: fullPath,
      functionName: functionName,
      parameters: parameters,
      returnType: returnType,
      requiresAuth: requiresAuth,
      requiredRoles: requiredRoles,
    );
  }

  /// Extract parameters from method
  List<ParameterMetadata> _extractParameters(MethodMirror method, String path) {
    final parameters = <ParameterMetadata>[];
    final pathParams = _extractPathParams(path);
    
    for (final param in method.parameters) {
      final paramName = MirrorSystem.getName(param.simpleName);
      
      // Skip RivetRequest parameter
      if (param.type.simpleName == #RivetRequest) {
        continue;
      }
      
      final paramType = _typeAnalyzer.analyzeType(
        (param.type as ClassMirror).reflectedType,
      );
      
      final isPathParam = pathParams.contains(paramName);
      
      parameters.add(ParameterMetadata(
        name: paramName,
        type: paramType,
        isRequired: !param.isOptional,
        isPathParam: isPathParam,
        isQueryParam: !isPathParam,
      ));
    }
    
    return parameters;
  }

  /// Extract path parameters from route path
  List<String> _extractPathParams(String path) {
    final regex = RegExp(r':(\w+)');
    final matches = regex.allMatches(path);
    return matches.map((m) => m.group(1)!).toList();
  }
}
