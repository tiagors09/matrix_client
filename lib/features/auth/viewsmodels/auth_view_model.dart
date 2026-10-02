abstract interface class AuthViewModel {
  Future<void> login(String hostname, String email, String password);
  Future<void> logout();
}
