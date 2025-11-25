import 'dart:io';

class UploadedFile {
  final String name;
  final String filename;
  final ContentType contentType;
  final List<int> data;

  UploadedFile({
    required this.name,
    required this.filename,
    required this.contentType,
    required this.data,
  });

  String get string => String.fromCharCodes(data);
}
