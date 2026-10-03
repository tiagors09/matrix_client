class MatrixServiceException implements Exception {
  final int? statusCode;
  final String message;

  const MatrixServiceException({this.statusCode, required this.message});

  factory MatrixServiceException.from(Object error) {
    if (error is MatrixServiceException) return error;
    final message = error.toString();
    final explicitStatus = RegExp(r'\b([45]\d{2})\b')
        .firstMatch(message)
        ?.group(1);
    final matrixErrcode = RegExp(r'\bM_[A-Z0-9_]+\b')
        .firstMatch(message)
        ?.group(0);
    final matrixStatus = switch (matrixErrcode) {
      'M_UNAUTHORIZED' => 401,
      'M_FORBIDDEN' => 403,
      'M_NOT_FOUND' => 404,
      'M_INVALID_PARAM' => 400,
      'M_LIMIT_EXCEEDED' => 429,
      _ => null,
    };
    return MatrixServiceException(
      statusCode: explicitStatus == null
          ? matrixStatus
          : int.parse(explicitStatus),
      message: message,
    );
  }

  @override
  String toString() => statusCode == null
      ? message
      : 'Matrix request failed ($statusCode): $message';
}
