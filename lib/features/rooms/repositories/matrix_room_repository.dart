import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/features/rooms/models/room_message.dart';
import 'package:matrix_client/features/rooms/models/room_summary.dart';
import 'package:matrix_client/features/rooms/repositories/room_repository.dart';
import 'package:matrix_client/features/rooms/services/matrix_room_service.dart';
import 'package:matrix_client/features/rooms/services/room_service.dart';

/// Provides the room repository backed by the Matrix service.
final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  final service = ref.watch(matrixRoomServiceProvider);
  return MatrixRoomRepository(service);
});

/// Implements [RoomRepository] by delegating to a [RoomService].
class MatrixRoomRepository implements RoomRepository {
  /// The room data source used by this repository.
  final RoomService _service;

  /// Creates a repository backed by [_service].
  const MatrixRoomRepository(this._service);

  @override
  Future<List<RoomSummary>> joinedRooms() => _service.joinedRooms();

  @override
  Stream<List<RoomSummary>> watchJoinedRooms() => _service.watchJoinedRooms();

  @override
  Future<List<RoomMessage>> roomMessages(String roomId) =>
      _service.roomMessages(roomId);

  @override
  Stream<List<RoomMessage>> watchRoomMessages(String roomId) =>
      _service.watchRoomMessages(roomId);

  @override
  Future<void> sendMessage(String roomId, String body) =>
      _service.sendMessage(roomId, body);
}

/// Streams joined rooms to consumers in the rooms feature.
final joinedRoomsStreamProvider = StreamProvider<List<RoomSummary>>(
  (ref) => ref.watch(roomRepositoryProvider).watchJoinedRooms(),
);

/// Streams messages for the requested room ID.
final roomMessagesStreamProvider =
    StreamProvider.family<List<RoomMessage>, String>((ref, roomId) {
      return ref.watch(roomRepositoryProvider).watchRoomMessages(roomId);
    });
