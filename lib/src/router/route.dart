import 'dart:async';

typedef Handler = FutureOr<dynamic> Function(dynamic request);

class Route {
  final String method;
  final String path;
  final Handler handler;

  Route(this.method, this.path, this.handler);
}
