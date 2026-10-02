import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_client/features/rooms/services/matrix_room_service.dart';
import 'package:matrix_client/src/rust/api/models.dart';

void main() {
  group('MatrixRoomService errors', () {
    test('converts a 403 response to a typed exception', () async {
      final service = MatrixRoomService(
        loadRooms: () => Future.error(Exception('M_FORBIDDEN: not allowed')),
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

    test('converts stream errors without swallowing them', () async {
      final controller = StreamController<List<RoomSummary>>();
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

      controller.addError(Exception('HTTP 500 Internal Server Error'));
      await expectation;
      await controller.close();
    });
  });
}
