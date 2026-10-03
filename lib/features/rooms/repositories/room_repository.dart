import 'package:matrix_client/features/rooms/models/room_message.dart';
import 'package:matrix_client/features/rooms/models/room_summary.dart';

/// Provides room and message data to view models.
abstract interface class RoomRepository {
  /// Returns rooms joined by the current account.
  Future<List<RoomSummary>> joinedRooms();

  /// Streams updates to the joined room list.
  Stream<List<RoomSummary>> watchJoinedRooms();

  /// Returns the message history for [roomId].
  Future<List<RoomMessage>> roomMessages(String roomId);

  /// Streams message history updates for [roomId].
  Stream<List<RoomMessage>> watchRoomMessages(String roomId);

  /// Sends [body] to [roomId].
  Future<void> sendMessage(String roomId, String body);
}
