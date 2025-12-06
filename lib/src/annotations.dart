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

class Patch extends Route {
  const Patch(String path) : super('PATCH', path);
}

/// Middleware Annotations

/// Annotation to apply authentication middleware
class Auth {
  final List<String> roles;
  const Auth({this.roles = const []});
}

/// Annotation to apply custom middleware
class UseMiddleware {
  final List<dynamic> middleware;
  const UseMiddleware(this.middleware);
}

/// Validation Annotations

/// Annotation to apply validators to a route
class Validate {
  final List<dynamic> validators;
  const Validate(this.validators);
}

/// Validator: Field is required
class Required {
  final String field;
  final String? message;
  const Required(this.field, {this.message});
}

/// Validator: Field must be a valid email
class Email {
  final String field;
  final String? message;
  const Email(this.field, {this.message});
}

/// Validator: Field must have minimum length
class MinLength {
  final String field;
  final int length;
  final String? message;
  const MinLength(this.field, this.length, {this.message});
}

/// Validator: Field must have maximum length
class MaxLength {
  final String field;
  final int length;
  final String? message;
  const MaxLength(this.field, this.length, {this.message});
}

/// Validator: Field must be at least this value
class Min {
  final String field;
  final num value;
  final String? message;
  const Min(this.field, this.value, {this.message});
}

/// Validator: Field must be at most this value
class Max {
  final String field;
  final num value;
  final String? message;
  const Max(this.field, this.value, {this.message});
}
