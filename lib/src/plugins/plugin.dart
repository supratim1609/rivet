import 'dart:async';
import '../http/request.dart';
import '../middleware/middleware.dart';

// Plugin interface
abstract class RivetPlugin {
  String get name;
  String get version;

  Future<void> onInit();
  Future<void> onShutdown();

  List<MiddlewareHandler> get middleware => [];
  Map<String, dynamic> get config => {};
}

// Plugin manager
class PluginManager {
  final List<RivetPlugin> _plugins = [];
  bool _initialized = false;

  void register(RivetPlugin plugin) {
    if (_initialized) {
      throw Exception('Cannot register plugins after initialization');
    }
    _plugins.add(plugin);
  }

  Future<void> initialize() async {
    if (_initialized) return;

    for (final plugin in _plugins) {
      await plugin.onInit();
      print('[PLUGIN] Loaded: ${plugin.name} v${plugin.version}');
    }

    _initialized = true;
  }

  Future<void> shutdown() async {
    for (final plugin in _plugins) {
      await plugin.onShutdown();
    }
  }

  List<MiddlewareHandler> getAllMiddleware() {
    return _plugins.expand((p) => p.middleware).toList();
  }

  RivetPlugin? getPlugin(String name) {
    try {
      return _plugins.firstWhere((p) => p.name == name);
    } catch (e) {
      return null;
    }
  }

  List<RivetPlugin> get plugins => List.unmodifiable(_plugins);
}

// Example plugin implementation
class LoggerPlugin extends RivetPlugin {
  @override
  String get name => 'logger';

  @override
  String get version => '1.0.0';

  @override
  Future<void> onInit() async {
    print('[LOGGER PLUGIN] Initialized');
  }

  @override
  Future<void> onShutdown() async {
    print('[LOGGER PLUGIN] Shutdown');
  }

  @override
  List<MiddlewareHandler> get middleware => [
    (RivetRequest req, FutureOr<dynamic> Function() next) async {
      print('[${DateTime.now()}] ${req.method} ${req.path}');
      return next();
    },
  ];
}
