import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_client/features/rooms/exceptions/matrix_service_exception.dart';
import 'package:matrix_client/features/rooms/services/matrix_room_service.dart';
import 'package:matrix_client/features/rooms/services/room_service.dart';
import 'package:matrix_client/src/rust/api/models.dart' as rust_models;

void main() {
  group('MatrixRoomService contract', () {
    test('implements RoomService and maps Matrix room models', () async {
      final RoomService service = MatrixRoomService(
        loadRooms: () async => const [
          rust_models.RoomSummary(roomId: '!room:matrix.org', name: 'Room'),
        ],
      );

      final rooms = await service.joinedRooms();

      expect(rooms, hasLength(1));
      expect(rooms.single.roomId, '!room:matrix.org');
      expect(rooms.single.name, 'Room');
    });
  });

  group('MatrixRoomService errors', () {
    test('converts a 403 response to a typed exception', () async {
      final service = MatrixRoomService(
        loadRooms: () => Future.error(
          jsonEncode({
            'statusCode': 403,
            'errorCode': 'M_FORBIDDEN',
            'message': 'Acesso negado à sala.',
            'details': 'M_FORBIDDEN: not allowed',
          }),
        ),
      );

      await expectLater(
        service.joinedRooms(),
        throwsA(
          isA<MatrixServiceException>().having(
            (error) => error.statusCode,
            'statusCode',
            403,
          ),
        ),
      );
    });

    test('preserves structured error details and code', () async {
      final service = MatrixRoomService(
        loadRooms: () => Future.error(
          jsonEncode({
            'statusCode': 404,
            'errorCode': 'ROOM_NOT_FOUND',
            'message': 'Sala não encontrada.',
            'details': 'Unknown room',
          }),
        ),
      );

      await expectLater(
        service.joinedRooms(),
        throwsA(
          isA<MatrixServiceException>()
              .having((error) => error.errorCode, 'errorCode', 'ROOM_NOT_FOUND')
              .having((error) => error.details, 'details', 'Unknown room'),
        ),
      );
    });

    test('converts stream errors without swallowing them', () async {
      final controller = StreamController<List<rust_models.RoomSummary>>();
      final service = MatrixRoomService(watchRooms: () => controller.stream);
      final expectation = expectLater(
        service.watchJoinedRooms(),
        emitsError(
          isA<MatrixServiceException>().having(
            (error) => error.statusCode,
            'statusCode',
            500,
          ),
        ),
      );

      controller.addError(
        jsonEncode({
          'statusCode': 500,
          'errorCode': 'MATRIX_ROOM_ERROR',
          'message': 'Homeserver indisponível.',
          'details': 'Upstream error',
        }),
      );
      await expectation;
      await controller.close();
    });

    test('does not parse non-string errors as Matrix errors', () async {
      final error = StateError('unexpected failure');
      final service = MatrixRoomService(loadRooms: () => Future.error(error));

      await expectLater(service.joinedRooms(), throwsA(same(error)));
    });
  });
}
