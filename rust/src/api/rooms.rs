use matrix_sdk::Room;

use crate::{
    api::{models::RoomSummary, room_error::RoomError},
    frb_generated::StreamSink,
    matrix::client::get_client,
};

fn summarize_room(room: &Room) -> RoomSummary {
    let room_id = room.room_id().to_string();
    let name = room.name().unwrap_or_else(|| room_id.clone());
    RoomSummary { room_id, name }
}

#[flutter_rust_bridge::frb]
/// Returns the rooms joined by the active Matrix user.
pub async fn joined_rooms() -> Result<Vec<RoomSummary>, String> {
    let client = get_client().await.map_err(|details| {
        RoomError::new(
            Some(401),
            "NO_ACTIVE_SESSION",
            "Faça login para acessar as salas.",
            Some(details),
        )
    })?;
    Ok(client.joined_rooms().iter().map(summarize_room).collect())
}

#[flutter_rust_bridge::frb]
/// Streams updates to the active user's joined rooms.
pub async fn watch_joined_rooms(sink: StreamSink<Vec<RoomSummary>>) {
    let client = match get_client().await {
        Ok(client) => client,
        Err(error) => {
            let _ = sink.add_error(RoomError::new(
                Some(401),
                "NO_ACTIVE_SESSION",
                "Faça login para acessar as salas.",
                Some(error),
            ));
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
