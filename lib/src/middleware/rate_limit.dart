import 'dart:async';
import 'dart:io';
import '../http/request.dart';
import '../http/response.dart';
import 'middleware.dart';

class RateLimiter {
  final int maxRequests;
  final Duration window;
  final Map<String, _TokenBucket> _buckets = {};

  RateLimiter({
    required this.maxRequests,
    required this.window,
  });

  bool _allowRequest(String key) {
    final bucket = _buckets.putIfAbsent(
      key,
      () => _TokenBucket(maxRequests, window),
    );
    return bucket.consume();
  }

  void _cleanup() {
    final now = DateTime.now();
    _buckets.removeWhere((key, bucket) {
      return now.difference(bucket._lastRefill) > window * 2;
    });
  }
}

class _TokenBucket {
  final int capacity;
  final Duration refillDuration;
  int _tokens;
  DateTime _lastRefill;

  _TokenBucket(this.capacity, this.refillDuration)
      : _tokens = capacity,
        _lastRefill = DateTime.now();

  bool consume() {
    _refill();
    if (_tokens > 0) {
      _tokens--;
      return true;
    }
    return false;
  }

  void _refill() {
    final now = DateTime.now();
    final elapsed = now.difference(_lastRefill);
    
    if (elapsed >= refillDuration) {
      _tokens = capacity;
      _lastRefill = now;
    }
  }
}

MiddlewareHandler rateLimit({
  int maxRequests = 100,
  Duration window = const Duration(minutes: 1),
  String Function(RivetRequest)? keyGenerator,
}) {
  final limiter = RateLimiter(maxRequests: maxRequests, window: window);
  
  // Cleanup old buckets periodically
  Timer.periodic(window, (_) => limiter._cleanup());

  return (RivetRequest req, FutureOr<dynamic> Function() next) async {
    final key = keyGenerator?.call(req) ?? 
                req.raw.connectionInfo?.remoteAddress.address ?? 
                'unknown';

    if (!limiter._allowRequest(key)) {
      return RivetResponse.json(
        {'error': 'Too many requests. Please try again later.'},
        statusCode: 429,
      );
    }

    return next();
  };
}
