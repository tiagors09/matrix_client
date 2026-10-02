import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/features/auth/viewsmodels/auth_view_model_impl.dart';
import 'package:matrix_client/features/auth/widgets/auth_form.dart';

class AuthView extends ConsumerWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(authViewModelProvider);

    return Scaffold(body: AuthForm(onLogin: vm.login));
  }
}
