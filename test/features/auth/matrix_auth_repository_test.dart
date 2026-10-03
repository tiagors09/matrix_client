import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_client/core/models/result.dart';
import 'package:matrix_client/features/auth/repositories/matrix_auth_repository.dart';
import 'package:matrix_client/features/auth/services/auth_service.dart';

void main() {
  group('MatrixAuthRepository', () {
    test('returns the user ID for a valid successful response', () async {
      final repository = MatrixAuthRepository(
        _FakeAuthService(
          const Result.ok('@alice:matrix.org'),
        ),
      );

      final result = await repository.login(
        'https://matrix.org',
        'alice',
        'secret',
      );

      expect(
        result,
        isA<Ok<String>>().having(
          (ok) => ok.value,
          'userId',
          '@alice:matrix.org',
        ),
      );
    });

    test('passes service errors through without interpreting them', () async {
      const error = FormatException('Invalid service response.');
      final repository = MatrixAuthRepository(
        _FakeAuthService(Result.error(error)),
      );

      final result = await repository.login(
        'https://matrix.org',
        'alice',
        'secret',
      );

      expect(
        result,
        isA<Error<String>>().having((failure) => failure.error, 'error', error),
      );
    });
  });
}

class _FakeAuthService implements AuthService {
  final Result<String> result;

  const _FakeAuthService(this.result);

  @override
  Future<Result<String>> login(
    String hostname,
    String username,
    String password,
  ) async => result;

  @override
  Future<void> logout() async {}
}
