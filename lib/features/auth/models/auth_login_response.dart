/// Contains the successful login status and the authenticated Matrix user ID.
class AuthLoginResponse {
  /// HTTP status code reported by the Rust login API.
  final int statusCode;

  /// Fully qualified Matrix user ID of the authenticated account.
  final String userId;

  /// Creates a login response.
  const AuthLoginResponse({required this.statusCode, required this.userId});

  /// Creates a login response from the Rust success JSON payload.
  factory AuthLoginResponse.fromJson(Map<String, dynamic> json) {
    final statusCode = json['status_code'];
    final userId = json['user_id'];

    if (statusCode is! int || userId is! String) {
      throw const FormatException('Invalid Matrix login response JSON.');
    }

    return AuthLoginResponse(statusCode: statusCode, userId: userId);
  }
}
