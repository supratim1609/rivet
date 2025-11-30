import 'dart:async';

import '../http/request.dart';
import '../http/response.dart';

typedef MiddlewareHandler =
    FutureOr<dynamic> Function(
      RivetRequest req,
      FutureOr<dynamic> Function() next,
    );

class Middleware {
  final List<MiddlewareHandler> _handlers = [];

  void use(MiddlewareHandler fn) {
    _handlers.add(fn);
  }

  bool get isEmpty => _handlers.isEmpty;

  /// Run middleware chain + final route handler
  Future<RivetResponse> run(
    RivetRequest req,
    FutureOr<dynamic> Function() finalHandler,
  ) async {
    int index = -1;

    // Recursive runner
    Future<dynamic> runner() async {
      index++;
      if (index < _handlers.length) {
        return await _handlers[index](req, runner);
      } else {
        return await finalHandler();
      }
    }

    try {
      final res = await runner();

      // Convert result to RivetResponse
      if (res is RivetResponse) {
        return res;
      } else if (res is String) {
        return RivetResponse.text(res);
      } else {
        return RivetResponse.json(res ?? {});
      }
    } catch (e) {
      // Re-throw to let error handler middleware catch it
      rethrow;
    }
  }
}
