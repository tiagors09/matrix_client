use matrix_sdk::{
    room::MessagesOptions,
    ruma::{events::room::message::SyncRoomMessageEvent, OwnedRoomId},
};

use crate::{
    api::{models::RoomMessage, room_error::RoomError},
    frb_generated::StreamSink,
    matrix::client::get_client,
};

#[flutter_rust_bridge::frb]
/// Loads the message history for a joined room.
pub async fn get_room_messages(room_id: String) -> Result<Vec<RoomMessage>, String> {
    let client = get_client().await.map_err(no_active_session)?;
    let parsed_room_id = room_id.parse::<OwnedRoomId>().map_err(invalid_room_id)?;
    let room = client
        .get_room(&parsed_room_id)
        .ok_or_else(room_not_found)?;
    load_room_messages(&room).await
}

#[flutter_rust_bridge::frb]
/// Sends a plain-text message to a joined room.
pub async fn send_message(room_id: String, body: String) -> Result<(), String> {
    let client = get_client().await.map_err(no_active_session)?;
    let parsed_room_id = room_id.parse::<OwnedRoomId>().map_err(invalid_room_id)?;
    let room = client
        .get_room(&parsed_room_id)
        .ok_or_else(room_not_found)?;
    room.send(matrix_sdk::ruma::events::room::message::RoomMessageEventContent::text_plain(body))
        .await
        .map_err(|error| RoomError::matrix_sdk(&error))?;
    Ok(())
}

#[flutter_rust_bridge::frb]
/// Streams message history updates for a joined room.
pub async fn watch_room_messages(room_id: String, sink: StreamSink<Vec<RoomMessage>>) {
    let client = match get_client().await {
        Ok(client) => client,
        Err(error) => {
            let _ = sink.add_error(no_active_session(error));
            return;
        }
    };
    let parsed_room_id = match room_id.parse::<OwnedRoomId>() {
        Ok(room_id) => room_id,
        Err(error) => {
            let _ = sink.add_error(invalid_room_id(error));
            return;
        }
    };
    let Some(room) = client.get_room(&parsed_room_id) else {
        let _ = sink.add_error(room_not_found());
        return;
    };
    let mut updates = room.subscribe_to_updates();

    loop {
        match load_room_messages(&room).await {
            Ok(messages) => {
                if sink.add(messages).is_err() {
                    break;
                }
            }
            Err(error) => {
                let _ = sink.add_error(error);
                break;
            }
        }
        if updates.recv().await.is_err() {
            break;
        }
    }
}

async fn load_room_messages(room: &matrix_sdk::Room) -> Result<Vec<RoomMessage>, String> {
    let messages = room
        .messages(MessagesOptions::backward())
        .await
        .map_err(|error| RoomError::matrix_sdk(&error))?;
    Ok(messages
        .chunk
        .into_iter()
        .filter_map(|event| {
            let event: SyncRoomMessageEvent = event.raw().deserialize_as_unchecked().ok()?;
            let body = event.as_original()?.content.body().to_owned();
            Some(RoomMessage {
                event_id: event.event_id().to_string(),
                sender: event.sender().to_string(),
                body,
                timestamp: event.origin_server_ts().get().into(),
            })
        })
        .collect::<Vec<_>>()
        .into_iter()
        .rev()
        .collect())
}

fn no_active_session(details: String) -> String {
    RoomError::new(
        Some(401),
        "NO_ACTIVE_SESSION",
        "Faça login para acessar as salas.",
        Some(details),
    )
}

fn invalid_room_id(error: matrix_sdk::IdParseError) -> String {
    RoomError::new(
        Some(400),
        "INVALID_ROOM_ID",
        "O identificador da sala é inválido.",
        Some(error.to_string()),
    )
}

fn room_not_found() -> String {
    RoomError::new(
        Some(404),
        "ROOM_NOT_FOUND",
        "Sala não encontrada ou não participada.",
        None,
    )
}
