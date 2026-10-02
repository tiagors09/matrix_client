class MatrixAuthException implements Exception {
  final int? statusCode;
  final String message;

  const MatrixAuthException({this.statusCode, required this.message});

  factory MatrixAuthException.from(Object error) {
    final rawMessage = error.toString();

    final statusText = RegExp(r'\b([45]\d{2})\b')
        .firstMatch(rawMessage)
        ?.group(1);

    final matrixErrcode = RegExp(r'\bM_[A-Z0-9_]+\b')
        .firstMatch(rawMessage)
        ?.group(0);

    final statusCode = statusText == null
        ? switch (matrixErrcode) {
            'M_UNAUTHORIZED' => 401,
            'M_FORBIDDEN' => 403,
            _ => null,
          }
        : int.parse(statusText);

    final message = switch (statusCode) {
      401 || 403 => 'Usuário ou senha inválidos.',
      500 => 'O homeserver apresentou um erro. Tente novamente mais tarde.',
      _ => 'Não foi possível entrar. Verifique seus dados e tente novamente.',
    };

    return MatrixAuthException(statusCode: statusCode, message: message);
  }

  @override
  String toString() => message;
}
