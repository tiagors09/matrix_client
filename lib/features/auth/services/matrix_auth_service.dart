import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/core/models/result.dart';
import 'package:matrix_client/features/auth/exceptions/matrix_auth_exception.dart';
import 'package:matrix_client/features/auth/models/auth_login_response.dart';
import 'package:matrix_client/features/auth/services/auth_service.dart';
import 'package:matrix_client/src/rust/api/auth.dart';

/// Implements authentication by calling the generated Rust API.
class MatrixAuthService implements AuthService {
  /// FRB login function, injectable for tests.
  final Future<String> Function({
    required String homeserverUrl,
    required String username,
    required String password,
  })
  onLogin;

  /// FRB logout function, injectable for tests.
  final Future<void> Function() onLogout;

  /// Creates a Matrix authentication service with optional test overrides.
  MatrixAuthService({required this.onLogin, required this.onLogout});

  /// Decodes and validates the Rust login response before returning a user ID.
  @override
  Future<Result<String>> login(
    String hostname,
    String username,
    String password,
  ) async {
    final homeserverUri = _parseHomeserverUri(hostname);
    if (homeserverUri == null) {
      return Result.error(
        const MatrixAuthException(
          errorCode: 'INVALID_HOMESERVER_URL',
          message: 'Informe uma URL válida para o homeserver.',
        ),
      );
    }

    try {
      final response = await onLogin(
        homeserverUrl: homeserverUri.toString(),
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

  Uri? _parseHomeserverUri(String value) {
    final input = value.trim();
    if (input.isEmpty) return null;

    final uri = Uri.tryParse(input.contains('://') ? input : 'https://$input');
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }

    return uri;
  }

  /// Ends the Rust Matrix session and converts structured FRB errors.
  @override
  Future<void> logout() async {
    try {
      await onLogout();
    } on String catch (errorJson) {
      throw MatrixAuthException.fromJson(errorJson);
    }
  }
}

/// Provides the authentication service to the application.
final authServiceProvider = Provider<AuthService>((ref) {
  return MatrixAuthService(onLogin: login, onLogout: logout);
});
