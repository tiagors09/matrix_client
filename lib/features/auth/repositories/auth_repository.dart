import 'package:matrix_client/core/models/result.dart';

abstract interface class AuthRepository {
  Future<Result<String>> login(
    String hostname,
    String username,
    String password,
  );
  Future<void> logout();
}
