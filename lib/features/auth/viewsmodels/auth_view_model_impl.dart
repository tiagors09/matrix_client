import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/core/models/result.dart';
import 'package:matrix_client/features/auth/exceptions/matrix_auth_exception.dart';
import 'package:matrix_client/features/auth/models/auth_state.dart';
import 'package:matrix_client/features/auth/repositories/auth_repository.dart';
import 'package:matrix_client/features/auth/repositories/matrix_auth_repository.dart';
import 'package:matrix_client/features/auth/viewsmodels/auth_view_model.dart';

/// Riverpod notifier that coordinates authentication commands and UI state.
class AuthViewModelImpl extends Notifier<AuthState> implements AuthViewModel {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    return const AuthState();
  }

  @override
  void togglePasswordVisibility() {
    state = state.copyWith(obscureText: !state.obscureText);
  }

  @override
  Future<void> login(String hostname, String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _repository.login(hostname, username, password);
      switch (result) {
        case Ok(value: final userId):
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            userId: userId,
          );
        case Error(error: final error):
          state = state.copyWith(
            isLoading: false,
            errorMessage: error is MatrixAuthException
                ? error.message
                : 'Não foi possível entrar. Tente novamente.',
          );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Não foi possível entrar. Tente novamente.',
      );
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

/// Provides authentication UI state and commands.
final authViewModelProvider = NotifierProvider<AuthViewModelImpl, AuthState>(
  AuthViewModelImpl.new,
);
