/// Identifies a room and provides the display name used in room lists.
class RoomSummary {
  /// Matrix room ID used for room operations.
  final String roomId;

  /// Human-readable room name.
  final String name;

  /// Creates a room summary.
  const RoomSummary({required this.roomId, required this.name});
}
