use crate::matrix::client::{get_client, set_client, stop_sync};
use matrix_sdk::Client;
use url::Url;

#[flutter_rust_bridge::frb]
pub async fn login(
    homeserver_url: String,
    username: String,
    password: String,
) -> Result<String, String> {
    eprintln!("[matrix-auth] login started");

    let url = Url::parse(&homeserver_url).map_err(|error| {
        eprintln!("[matrix-auth] invalid homeserver URL: {error}");
        error.to_string()
    })?;
    eprintln!("[matrix-auth] homeserver URL parsed");

    let client = Client::new(url).await.map_err(|error| {
        eprintln!("[matrix-auth] client creation failed: {error}");
        error.to_string()
    })?;
    eprintln!("[matrix-auth] client created");

    client
        .matrix_auth()
        .login_username(&username, &password)
        .initial_device_display_name("Flutter Desktop Client")
        .await
        .map_err(|error| {
            eprintln!("[matrix-auth] login request failed: {error}");
            error.to_string()
        })?;
    eprintln!("[matrix-auth] login request succeeded");

    let user_id = client
        .user_id()
        .ok_or_else(|| {
            eprintln!("[matrix-auth] login succeeded but no user ID was available");
            "Erro ao obter ID do usuário".to_string()
        })?
        .to_string();

    set_client(client.clone()).await;
    crate::matrix::client::start_sync(client).await;
    eprintln!("[matrix-auth] authenticated session stored");

    Ok(user_id)
}

#[flutter_rust_bridge::frb]
pub async fn logout() -> Result<(), String> {
    eprintln!("[matrix-auth] logout requested");
    stop_sync().await;

    if let Ok(client) = get_client().await {
        client.matrix_auth().logout().await.map_err(|error| {
            eprintln!("[matrix-auth] logout request failed: {error}");
            error.to_string()
        })?;
        set_client(None::<Client>).await;
        eprintln!("[matrix-auth] logout succeeded");
    } else {
        eprintln!("[matrix-auth] no active session to log out");
    }

    Ok(())
}
