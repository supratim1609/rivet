import 'dart:async';
import 'dart:io';
import '../http/request.dart';
import '../http/response.dart';
import 'middleware.dart';

class Session {
  final String id;
  final Map<String, dynamic> data = {};
  DateTime lastAccessed = DateTime.now();

  Session(this.id);

  void touch() {
    lastAccessed = DateTime.now();
  }
}

class SessionStore {
  final Map<String, Session> _sessions = {};
  final Duration maxAge;

  SessionStore({this.maxAge = const Duration(hours: 24)});

  Session? get(String id) {
    final session = _sessions[id];
    if (session != null) {
      final age = DateTime.now().difference(session.lastAccessed);
      if (age > maxAge) {
        _sessions.remove(id);
        return null;
      }
      session.touch();
    }
    return session;
  }

  Session create(String id) {
    final session = Session(id);
    _sessions[id] = session;
    return session;
  }

  void destroy(String id) {
    _sessions.remove(id);
  }

  void cleanup() {
    final now = DateTime.now();
    _sessions.removeWhere((id, session) {
      return now.difference(session.lastAccessed) > maxAge;
    });
  }
}

String _generateSessionId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = (timestamp * 1000).toString();
  return 'sess_$random';
}

MiddlewareHandler session({
  String cookieName = 'rivet_session',
  Duration maxAge = const Duration(hours: 24),
  bool httpOnly = true,
  bool secure = false,
}) {
  final store = SessionStore(maxAge: maxAge);
  
  // Cleanup old sessions periodically
  Timer.periodic(Duration(minutes: 15), (_) => store.cleanup());

  return (RivetRequest req, FutureOr<dynamic> Function() next) async {
    // Get session ID from cookie
    final cookies = req.headers.value(HttpHeaders.cookieHeader);
    String? sessionId;
    
    if (cookies != null) {
      final cookieList = cookies.split(';');
      for (final cookie in cookieList) {
        final parts = cookie.trim().split('=');
        if (parts.length == 2 && parts[0] == cookieName) {
          sessionId = parts[1];
          break;
        }
      }
    }

    // Get or create session
    Session sess;
    if (sessionId != null) {
      sess = store.get(sessionId) ?? store.create(_generateSessionId());
    } else {
      sessionId = _generateSessionId();
      sess = store.create(sessionId);
    }

    // Store session in request params
    req.params['__session_id'] = sess.id;
    req.params['__session_data'] = sess.data.toString();

    final result = await next();

    // Set cookie in response
    if (result is RivetResponse) {
      final cookieValue = '$cookieName=$sessionId; Max-Age=${maxAge.inSeconds}; Path=/'
          '${httpOnly ? '; HttpOnly' : ''}'
          '${secure ? '; Secure' : ''}';
      result.headers['Set-Cookie'] = cookieValue;
    }

    return result;
  };
}
