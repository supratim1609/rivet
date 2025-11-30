import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:rivet/src/http/request.dart';

// Stub HttpHeaders
class StubHttpHeaders implements HttpHeaders {
  final Map<String, String> _headers = {};
  ContentType? _contentType;

  @override
  ContentType? get contentType => _contentType;

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    if (name == HttpHeaders.contentTypeHeader) {
      _contentType = value as ContentType;
    }
    _headers[name] = value.toString();
  }

  @override
  String? value(String name) => _headers[name];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Stub HttpRequest
class StubHttpRequest extends Stream<Uint8List> implements HttpRequest {
  final Stream<Uint8List> _bodyStream;

  @override
  final Uri uri;

  @override
  final String method = 'POST';

  @override
  final HttpHeaders headers = StubHttpHeaders();

  StubHttpRequest(this.uri, List<int> bodyBytes)
    : _bodyStream = Stream.value(Uint8List.fromList(bodyBytes));

  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _bodyStream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  // Cast is needed for transform
  @override
  Stream<S> cast<S>() => _bodyStream.cast<S>();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('RivetRequest Form Data', () {
    test('parses simple form fields', () async {
      final boundary = 'boundary123';
      final body =
          '--$boundary\r\n'
          'Content-Disposition: form-data; name="username"\r\n\r\n'
          'antigravity\r\n'
          '--$boundary--\r\n';

      final req = RivetRequest.from(
        StubHttpRequest(
          Uri.parse('http://localhost/upload'),
          utf8.encode(body),
        ),
      );

      req.headers.set(
        HttpHeaders.contentTypeHeader,
        ContentType(
          'multipart',
          'form-data',
          parameters: {'boundary': boundary},
        ),
      );

      await req.parseBody();

      expect(req.formFields['username'], equals('antigravity'));
      expect(req.files, isEmpty);
    });

    test('parses file upload', () async {
      final boundary = 'boundary123';
      final fileContent = 'Hello World';
      final body =
          '--$boundary\r\n'
          'Content-Disposition: form-data; name="doc"; filename="test.txt"\r\n'
          'Content-Type: text/plain\r\n\r\n'
          '$fileContent\r\n'
          '--$boundary--\r\n';

      final req = RivetRequest.from(
        StubHttpRequest(
          Uri.parse('http://localhost/upload'),
          utf8.encode(body),
        ),
      );

      req.headers.set(
        HttpHeaders.contentTypeHeader,
        ContentType(
          'multipart',
          'form-data',
          parameters: {'boundary': boundary},
        ),
      );

      await req.parseBody();

      expect(req.files, hasLength(1));
      final file = req.files.first;
      expect(file.name, equals('doc'));
      expect(file.filename, equals('test.txt'));
      expect(file.contentType.mimeType, equals('text/plain'));
      expect(file.string, equals(fileContent));
    });

    test('parses mixed fields and files', () async {
      final boundary = 'boundary123';
      final body =
          '--$boundary\r\n'
          'Content-Disposition: form-data; name="title"\r\n\r\n'
          'My Document\r\n'
          '--$boundary\r\n'
          'Content-Disposition: form-data; name="file"; filename="doc.txt"\r\n'
          'Content-Type: text/plain\r\n\r\n'
          'Content\r\n'
          '--$boundary--\r\n';

      final req = RivetRequest.from(
        StubHttpRequest(
          Uri.parse('http://localhost/upload'),
          utf8.encode(body),
        ),
      );

      req.headers.set(
        HttpHeaders.contentTypeHeader,
        ContentType(
          'multipart',
          'form-data',
          parameters: {'boundary': boundary},
        ),
      );

      await req.parseBody();

      expect(req.formFields['title'], equals('My Document'));
      expect(req.files, hasLength(1));
      expect(req.files.first.filename, equals('doc.txt'));
    });
  });
}
