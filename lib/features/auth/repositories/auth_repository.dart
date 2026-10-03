import 'package:matrix_client/core/models/result.dart';

/// Exposes authentication data to the UI layer.
abstract interface class AuthRepository {
  /// Authenticates against [hostname] and returns the Matrix user ID on success.
  Future<Result<String>> login(
    String hostname,
    String username,
    String password,
  );

  /// Ends the current authenticated session.
  Future<void> logout();
}
