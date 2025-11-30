import 'dart:async';

class CacheEntry<T> {
  final T value;
  final DateTime expiry;

  CacheEntry(this.value, this.expiry);

  bool get isExpired => DateTime.now().isAfter(expiry);
}

class Cache {
  final Map<String, CacheEntry> _cache = {};

  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.value as T?;
  }

  void set<T>(
    String key,
    T value, {
    Duration ttl = const Duration(minutes: 5),
  }) {
    final expiry = DateTime.now().add(ttl);
    _cache[key] = CacheEntry(value, expiry);
  }

  void delete(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }

  void cleanup() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  int get size => _cache.length;
}

// Global cache instance
final cache = Cache();

// Cache middleware
typedef CacheKeyGenerator =
    String Function(String method, String path, Map<String, String> query);

String defaultCacheKey(String method, String path, Map<String, String> query) {
  if (query.isEmpty) return '$method:$path';
  final queryStr = query.entries.map((e) => '${e.key}=${e.value}').join('&');
  return '$method:$path?$queryStr';
}

// Note: This is a simplified cache middleware
// For production, you'd want Redis or similar
class CacheManager {
  static final Cache _instance = Cache();

  static void startCleanup() {
    Timer.periodic(Duration(minutes: 1), (_) => _instance.cleanup());
  }

  static T? get<T>(String key) => _instance.get<T>(key);
  static void set<T>(
    String key,
    T value, {
    Duration ttl = const Duration(minutes: 5),
  }) {
    _instance.set(key, value, ttl: ttl);
  }

  static void delete(String key) => _instance.delete(key);
  static void clear() => _instance.clear();
}
