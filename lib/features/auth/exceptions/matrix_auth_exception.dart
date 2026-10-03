import 'dart:convert';

/// Represents a structured authentication failure returned by the Rust API.
class MatrixAuthException implements Exception {
  /// HTTP status code, when the homeserver returned one.
  final int? statusCode;

  /// Matrix error code or an application-defined authentication error code.
  final String errorCode;

  /// Safe message suitable for displaying to the user.
  final String message;

  /// Optional diagnostic details returned by the Rust API.
  final String? details;

  /// Creates a typed authentication exception.
  const MatrixAuthException({
    this.statusCode,
    this.errorCode = 'MATRIX_AUTH_ERROR',
    required this.message,
    this.details,
  });

  /// Decodes an authentication error JSON payload returned over FRB.
  factory MatrixAuthException.fromJson(String json) {
    final decoded = jsonDecode(json);
    if (decoded case {
      'statusCode': final int? statusCode,
      'errorCode': final String errorCode,
      'message': final String rustMessage,
      'details': final String? details,
    }) {
      final message = switch (statusCode) {
        401 || 403 => 'Usuário ou senha inválidos.',
        500 => 'O homeserver apresentou um erro. Tente novamente mais tarde.',
        _ => rustMessage,
      };

      return MatrixAuthException(
        statusCode: statusCode,
        errorCode: errorCode,
        message: message,
        details: details,
      );
    }
    throw const FormatException('Invalid Matrix authentication error JSON.');
  }

  @override
  String toString() => message;
}
