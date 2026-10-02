abstract interface class AuthRepository {
  Future<dynamic> login(String hostname, String username, String password);
  Future<void> logout();
}
