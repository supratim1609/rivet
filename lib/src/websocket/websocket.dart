import 'dart:async';
import 'dart:io';
import 'dart:convert';

typedef WebSocketHandler = FutureOr<void> Function(WebSocketConnection);

class WebSocketConnection {
  final WebSocket socket;
  final String id;
  final Map<String, dynamic> data = {};
  final Set<String> _rooms = {};

  WebSocketConnection(this.socket, this.id);

  void send(dynamic message) {
    if (message is String) {
      socket.add(message);
    } else {
      socket.add(jsonEncode(message));
    }
  }

  void join(String room) {
    _rooms.add(room);
    WebSocketManager._instance.joinRoom(this, room);
  }

  void leave(String room) {
    _rooms.remove(room);
    WebSocketManager._instance.leaveRoom(this, room);
  }

  void broadcast(String room, dynamic message) {
    WebSocketManager._instance.broadcastToRoom(room, message, exclude: id);
  }

  void close([int? code, String? reason]) {
    socket.close(code, reason);
  }

  Stream get messages => socket;
}

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  factory WebSocketManager() => _instance;
  WebSocketManager._internal();

  final Map<String, WebSocketConnection> _connections = {};
  final Map<String, Set<WebSocketConnection>> _rooms = {};
  int _nextId = 0;

  Future<WebSocketConnection> handleUpgrade(
    HttpRequest request,
    WebSocketHandler handler,
  ) async {
    final socket = await WebSocketTransformer.upgrade(request);
    final id = 'ws_${_nextId++}';
    final connection = WebSocketConnection(socket, id);

    _connections[id] = connection;

    socket.done.then((_) {
      _connections.remove(id);
      // Remove from all rooms
      _rooms.forEach((room, connections) {
        connections.remove(connection);
      });
    });

    await handler(connection);

    return connection;
  }

  void joinRoom(WebSocketConnection connection, String room) {
    _rooms.putIfAbsent(room, () => {}).add(connection);
  }

  void leaveRoom(WebSocketConnection connection, String room) {
    _rooms[room]?.remove(connection);
    if (_rooms[room]?.isEmpty ?? false) {
      _rooms.remove(room);
    }
  }

  void broadcastToRoom(String room, dynamic message, {String? exclude}) {
    final connections = _rooms[room];
    if (connections == null) return;

    final payload = message is String ? message : jsonEncode(message);

    for (final conn in connections) {
      if (conn.id != exclude) {
        conn.send(payload);
      }
    }
  }

  void broadcast(dynamic message, {String? exclude}) {
    final payload = message is String ? message : jsonEncode(message);

    for (final conn in _connections.values) {
      if (conn.id != exclude) {
        conn.send(payload);
      }
    }
  }

  int get connectionCount => _connections.length;
  int roomSize(String room) => _rooms[room]?.length ?? 0;
}
