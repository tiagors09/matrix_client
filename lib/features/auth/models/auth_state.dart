/// UI state for the authentication flow.
class AuthState {
  /// Whether an authentication operation is currently running.
  final bool isLoading;

  /// Whether the user has an active authenticated session.
  final bool isAuthenticated;

  /// Matrix user ID returned by the successful login, if available.
  final String? userId;

  /// User-facing authentication error, if the latest operation failed.
  final String? errorMessage;

  /// Creates an authentication state.
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.userId,
    this.errorMessage,
  });

  /// Returns a copy with the supplied values while retaining unchanged fields.
  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? userId,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      errorMessage: errorMessage,
    );
  }
}
