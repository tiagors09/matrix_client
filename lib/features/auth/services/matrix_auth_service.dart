import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/features/auth/services/auth_service.dart';
import 'package:matrix_client/src/rust/api/auth.dart';

class MatrixAuthService implements AuthService {
  final Future<dynamic> Function(String hostname, String email, String password)
  onLogin;
  final Future<void> Function() onLogout;

  MatrixAuthService({required this.onLogin, required this.onLogout});

  @override
  Future<dynamic> login(String hostname, String email, String password) async {
    return await onLogin(hostname, email, password);
  }

  @override
  Future<void> logout() async {
    await onLogout();
  }
}

// Provider configurado com as chamadas reais de HTTP/Matrix SDK
final authServiceProvider = Provider<AuthService>((ref) {
  return MatrixAuthService(
    onLogin: (homeserverUrl, username, password) => login(
      homeserverUrl: homeserverUrl,
      username: username,
      password: password,
    ),
    onLogout: logout,
  );
});
