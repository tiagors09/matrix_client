use matrix_sdk::Room;

use crate::{api::models::RoomSummary, frb_generated::StreamSink, matrix::client::get_client};

fn summarize_room(room: &Room) -> RoomSummary {
    let room_id = room.room_id().to_string();
    let name = room.name().unwrap_or_else(|| room_id.clone());
    RoomSummary { room_id, name }
}

#[flutter_rust_bridge::frb]
pub async fn joined_rooms() -> Result<Vec<RoomSummary>, String> {
    let client = get_client().await?;
    Ok(client.joined_rooms().iter().map(summarize_room).collect())
}

#[flutter_rust_bridge::frb]
pub async fn watch_joined_rooms(sink: StreamSink<Vec<RoomSummary>>) {
    let client = match get_client().await {
        Ok(client) => client,
        Err(error) => {
            let _ = sink.add_error(error);
            return;
        }
    };
    let mut updates = client.subscribe_to_all_room_updates();

    loop {
        let rooms = client.joined_rooms().iter().map(summarize_room).collect();
        if sink.add(rooms).is_err() {
            break;
        }
        if updates.recv().await.is_err() {
            break;
        }
    }
}
