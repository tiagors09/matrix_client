abstract interface class AuthViewModel {
  Future<void> login(String hostname, String username, String password);
  Future<void> logout();
}
