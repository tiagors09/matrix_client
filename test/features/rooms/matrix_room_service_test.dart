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
        watchRooms: () => const Stream.empty(),
        loadMessages: (_) async => const [],
        watchMessages: (_) => const Stream.empty(),
        sendMessage: (_, _) async {},
      );

      final rooms = await service.joinedRooms();

      expect(rooms, hasLength(1));
      expect(rooms.single.roomId, '!room:matrix.org');
      expect(rooms.single.name, 'Room');
    });
  });

  group('MatrixRoomService errors', () {
    test('converts a 403 response to a typed exception', () async {
      final service = _createService(
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
      final service = _createService(
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
      final service = _createService(watchRooms: () => controller.stream);
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
      final service = _createService(loadRooms: () => Future.error(error));

      await expectLater(service.joinedRooms(), throwsA(same(error)));
    });
  });
}

MatrixRoomService _createService({
  Future<List<rust_models.RoomSummary>> Function()? loadRooms,
  Stream<List<rust_models.RoomSummary>> Function()? watchRooms,
  Future<List<rust_models.RoomMessage>> Function(String roomId)? loadMessages,
  Stream<List<rust_models.RoomMessage>> Function(String roomId)? watchMessages,
  Future<void> Function(String roomId, String body)? sendMessage,
}) => MatrixRoomService(
  loadRooms: loadRooms ?? () async => const [],
  watchRooms: watchRooms ?? () => const Stream.empty(),
  loadMessages: loadMessages ?? (_) async => const [],
  watchMessages: watchMessages ?? (_) => const Stream.empty(),
  sendMessage: sendMessage ?? (_, _) async {},
);
