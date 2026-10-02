import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/features/auth/exceptions/matrix_auth_exception.dart';
import 'package:matrix_client/features/auth/repositories/auth_repository.dart';
import 'package:matrix_client/features/auth/services/auth_service.dart';
import 'package:matrix_client/features/auth/services/matrix_auth_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final service = ref.watch(authServiceProvider);
  return MatrixAuthRepository(service);
});

class MatrixAuthRepository implements AuthRepository {
  final AuthService _service;

  MatrixAuthRepository(this._service);

  @override
  Future<String> login(
    String hostname,
    String username,
    String password,
  ) async {
    log('Iniciando login pelo serviço Matrix', name: runtimeType.toString());

    try {
      return await _service.login(hostname, username, password);
    } on MatrixAuthException catch (error) {
      log(
        'Login recusado pelo homeserver (status ${error.statusCode ?? 'desconhecido'})',
        name: runtimeType.toString(),
        level: 900,
      );
      rethrow;
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
