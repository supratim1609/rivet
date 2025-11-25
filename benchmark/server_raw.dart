import 'dart:io';

void main() async {
  final server = await HttpServer.bind('0.0.0.0', 3001, shared: true);
  print('Raw Dart Benchmark Server running on port 3001');

  await for (final req in server) {
    if (req.uri.path == '/') {
      req.response
        ..write('Hello World')
        ..close();
    } else {
      req.response
        ..statusCode = HttpStatus.notFound
        ..close();
    }
  }
}
