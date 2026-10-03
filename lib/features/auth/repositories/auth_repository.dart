import 'package:matrix_client/core/models/result.dart';
import 'package:matrix_client/features/auth/models/auth_login_response.dart';

abstract interface class AuthRepository {
  Future<Result<AuthLoginResponse>> login(
    String hostname,
    String username,
    String password,
  );
  Future<void> logout();
}
