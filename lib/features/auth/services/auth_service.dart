abstract interface class AuthService {
  Future<dynamic> login(String hostname, String email, String password);
  Future<void> logout();
}
