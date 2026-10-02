import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/features/auth/models/auth_state.dart';
import 'package:matrix_client/features/auth/repositories/auth_repository.dart';
import 'package:matrix_client/features/auth/repositories/matrix_auth_repository.dart';
import 'package:matrix_client/features/auth/viewsmodels/auth_view_model.dart';

class AuthViewModelImpl extends Notifier<AuthState> implements AuthViewModel {
  final AuthRepository _repository;

  new(this._repository);

  @override
  AuthState build() {
    return const AuthState();
  }

  @override
  Future<void> login(String hostname, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.login(hostname, email, password);
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _repository.logout();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final authViewModelProvider = Provider<AuthViewModel>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthViewModelImpl(repository);
});
