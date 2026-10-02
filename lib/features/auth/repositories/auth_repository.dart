abstract interface class AuthRepository {
  Future<String> login(String hostname, String username, String password);
  Future<void> logout();
}
