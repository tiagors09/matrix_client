import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Future<void> login(String hostname, String username, String password) async {
    log('Iniciando login pelo serviço Matrix', name: runtimeType.toString());

    try {
      final response = await _service.login(hostname, username, password);
      final hasResponse = response != null && response.toString().isNotEmpty;
      log(
        'Login retornou resposta: $hasResponse',
        name: runtimeType.toString(),
      );
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
