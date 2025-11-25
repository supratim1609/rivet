class RivetException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? details;

  RivetException(this.message, {this.statusCode = 500, this.details});

  @override
  String toString() => 'RivetException: $message (Status: $statusCode)';
}
