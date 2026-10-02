import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/features/auth/views/auth_view.dart';

class MatrixClientApp extends StatelessWidget {
  const MatrixClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(body: AuthView()),
      ),
    );
  }
}
