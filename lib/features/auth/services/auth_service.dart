abstract interface class AuthService {
  Future<dynamic> login(String hostname, String username, String password);
  Future<void> logout();
}
