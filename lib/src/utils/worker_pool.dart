import 'dart:async';
import 'dart:io';

class WorkerPool {
  final int workerCount;
  final List<HttpServer> _servers = [];
  final int _currentWorker = 0;

  WorkerPool({int? workerCount})
    : workerCount = workerCount ?? Platform.numberOfProcessors;

  Future<void> start(
    int port,
    Future<void> Function(HttpRequest) handler,
  ) async {
    print('[WORKER POOL] Starting $workerCount workers...');

    for (var i = 0; i < workerCount; i++) {
      final server = await HttpServer.bind(
        InternetAddress.anyIPv4,
        port,
        shared: true,
      );

      _servers.add(server);

      server.listen((request) async {
        await handler(request);
      });

      print('[WORKER POOL] Worker $i listening on port $port');
    }

    print('[WORKER POOL] All workers started ✅');
  }

  Future<void> close() async {
    for (final server in _servers) {
      await server.close();
    }
    _servers.clear();
  }
}
