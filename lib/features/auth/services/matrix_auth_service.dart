import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/core/models/result.dart';
import 'package:matrix_client/features/auth/exceptions/matrix_auth_exception.dart';
import 'package:matrix_client/features/auth/models/auth_login_response.dart';
import 'package:matrix_client/features/auth/services/auth_service.dart';
import 'package:matrix_client/src/rust/api/auth.dart';

class MatrixAuthService implements AuthService {
  final Future<String> Function({
    required String homeserverUrl,
    required String username,
    required String password,
  })
  onLogin;
  final Future<void> Function() onLogout;

  MatrixAuthService({required this.onLogin, required this.onLogout});

  @override
  Future<Result<String>> login(
    String hostname,
    String username,
    String password,
  ) async {
    try {
      final homeserverUrl = Uri.https(hostname);
      final response = await onLogin(
        homeserverUrl: homeserverUrl.toString(),
        username: username,
        password: password,
      );
      final decoded = jsonDecode(response);
      if (decoded is! Map<String, dynamic>) {
        return Result.error(
          MatrixAuthException(message: 'Resposta do servidor inválida.'),
        );
      }

      try {
        final loginResponse = AuthLoginResponse.fromJson(decoded);
        if (loginResponse.statusCode != 200 ||
            loginResponse.userId.trim().isEmpty) {
          return Result.error(
            MatrixAuthException(
              statusCode: loginResponse.statusCode,
              errorCode: 'INVALID_LOGIN_RESPONSE',
              message: 'Não foi possível concluir a autenticação.',
            ),
          );
        }

        return Result.ok(loginResponse.userId);
      } on FormatException catch (error) {
        return Result.error(
          MatrixAuthException(
            message: 'Resposta do servidor inválida.',
            details: error.message,
          ),
        );
      }
    } on String catch (errorJson) {
      return Result.error(MatrixAuthException.fromJson(errorJson));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await onLogout();
    } on String catch (errorJson) {
      throw MatrixAuthException.fromJson(errorJson);
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return MatrixAuthService(onLogin: login, onLogout: logout);
});
