import 'dart:io';
import 'dart:async';

/// Watches files for changes and triggers callbacks
class FileWatcher {
  final String directory;
  final List<String> extensions;
  final List<String> ignorePatterns;
  final Function(String path) onChanged;

  StreamSubscription? _subscription;
  Timer? _debounceTimer;
  final Duration _debounceDuration = Duration(milliseconds: 500);
  final Set<String> _pendingChanges = {};

  FileWatcher({
    required this.directory,
    this.extensions = const ['.dart'],
    this.ignorePatterns = const [
      '.dart_tool/',
      'build/',
      '.git/',
      '.g.dart',
      'test/',
      '.idea/',
      '.vscode/',
    ],
    required this.onChanged,
  });

  /// Start watching for file changes
  Future<void> start() async {
    final dir = Directory(directory);
    if (!await dir.exists()) {
      throw Exception('Directory does not exist: $directory');
    }

    _subscription = dir.watch(recursive: true).listen(
      (event) {
        if (_shouldWatch(event.path)) {
          _handleChange(event.path);
        }
      },
      onError: (e) {
        print('Error watching files: $e');
      },
      cancelOnError: false, // Don't stop watching on error
    );
  }

  /// Stop watching for file changes
  Future<void> stop() async {
    await _subscription?.cancel();
    _debounceTimer?.cancel();
  }

  /// Check if a file should be watched
  bool _shouldWatch(String path) {
    // Check if file has watched extension
    final hasValidExtension = extensions.any((ext) => path.endsWith(ext));
    if (!hasValidExtension) return false;

    // Check if path matches ignore patterns
    final shouldIgnore = ignorePatterns.any((pattern) => path.contains(pattern));
    if (shouldIgnore) return false;

    return true;
  }

  /// Handle file change with debouncing
  void _handleChange(String path) {
    _pendingChanges.add(path);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (_pendingChanges.isNotEmpty) {
        // Trigger callback with first changed file
        // (we restart anyway, so we don't need all files)
        final changedFile = _pendingChanges.first;
        _pendingChanges.clear();
        onChanged(changedFile);
      }
    });
  }
}
