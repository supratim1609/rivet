import 'route.dart';
import 'tree.dart';

class Router {
  final Map<String, RouteTree> _trees = {
    'GET': RouteTree(),
    'POST': RouteTree(),
    'PUT': RouteTree(),
    'DELETE': RouteTree(),
    'PATCH': RouteTree(),
  };

  void addRoute(String method, String path, Handler handler) {
    final upper = method.toUpperCase();
    _trees.putIfAbsent(upper, () => RouteTree());
    _trees[upper]!.add(upper, path, handler);
  }

  void get(String path, Handler handler) => addRoute('GET', path, handler);
  void post(String path, Handler handler) => addRoute('POST', path, handler);
  void put(String path, Handler handler) => addRoute('PUT', path, handler);
  void delete(String path, Handler handler) =>
      addRoute('DELETE', path, handler);
  void patch(String path, Handler handler) => addRoute('PATCH', path, handler);

  MatchResult? match(String method, String path) {
    final tree = _trees[method.toUpperCase()];
    if (tree == null) return null;
    return tree.match(method, path);
  }
}
