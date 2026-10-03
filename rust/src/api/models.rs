#[derive(Clone, Debug)]
/// Display information for a Matrix room joined by the current user.
pub struct RoomSummary {
    /// Fully qualified Matrix room ID.
    pub room_id: String,
    /// Display name of the room, falling back to its ID when unnamed.
    pub name: String,
}

#[derive(Clone, Debug)]
/// Plain-text room message exposed to the Flutter application.
pub struct RoomMessage {
    /// Matrix event ID.
    pub event_id: String,
    /// Matrix user ID of the sender.
    pub sender: String,
    /// Plain-text event body.
    pub body: String,
    /// Event timestamp in milliseconds since the Unix epoch.
    pub timestamp: i64,
}
