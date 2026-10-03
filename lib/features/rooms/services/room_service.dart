import 'package:matrix_client/features/rooms/models/room_message.dart';
import 'package:matrix_client/features/rooms/models/room_summary.dart';

/// Defines common room and messaging operations for a chat service.
abstract interface class RoomService {
  /// Loads the rooms the current account has joined.
  Future<List<RoomSummary>> joinedRooms();

  /// Watches for updates to the joined room list.
  Stream<List<RoomSummary>> watchJoinedRooms();

  /// Loads the current message history for [roomId].
  Future<List<RoomMessage>> roomMessages(String roomId);

  /// Watches for message history updates in [roomId].
  Stream<List<RoomMessage>> watchRoomMessages(String roomId);

  /// Sends [body] as a text message to [roomId].
  Future<void> sendMessage(String roomId, String body);
}
