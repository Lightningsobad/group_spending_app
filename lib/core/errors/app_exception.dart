class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final Map<String, String>? fieldErrors;

  const AppException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.fieldErrors,
  });

  @override
  String toString() => 'AppException: $message (code: $errorCode, status: $statusCode)';
}
