import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import '../router/router.dart';
import '../router/route.dart';
import '../router/group.dart';
import '../websocket/websocket.dart';
import '../plugins/plugin.dart';
import '../middleware/middleware.dart';
import '../middleware/error_handler.dart';
import '../middleware/json_parser.dart';
import 'request.dart';
import 'response.dart';
import 'isolate_manager.dart';

class RivetServer {
  final Router _router = Router();
  final Middleware _middleware = Middleware();
  final WebSocketManager _wsManager = WebSocketManager();
  final PluginManager _pluginManager = PluginManager();
  HttpServer? _server;

  RivetServer() {
    // Default middleware for production-ready setup
    use(errorHandler);
    use(jsonParser);
  }

  // Plugin support
  void plugin(RivetPlugin p) {
    _pluginManager.register(p);
    // Add plugin middleware
    for (final mw in p.middleware) {
      use(mw);
    }
  }

  // Public API
  void use(MiddlewareHandler fn) => _middleware.use(fn);
  void get(String path, Handler handler) => _router.get(path, handler);
  void post(String path, Handler handler) => _router.post(path, handler);
  void on(String method, String path, Handler handler) =>
      _router.addRoute(method, path, handler);

  // Create route group
  RouteGroup group(String prefix) => RouteGroup(prefix, _router);

  // WebSocket support
  void ws(String path, WebSocketHandler handler) {
    _router.get(path, (req) async {
      if (req.headers.value('upgrade')?.toLowerCase() == 'websocket') {
        await _wsManager.handleUpgrade(req.raw, handler);
        return RivetResponse(null); // Connection upgraded
      }
      return RivetResponse.badRequest('WebSocket upgrade required');
    });
  }

  // Start listening
  Future<void> listen({
    int port = 8080,
    String address = '0.0.0.0',
    void Function()? onStarted,
  }) async {
    _server =
        await HttpServer.bind(InternetAddress(address), port, shared: true);
    onStarted?.call();
    print('RIVET 🚀 running on http://$address:$port');

    await for (final raw in _server!) {
      _handle(raw);
    }
  }

  // Cluster mode helper
  static Future<void> cluster({
    required void Function(RivetServer) builder,
    int workers = 1,
    int port = 8080,
    String address = '0.0.0.0',
  }) async {
    print('RIVET 🚀 Starting in CLUSTER mode with $workers workers...');
    final manager = IsolateManager();
    
    await manager.spawn(
      _clusterWorker,
      count: workers,
      args: [builder, address, port],
    );
    
    print('RIVET 🚀 Master process running. Workers spawned.');
    await ProcessSignal.sigint.watch().first;
    manager.killAll();
    exit(0);
  }

  // Worker entry point for cluster mode
  static void _clusterWorker(List<dynamic> args) {
    final id = args[0] as int;
    final sendPort = args[1] as SendPort;
    final builder = args[2] as void Function(RivetServer);
    final address = args[3] as String;
    final port = args[4] as int;

    final app = RivetServer();
    builder(app); // Configure app
    
    // Start listening (shared: true is default in listen)
    app.listen(port: port, address: address, onStarted: () {
      sendPort.send('Worker $id ready');
    });
  }

  // Graceful shutdown
  Future<void> close({bool force = false}) async {
    if (_server != null) {
      await _server!.close(force: force);
      _server = null;
      print('RIVET 🛑 server closed');
    }
  }

  // Handle each request
  void _handle(HttpRequest raw) async {
    final req = RivetRequest.from(raw);

    // Run global middleware first
    final response = await _middleware.run(req, () async {
      // Then try to match a route
      final route = _router.match(req.method, req.path);

      if (route != null) {
        req.params.addAll(route.params);

        // Execute the handler
        final result = await route.handler(req);
        return result;
      } else {
        return RivetResponse.text('Not Found', statusCode: 404);
      }
    });
    
    // Send the response
    await _sendResponse(raw.response, response);
  }

  // Send RivetResponse
  Future<void> _sendResponse(HttpResponse raw, RivetResponse res) async {
    raw.statusCode = res.statusCode;
    
    // Set all headers from response
    res.headers.forEach((key, value) {
      raw.headers.set(key, value);
    });

    final body = res.body;
    if (body is Stream<List<int>>) {
      await raw.addStream(body);
    } else if (body is List<int>) {
      raw.add(body);
    } else if (body is String) {
      raw.write(body);
    }

    await raw.close();
  }
}
