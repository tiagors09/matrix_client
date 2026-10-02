use matrix_sdk::{
    room::MessagesOptions,
    ruma::{events::room::message::SyncRoomMessageEvent, OwnedRoomId},
};

use crate::{api::models::RoomMessage, frb_generated::StreamSink, matrix::client::get_client};

#[flutter_rust_bridge::frb]
pub async fn get_room_messages(room_id: String) -> Result<Vec<RoomMessage>, String> {
    let client = get_client().await?;
    let parsed_room_id = room_id
        .parse::<OwnedRoomId>()
        .map_err(|error: matrix_sdk::IdParseError| error.to_string())?;
    let room = client
        .get_room(&parsed_room_id)
        .ok_or_else(|| "Sala não encontrada ou não participada".to_string())?;
    load_room_messages(&room).await
}

#[flutter_rust_bridge::frb]
pub async fn send_message(room_id: String, body: String) -> Result<(), String> {
    let client = get_client().await?;
    let parsed_room_id = room_id
        .parse::<OwnedRoomId>()
        .map_err(|error: matrix_sdk::IdParseError| error.to_string())?;
    let room = client
        .get_room(&parsed_room_id)
        .ok_or_else(|| "Sala não encontrada ou não participada".to_string())?;
    room.send(matrix_sdk::ruma::events::room::message::RoomMessageEventContent::text_plain(body))
        .await
        .map_err(|error| error.to_string())?;
    Ok(())
}

#[flutter_rust_bridge::frb]
pub async fn watch_room_messages(room_id: String, sink: StreamSink<Vec<RoomMessage>>) {
    let client = match get_client().await {
        Ok(client) => client,
        Err(error) => {
            let _ = sink.add_error(error);
            return;
        }
    };
    let parsed_room_id = match room_id.parse::<OwnedRoomId>() {
        Ok(room_id) => room_id,
        Err(error) => {
            let _ = sink.add_error(error.to_string());
            return;
        }
    };
    let Some(room) = client.get_room(&parsed_room_id) else {
        let _ = sink.add_error("Sala não encontrada ou não participada".to_string());
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
        .map_err(|error| error.to_string())?;
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
