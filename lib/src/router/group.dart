import 'router.dart';
import 'route.dart';

class RouteGroup {
  final String prefix;
  final Router _router;

  RouteGroup(this.prefix, this._router);

  void get(String path, Handler handler) {
    _router.get('$prefix$path', handler);
  }

  void post(String path, Handler handler) {
    _router.post('$prefix$path', handler);
  }

  void put(String path, Handler handler) {
    _router.addRoute('PUT', '$prefix$path', handler);
  }

  void delete(String path, Handler handler) {
    _router.addRoute('DELETE', '$prefix$path', handler);
  }
}
