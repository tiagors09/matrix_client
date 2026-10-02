#[derive(Clone, Debug)]
pub struct RoomSummary {
    pub room_id: String,
    pub name: String,
}

#[derive(Clone, Debug)]
pub struct RoomMessage {
    pub event_id: String,
    pub sender: String,
    pub body: String,
    pub timestamp: i64,
}
