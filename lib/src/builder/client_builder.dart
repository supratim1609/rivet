import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import '../annotations.dart';
import '../codegen/client_generator.dart';
import '../codegen/models.dart';

/// Generator for @RivetClient annotation
class ClientGeneratorBuilder extends GeneratorForAnnotation<RivetClient> {
  @override
  dynamic generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@RivetClient can only be applied to classes.',
        element: element,
      );
    }

    // Get controllers from annotation
    final controllersReader = annotation.read('controllers');
    final routes = <RouteDefinition>[];

    if (controllersReader.isList) {
      final controllers = controllersReader.listValue;
      for (final controllerObject in controllers) {
        final controllerType = controllerObject.toTypeValue();
        if (controllerType != null && controllerType.element is ClassElement) {
          final controllerClass = controllerType.element as ClassElement;
          _parseController(controllerClass, routes);
        }
      }
    }

    if (routes.isEmpty) {
      // If no controllers specified, maybe try to parse the annotated class itself?
      // Or warn?
      return '// No routes found. Did you add controllers to @RivetClient?';
    }

    // Generate client code
    final generator = ClientGenerator();
    // We pass empty types for now as we are not parsing models yet
    final code = generator.generate(
      routes: routes,
      types: [],
      className:
          '_${element.name ?? 'RivetClient'}', // Generate private implementation
      implements: element.name,
    );

    return code;
  }

  void _parseController(ClassElement controller, List<RouteDefinition> routes) {
    // Look for 'register' method first (legacy support)
    final registerMethod = controller.getMethod('register');
    if (registerMethod != null) {
      // We can't easily parse the body of register method without AST.
      // But we can look for @RivetController annotation and methods with @Route
    }

    // Look for @Route annotations on methods
    for (final method in controller.methods) {
      final routeAnnot = _getRouteAnnotation(method);
      if (routeAnnot != null) {
        // Extract parameters
        final pathParams = <String>[];
        final queryParams = <String, String>{};

        // Use children to find parameters if getter is missing
        // This is a fallback for analyzer API changes
        final parameters = method.children.where(
          (e) => e.kind == ElementKind.PARAMETER,
        );

        for (final p in parameters) {
          // p is Element, so we need to access name and type
          // Element has name (String?)
          // Element doesn't have type property directly (VariableElement does)
          // So we need to cast to VariableElement or similar if possible
          // But if we can't name the type, we can't cast.
          // However, we can use dynamic or check properties.

          final name = p.name ?? '';
          String typeName = 'dynamic';

          // Try to get type string
          // In analyzer, most elements that have a type implement TypeDefinedElement or similar
          // Or we can try to cast to dynamic and access type
          try {
            typeName = (p as dynamic).type.toString();
          } catch (e) {
            // Ignore
          }

          // Simple heuristic: if it's in the path string, it's a path param
          // Otherwise it's a query param (unless it's the request object)
          if (routeAnnot.path.contains(':$name')) {
            pathParams.add(name);
          } else if (typeName != 'RivetRequest') {
            queryParams[name] = typeName;
          }
        }

        routes.add(
          RouteDefinition(
            method: routeAnnot.method,
            path: routeAnnot.path,
            pathParams: pathParams,
            queryParams: queryParams,
            responseType: method.returnType.toString(),
            handlerName: method.name!, // Name is non-null for methods usually
          ),
        );
      }
    }
  }

  _RouteInfo? _getRouteAnnotation(MethodElement method) {
    // Check each annotation
    for (final annot in method.metadata) {
      final value = annot.computeConstantValue();
      if (value == null) continue;
      
      final type = value.type;
      if (type == null) continue;
      
      final typeName = type.element?.name;
      
      if (typeName == 'Get') {
        final path = value.getField('path')?.toStringValue() ?? '/';
        return _RouteInfo('GET', path);
      } else if (typeName == 'Post') {
        final path = value.getField('path')?.toStringValue() ?? '/';
        return _RouteInfo('POST', path);
      } else if (typeName == 'Put') {
        final path = value.getField('path')?.toStringValue() ?? '/';
        return _RouteInfo('PUT', path);
      } else if (typeName == 'Delete') {
        final path = value.getField('path')?.toStringValue() ?? '/';
        return _RouteInfo('DELETE', path);
      }
    }
    
    return null;
  }
}

class _RouteInfo {
  final String method;
  final String path;
  _RouteInfo(this.method, this.path);
}

Builder clientBuilder(BuilderOptions options) =>
    SharedPartBuilder([ClientGeneratorBuilder()], 'rivet_client');
