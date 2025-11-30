/// Annotations for Rivet code generation
library;

/// Annotation to generate a Rivet API client
///
/// Usage:
/// ```dart
/// @RivetClient(controllers: [UserController, ProductController])
/// class ApiClient {}
/// ```
class RivetClient {
  /// List of controller classes to include in the client
  final List<Type> controllers;

  const RivetClient({this.controllers = const []});
}

/// Annotation to mark a class as a Rivet controller
///
/// Usage:
/// ```dart
/// @RivetController(path: '/users')
/// class UserController { ... }
/// ```
class RivetController {
  /// Base path for the controller
  final String path;

  const RivetController({this.path = ''});
}

/// Annotation to mark a method as a route
class Route {
  final String method;
  final String path;

  const Route(this.method, this.path);
}

class Get extends Route {
  const Get(String path) : super('GET', path);
}

class Post extends Route {
  const Post(String path) : super('POST', path);
}

class Put extends Route {
  const Put(String path) : super('PUT', path);
}

class Delete extends Route {
  const Delete(String path) : super('DELETE', path);
}
