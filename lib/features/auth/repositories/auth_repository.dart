abstract interface class AuthRepository {
  Future<dynamic> login(String hostname, String email, String password);
  Future<void> logout();
}
