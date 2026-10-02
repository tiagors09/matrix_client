import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/features/auth/viewsmodels/auth_view_model_impl.dart';
import 'package:matrix_client/features/auth/widgets/auth_form.dart';

class AuthView extends ConsumerWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.isAuthenticated && (previous?.isAuthenticated != true)) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });

    final state = ref.watch(authViewModelProvider);
    final notifier = ref.read(authViewModelProvider.notifier);

    return Scaffold(
      body: AuthForm(
        onLogin: notifier.login,
        isLoading: state.isLoading,
        isAuthenticated: state.isAuthenticated,
        errorMessage: state.errorMessage,
      ),
    );
  }
}
