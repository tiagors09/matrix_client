import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/features/auth/views/auth_view.dart';
import 'package:matrix_client/features/rooms/views/rooms_view.dart';

/// Configures the application theme, providers, and top-level routes.
class MatrixClientApp extends StatelessWidget {
  const MatrixClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData(
          colorSchemeSeed: Colors.blueAccent,
          useMaterial3: true,
        ),
        initialRoute: '/login',
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => AuthView(),
          '/home': (context) => RoomsView(),
        },
      ),
    );
  }
}
