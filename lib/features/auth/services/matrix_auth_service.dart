import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Future<dynamic> login(
    String hostname,
    String username,
    String password,
  ) async {
    final response = await onLogin(
      homeserverUrl: hostname,
      username: username,
      password: password,
    );

    return response;
  }

  @override
  Future<void> logout() async {
    await onLogout();
  }
}

// Provider configurado com as chamadas reais de HTTP/Matrix SDK
final authServiceProvider = Provider<AuthService>((ref) {
  return MatrixAuthService(onLogin: login, onLogout: logout);
});
