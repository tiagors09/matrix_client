import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_client/core/models/result.dart';
import 'package:matrix_client/features/auth/exceptions/matrix_auth_exception.dart';
import 'package:matrix_client/features/auth/services/matrix_auth_service.dart';

void main() {
  group('MatrixAuthService', () {
    test('decodes the successful JSON response', () async {
      String? requestedHomeserverUrl;
      final service = MatrixAuthService(
        onLogin:
            ({required homeserverUrl, required username, required password}) {
              requestedHomeserverUrl = homeserverUrl;
              return Future.value(
                jsonEncode({
                  'status_code': 200,
                  'user_id': '@alice:matrix.org',
                }),
              );
            },
        onLogout: () async {},
      );

      final result = await service.login(
        'https://matrix.org',
        'alice',
        'secret',
      );

      expect(requestedHomeserverUrl, 'https://matrix.org');
      expect(
        result,
        isA<Ok<String>>().having(
          (ok) => ok.value,
          'userId',
          '@alice:matrix.org',
        ),
      );
    });

    test('adds HTTPS when the homeserver is provided as a hostname', () async {
      String? requestedHomeserverUrl;
      final service = MatrixAuthService(
        onLogin:
            ({required homeserverUrl, required username, required password}) {
              requestedHomeserverUrl = homeserverUrl;
              return Future.value(
                jsonEncode({
                  'status_code': 200,
                  'user_id': '@alice:matrix.org',
                }),
              );
            },
        onLogout: () async {},
      );

      await service.login('matrix.org', 'alice', 'secret');

      expect(requestedHomeserverUrl, 'https://matrix.org');
    });

    test(
      'rejects homeserver URLs without a valid HTTP scheme and host',
      () async {
        var loginCalled = false;
        final service = MatrixAuthService(
          onLogin:
              ({required homeserverUrl, required username, required password}) {
                loginCalled = true;
                return Future.value('{}');
              },
          onLogout: () async {},
        );

        final result = await service.login(
          'ftp://matrix.org',
          'alice',
          'secret',
        );

        expect(loginCalled, isFalse);
        expect(
          result,
          isA<Error<String>>().having(
            (failure) => failure.error,
            'error',
            isA<MatrixAuthException>()
                .having(
                  (error) => error.errorCode,
                  'errorCode',
                  'INVALID_HOMESERVER_URL',
                )
                .having(
                  (error) => error.message,
                  'message',
                  'Informe uma URL válida para o homeserver.',
                ),
          ),
        );
      },
    );

    test('maps invalid credentials to a safe 403 message', () async {
      final service = MatrixAuthService(
        onLogin:
            ({required homeserverUrl, required username, required password}) {
              return Future.error(
                jsonEncode({
                  'statusCode': 403,
                  'errorCode': 'M_FORBIDDEN',
                  'message': 'Authentication failed.',
                  'details': 'Invalid username/password',
                }),
              );
            },
        onLogout: () async {},
      );

      final result = await service.login(
        'https://matrix.org',
        'alice',
        'secret',
      );
      expect(
        result,
        isA<Error<String>>().having(
          (result) => result.error,
          'error',
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
              return Future.error(
                jsonEncode({
                  'statusCode': 500,
                  'errorCode': 'M_UNKNOWN',
                  'message': 'The homeserver failed.',
                  'details': null,
                }),
              );
            },
        onLogout: () async {},
      );

      final result = await service.login(
        'https://matrix.org',
        'alice',
        'secret',
      );
      expect(
        result,
        isA<Error<String>>().having(
          (result) => result.error,
          'error',
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

    test('preserves the structured Matrix error code', () async {
      final service = MatrixAuthService(
        onLogin:
            ({required homeserverUrl, required username, required password}) {
              return Future.error(
                jsonEncode({
                  'statusCode': 429,
                  'errorCode': 'M_LIMIT_EXCEEDED',
                  'message': 'Please retry later.',
                  'details': 'Rate limited',
                }),
              );
            },
        onLogout: () async {},
      );

      final result = await service.login(
        'https://matrix.org',
        'alice',
        'secret',
      );
      expect(
        result,
        isA<Error<String>>().having(
          (result) => result.error,
          'error',
          isA<MatrixAuthException>()
              .having((error) => error.statusCode, 'statusCode', 429)
              .having(
                (error) => error.errorCode,
                'errorCode',
                'M_LIMIT_EXCEEDED',
              )
              .having(
                (error) => error.message,
                'message',
                'Please retry later.',
              ),
        ),
      );
    });

    test('does not reinterpret non-string exceptions', () async {
      final error = StateError('unexpected failure');
      final service = MatrixAuthService(
        onLogin:
            ({required homeserverUrl, required username, required password}) {
              return Future.error(error);
            },
        onLogout: () async {},
      );

      await expectLater(
        service.login('https://matrix.org', 'alice', 'secret'),
        throwsA(same(error)),
      );
    });

    test('rejects a non-200 success payload in the service', () async {
      final service = MatrixAuthService(
        onLogin:
            ({required homeserverUrl, required username, required password}) {
              return Future.value(
                jsonEncode({'status_code': 403, 'user_id': ''}),
              );
            },
        onLogout: () async {},
      );

      final result = await service.login(
        'https://matrix.org',
        'alice',
        'secret',
      );

      expect(
        result,
        isA<Error<String>>().having(
          (failure) => failure.error,
          'error',
          isA<MatrixAuthException>()
              .having((error) => error.statusCode, 'statusCode', 403)
              .having(
                (error) => error.errorCode,
                'errorCode',
                'INVALID_LOGIN_RESPONSE',
              ),
        ),
      );
    });
  });
}
