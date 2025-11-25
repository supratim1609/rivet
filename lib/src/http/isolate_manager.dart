import 'dart:async';
import 'dart:isolate';

/// Manages a cluster of worker isolates for multi-core performance.
class IsolateManager {
  final List<Isolate> _isolates = [];
  final ReceivePort _receivePort = ReceivePort();
  
  /// Spawns [count] worker isolates.
  /// 
  /// [entryPoint] is the main function to run in each isolate.
  /// [args] are arguments to pass to the entry point.
  Future<void> spawn(
    void Function(List<dynamic>) entryPoint, {
    int count = 1,
    List<dynamic>? args,
  }) async {
    print('RIVET 🚀 Spawning $count worker isolates...');
    
    for (var i = 0; i < count; i++) {
      final isolate = await Isolate.spawn(
        entryPoint,
        [i + 1, _receivePort.sendPort, ...(args ?? [])],
        debugName: 'RivetWorker-$i',
      );
      _isolates.add(isolate);
    }
    
    // Listen for messages from workers (optional, for metrics/logging)
    _receivePort.listen((message) {
      if (message is String) {
        print('[Worker] $message');
      }
    });
  }

  /// Kills all worker isolates.
  void killAll() {
    for (final isolate in _isolates) {
      isolate.kill(priority: Isolate.immediate);
    }
    _isolates.clear();
    _receivePort.close();
    print('RIVET 🛑 All workers terminated.');
  }
}
