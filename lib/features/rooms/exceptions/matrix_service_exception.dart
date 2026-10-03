import 'dart:convert';

/// Represents a structured room or messaging failure returned by Rust.
class MatrixServiceException implements Exception {
  /// HTTP status code, when one is available.
  final int? statusCode;

  /// Matrix error code or an application-defined room error code.
  final String errorCode;

  /// User-facing description of the failed operation.
  final String message;

  /// Optional diagnostic details from the Rust API.
  final String? details;

  /// Creates a typed room service exception.
  const MatrixServiceException({
    this.statusCode,
    this.errorCode = 'MATRIX_ROOM_ERROR',
    required this.message,
    this.details,
  });

  /// Decodes a room error JSON payload returned over FRB.
  factory MatrixServiceException.fromJson(String json) {
    final decoded = jsonDecode(json);
    if (decoded case {
      'statusCode': final int? statusCode,
      'errorCode': final String errorCode,
      'message': final String message,
      'details': final String? details,
    }) {
      return MatrixServiceException(
        statusCode: statusCode,
        errorCode: errorCode,
        message: message,
        details: details,
      );
    }
    throw const FormatException('Invalid Matrix room error JSON.');
  }

  @override
  String toString() => statusCode == null
      ? message
      : 'Matrix request failed ($statusCode): $message';
}
