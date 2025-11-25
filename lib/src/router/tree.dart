import 'route.dart';

class MatchResult {
  final Handler handler;
  final Map<String, String> params;

  MatchResult(this.handler, this.params);
}

class RouteNode {
  final Map<String, RouteNode> children = {};
  Handler? handler;
  String? paramName;

  RouteNode();
}

class RouteTree {
  final RouteNode root = RouteNode();

  void add(String method, String path, Handler handler) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    RouteNode current = root;

    for (final part in parts) {
      bool isParam = part.startsWith(':');
      String key = isParam ? ':' : part;

      current.children.putIfAbsent(key, () => RouteNode());
      current = current.children[key]!;

      if (isParam) current.paramName = part.substring(1);
    }

    current.handler = handler;
  }

  MatchResult? match(String method, String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    RouteNode current = root;
    final params = <String, String>{};

    for (final part in parts) {
      if (current.children.containsKey(part)) {
        current = current.children[part]!;
      } else if (current.children.containsKey(':')) {
        current = current.children[':']!;
        if (current.paramName != null) {
          params[current.paramName!] = part;
        }
      } else {
        return null;
      }
    }

    if (current.handler != null) {
      return MatchResult(current.handler!, params);
    }
    return null;
  }
}
