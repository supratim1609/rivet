import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import '../http/request.dart';
import '../http/response.dart';
import 'middleware.dart';

MiddlewareHandler createStaticHandler(String rootPath) {
  // Resolve symlinks to get canonical path (fixes macOS /var vs /private/var issue)
  final root = Directory(rootPath).absolute.resolveSymbolicLinksSync();

  return (RivetRequest req, FutureOr<dynamic> Function() next) async {
    // Only handle GET and HEAD
    if (req.method != 'GET' && req.method != 'HEAD') {
      return next();
    }

    // Resolve path
    var requestPath = req.path;
    if (requestPath.endsWith('/')) {
      requestPath += 'index.html';
    }

    // Security check: Ensure path is within root
    // We use p.normalize to resolve .. segments before checking
    // requestPath usually starts with /, so substring(1) is correct, but let's be safer
    final relativePath = requestPath.startsWith('/') ? requestPath.substring(1) : requestPath;
    final file = File(p.join(root, relativePath)); 
    // Resolve symlinks for the target file too
    String resolvedPath;
    try {
      resolvedPath = await file.resolveSymbolicLinks();
    } catch (e) {
      // File doesn't exist or other error
      return next();
    }

    if (!resolvedPath.startsWith(root)) {
      // Path traversal attempt or outside root
      return next();
    }

    if (await file.exists()) {
      final stat = await file.stat();
      var mimeType = lookupMimeType(file.path);
      
      // Fallback for common types if mime package fails
      if (mimeType == null) {
        final ext = p.extension(file.path).toLowerCase();
        if (ext == '.css') {
          mimeType = 'text/css';
        } else if (ext == '.html') mimeType = 'text/html';
        else if (ext == '.js') mimeType = 'application/javascript';
        else if (ext == '.json') mimeType = 'application/json';
        else mimeType = 'application/octet-stream';
      }
      
      return RivetResponse(
        file.openRead(),
        headers: {
          HttpHeaders.contentTypeHeader: mimeType,
          HttpHeaders.contentLengthHeader: stat.size.toString(),
        },
      );
    }

    return next();
  };
}
