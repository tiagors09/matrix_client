import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_client/features/auth/exceptions/matrix_auth_exception.dart';
import 'package:matrix_client/features/auth/services/matrix_auth_service.dart';

void main() {
  group('MatrixAuthService', () {
    test('maps invalid credentials to a safe 403 message', () async {
      final service = MatrixAuthService(
        onLogin:
            ({required homeserverUrl, required username, required password}) {
              return Future.error(
                Exception(
                  'the server returned an error: [403 / M_FORBIDDEN] Invalid username/password',
                ),
              );
            },
        onLogout: () async {},
      );

      await expectLater(
        service.login('https://matrix.org', 'alice', 'secret'),
        throwsA(
          isA<MatrixAuthException>()
              .having((error) => error.statusCode, 'statusCode', 403)
              .having(
                (error) => error.message,
                'message',
                'Usuário ou senha inválidos.',
              ),
        ),
      );
    });

    test('maps server errors to a retryable user message', () async {
      final service = MatrixAuthService(
        onLogin:
            ({required homeserverUrl, required username, required password}) {
              return Future.error(Exception('HTTP 500 Internal Server Error'));
            },
        onLogout: () async {},
      );

      await expectLater(
        service.login('https://matrix.org', 'alice', 'secret'),
        throwsA(
          isA<MatrixAuthException>()
              .having((error) => error.statusCode, 'statusCode', 500)
              .having(
                (error) => error.message,
                'message',
                'O homeserver apresentou um erro. Tente novamente mais tarde.',
              ),
        ),
      );
    });
  });
}
