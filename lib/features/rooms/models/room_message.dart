/// A text message displayed in a Matrix room conversation.
class RoomMessage {
  /// Matrix event ID identifying this message.
  final String eventId;

  /// Matrix user ID of the message sender.
  final String sender;

  /// Plain-text message body.
  final String body;

  /// Event timestamp in milliseconds since the Unix epoch.
  final int timestamp;

  /// Creates a room message.
  const RoomMessage({
    required this.eventId,
    required this.sender,
    required this.body,
    required this.timestamp,
  });
}
