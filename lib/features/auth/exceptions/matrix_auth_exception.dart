import 'dart:convert';

class MatrixAuthException implements Exception {
  final int? statusCode;
  final String errorCode;
  final String message;
  final String? details;

  const MatrixAuthException({
    this.statusCode,
    this.errorCode = 'MATRIX_AUTH_ERROR',
    required this.message,
    this.details,
  });

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
