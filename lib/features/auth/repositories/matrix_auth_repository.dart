import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/core/models/result.dart';
import 'package:matrix_client/features/auth/repositories/auth_repository.dart';
import 'package:matrix_client/features/auth/services/auth_service.dart';
import 'package:matrix_client/features/auth/services/matrix_auth_service.dart';

/// Provides the authentication repository backed by the Matrix service.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final service = ref.watch(authServiceProvider);
  return MatrixAuthRepository(service);
});

/// Delegates authentication operations to the configured [AuthService].
class MatrixAuthRepository implements AuthRepository {
  /// The authentication data source used by this repository.
  final AuthService _service;

  /// Creates a repository backed by [_service].
  MatrixAuthRepository(this._service);

  /// Returns the typed login result from the authentication service.
  @override
  Future<Result<String>> login(
    String hostname,
    String username,
    String password,
  ) async {
    log('Iniciando login pelo serviço Matrix', name: runtimeType.toString());

    try {
      return await _service.login(hostname, username, password);
    } catch (e, stackTrace) {
      log(
        'Erro ao realizar login',
        error: e,
        stackTrace: stackTrace,
        name: runtimeType.toString(),
      );
      rethrow;
    }
  }

  /// Delegates logout and logs failures before rethrowing them.
  @override
  Future<void> logout() async {
    try {
      await _service.logout();
    } catch (e, stackTrace) {
      log(
        'Erro ao realizar logout',
        error: e,
        stackTrace: stackTrace,
        name: runtimeType.toString(),
      );
      rethrow;
    }
  }
}
