import 'dart:io';
import 'dart:async';
import 'file_watcher.dart';

/// Manages hot reload functionality for the Rivet server
class HotReloadManager {
  final String watchDirectory;
  final List<String> watchExtensions;
  final Duration debounceDelay;
  final Function()? onReload;

  FileWatcher? _watcher;
  bool _isRestarting = false;

  HotReloadManager({
    required this.watchDirectory,
    this.watchExtensions = const ['.dart'],
    this.debounceDelay = const Duration(milliseconds: 500),
    this.onReload,
  });

  /// Start hot reload watching
  Future<void> start() async {
    _log('Hot reload enabled - watching for changes...', emoji: '🔥');

    _watcher = FileWatcher(
      directory: watchDirectory,
      extensions: watchExtensions,
      onChanged: _onFileChanged,
    );

    await _watcher!.start();
  }

  /// Stop hot reload watching
  Future<void> stop() async {
    await _watcher?.stop();
  }

  /// Handle file change event
  void _onFileChanged(String path) {
    if (_isRestarting) {
      return; // Ignore changes during restart
    }

    _isRestarting = true;

    final relativePath = path.replaceFirst(Directory.current.path, '.');
    _log('File changed: $relativePath', emoji: '📝');

    _restartServer();
  }

  /// Restart the server process
  Future<void> _restartServer() async {
    _log('Restarting server...', emoji: '🔄');

    final stopwatch = Stopwatch()..start();

    // Call user-provided reload callback (wait for graceful shutdown)
    if (onReload != null) {
      if (onReload is Future Function()) {
        await onReload!();
      } else {
        onReload!();
      }
    }

    // Exit current process - the process manager (like nodemon or custom script)
    // will restart it, OR we can use dart run with --enable-vm-service
    // For now, we'll use a simple approach: exit and let external tool restart

    // In production, you'd use a process manager or VM service
    // For development, we'll just exit and rely on external restart
    _log('Server will restart automatically...', emoji: '⏳');

    stopwatch.stop();
    _log('Restart initiated in ${stopwatch.elapsedMilliseconds}ms', emoji: '✅');

    // Exit with code 0 to signal clean restart
    exit(0);
  }

  /// Log message with timestamp and emoji
  void _log(String message, {String emoji = '🔥'}) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    print('$emoji [$timestamp] $message');
  }
}
