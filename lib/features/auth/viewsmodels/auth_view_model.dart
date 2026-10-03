/// Commands exposed by the authentication view model.
abstract interface class AuthViewModel {
  /// Attempts to sign in and updates the authentication UI state.
  Future<void> login(String hostname, String username, String password);

  /// Ends the current session and resets the authentication UI state.
  Future<void> logout();
}
