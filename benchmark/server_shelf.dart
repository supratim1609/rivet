import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'dart:convert';

void main() async {
  final handler = const Pipeline().addHandler((Request request) {
    final id = request.url.pathSegments.last;
    return Response.ok(
      jsonEncode({'id': id, 'name': 'User $id'}),
      headers: {'content-type': 'application/json'},
    );
  });

  await shelf_io.serve(handler, '0.0.0.0', 3000);
  print('Shelf server running on port 3000');
}
