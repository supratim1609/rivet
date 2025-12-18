/// Advanced caching system with TTL and LRU eviction
library;

import 'dart:async';
import 'dart:collection';

/// Cache entry with expiration
class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;
  DateTime lastAccessed;

  _CacheEntry(this.value, Duration ttl)
      : expiresAt = DateTime.now().add(ttl),
        lastAccessed = DateTime.now();

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  void touch() {
    lastAccessed = DateTime.now();
  }
}

/// In-memory cache with TTL and LRU eviction
class Cache {
  final Map<String, _CacheEntry> _cache = {};
  final int maxSize;
  final Duration defaultTtl;
  Timer? _cleanupTimer;

  Cache({
    this.maxSize = 1000,
    this.defaultTtl = const Duration(minutes: 5),
    Duration cleanupInterval = const Duration(minutes: 1),
  }) {
    // Start cleanup timer
    _cleanupTimer = Timer.periodic(cleanupInterval, (_) => _cleanup());
  }

  /// Get value from cache
  Future<T?> get<T>(String key) async {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    entry.touch();
    return entry.value as T?;
  }

  /// Set value in cache
  Future<void> set<T>(
    String key,
    T value, {
    Duration? ttl,
  }) async {
    // Evict if at max size
    if (_cache.length >= maxSize) {
      _evictLRU();
    }

    _cache[key] = _CacheEntry(value, ttl ?? defaultTtl);
  }

  /// Delete value from cache
  Future<void> delete(String key) async {
    _cache.remove(key);
  }

  /// Clear all cache
  Future<void> clear() async {
    _cache.clear();
  }

  /// Check if key exists and is not expired
  Future<bool> has(String key) async {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  /// Get or set pattern
  Future<T> getOrSet<T>(
    String key,
    Future<T> Function() factory, {
    Duration? ttl,
  }) async {
    final cached = await get<T>(key);
    if (cached != null) return cached;

    final value = await factory();
    await set(key, value, ttl: ttl);
    return value;
  }

  /// Get cache statistics
  Map<String, dynamic> get stats {
    final now = DateTime.now();
    var expired = 0;
    var valid = 0;

    for (final entry in _cache.values) {
      if (entry.isExpired) {
        expired++;
      } else {
        valid++;
      }
    }

    return {
      'size': _cache.length,
      'maxSize': maxSize,
      'valid': valid,
      'expired': expired,
      'hitRate': 0.0, // TODO: Track hits/misses
    };
  }

  /// Cleanup expired entries
  void _cleanup() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  /// Evict least recently used entry
  void _evictLRU() {
    if (_cache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.lastAccessed.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value.lastAccessed;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }

  /// Dispose cache and cleanup timer
  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
  }
}

/// Global cache instance
final cache = Cache();
