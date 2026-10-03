import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_client/features/rooms/models/room_message.dart';
import 'package:matrix_client/features/rooms/models/room_summary.dart';
import 'package:matrix_client/features/rooms/repositories/matrix_room_repository.dart';
import 'package:matrix_client/features/rooms/repositories/room_repository.dart';
import 'package:matrix_client/features/rooms/services/room_service.dart';

void main() {
  group('MatrixRoomRepository', () {
    test('implements RoomRepository and delegates room operations', () async {
      final service = _FakeRoomService();
      final RoomRepository repository = MatrixRoomRepository(service);

      expect(await repository.joinedRooms(), service.rooms);
      expect(
        await repository.roomMessages('!room:matrix.org'),
        service.messages,
      );

      await repository.sendMessage('!room:matrix.org', 'Hello');

      expect(service.sentMessages, [('!room:matrix.org', 'Hello')]);
    });
  });
}

class _FakeRoomService implements RoomService {
  final rooms = const [RoomSummary(roomId: '!room:matrix.org', name: 'Room')];
  final messages = const [
    RoomMessage(
      eventId: r'$event:matrix.org',
      sender: '@alice:matrix.org',
      body: 'Hello',
      timestamp: 100,
    ),
  ];
  final sentMessages = <(String, String)>[];

  @override
  Future<List<RoomSummary>> joinedRooms() async => rooms;

  @override
  Stream<List<RoomSummary>> watchJoinedRooms() => Stream.value(rooms);

  @override
  Future<List<RoomMessage>> roomMessages(String roomId) async => messages;

  @override
  Stream<List<RoomMessage>> watchRoomMessages(String roomId) =>
      Stream.value(messages);

  @override
  Future<void> sendMessage(String roomId, String body) async {
    sentMessages.add((roomId, body));
  }
}
