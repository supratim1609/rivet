import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ServerSentEvent {
  final String? event;
  final String data;
  final String? id;
  final int? retry;

  ServerSentEvent({this.event, required this.data, this.id, this.retry});

  String format() {
    final buffer = StringBuffer();
    if (id != null) buffer.writeln('id: $id');
    if (event != null) buffer.writeln('event: $event');
    if (retry != null) buffer.writeln('retry: $retry');

    // Handle multi-line data
    for (final line in data.split('\n')) {
      buffer.writeln('data: $line');
    }
    buffer.writeln();

    return buffer.toString();
  }
}

class SSEStream {
  final StreamController<ServerSentEvent> _controller;
  final HttpResponse _response;
  bool _closed = false;

  SSEStream._(this._controller, this._response);

  static SSEStream create(HttpResponse response) {
    response.headers.contentType = ContentType(
      'text',
      'event-stream',
      charset: 'utf-8',
    );
    response.headers.set('Cache-Control', 'no-cache');
    response.headers.set('Connection', 'keep-alive');

    final controller = StreamController<ServerSentEvent>();
    final stream = SSEStream._(controller, response);

    controller.stream.listen(
      (event) {
        if (!stream._closed) {
          response.write(event.format());
        }
      },
      onDone: () => response.close(),
      onError: (error) => response.close(),
    );

    return stream;
  }

  void send(String data, {String? event, String? id}) {
    if (_closed) return;
    _controller.add(ServerSentEvent(data: data, event: event, id: id));
  }

  void sendJson(Map<String, dynamic> data, {String? event, String? id}) {
    send(jsonEncode(data), event: event, id: id);
  }

  void comment(String text) {
    if (_closed) return;
    _response.write(': $text\n\n');
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _controller.close();
  }
}

// Chunked streaming for large files
class ChunkedStream {
  final Stream<List<int>> source;
  final HttpResponse response;

  ChunkedStream(this.source, this.response);

  Future<void> pipe() async {
    await response.addStream(source);
    await response.close();
  }
}
