import 'package:matrix_client/core/models/result.dart';

/// Defines authentication operations provided by an external identity source.
abstract interface class AuthService {
  /// Logs in to a homeserver and returns the authenticated Matrix user ID.
  Future<Result<String>> login(
    String hostname,
    String username,
    String password,
  );

  /// Logs out of the current homeserver session.
  Future<void> logout();
}
