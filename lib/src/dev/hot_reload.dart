import 'dart:io';
import 'package:watcher/watcher.dart';

class HotReload {
  final String watchPath;
  final Function() onReload;
  DirectoryWatcher? _watcher;
  Process? _process;

  HotReload({required this.watchPath, required this.onReload});

  Future<void> start(String scriptPath) async {
    print('[HOT RELOAD] Watching $watchPath for changes...');

    // Start initial process
    await _startProcess(scriptPath);

    // Watch for file changes
    _watcher = DirectoryWatcher(watchPath);
    _watcher!.events.listen((event) {
      if (event.type == ChangeType.MODIFY || event.type == ChangeType.ADD) {
        if (event.path.endsWith('.dart')) {
          print('[HOT RELOAD] Detected change in ${event.path}');
          _reload(scriptPath);
        }
      }
    });
  }

  Future<void> _startProcess(String scriptPath) async {
    _process = await Process.start('dart', ['run', scriptPath]);

    _process!.stdout.listen((data) {
      stdout.add(data);
    });

    _process!.stderr.listen((data) {
      stderr.add(data);
    });
  }

  Future<void> _reload(String scriptPath) async {
    print('[HOT RELOAD] Restarting server...');

    // Kill old process
    _process?.kill();
    await Future.delayed(Duration(milliseconds: 500));

    // Start new process
    await _startProcess(scriptPath);

    onReload();
    print('[HOT RELOAD] Server restarted ✅');
  }

  void stop() {
    _process?.kill();
  }
}
