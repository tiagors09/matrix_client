class AuthLoginResponse {
  final int statusCode;
  final String userId;

  const AuthLoginResponse({required this.statusCode, required this.userId});

  factory AuthLoginResponse.fromJson(Map<String, dynamic> json) {
    final statusCode = json['status_code'];
    final userId = json['user_id'];

    if (statusCode is! int || userId is! String) {
      throw const FormatException('Invalid Matrix login response JSON.');
    }

    return AuthLoginResponse(statusCode: statusCode, userId: userId);
  }
}
