use matrix_sdk::Client;
use std::sync::OnceLock;
use tokio::sync::Mutex;
use url::Url;

static MATRIX_CLIENT: OnceLock<Mutex<Option<Client>>> = OnceLock::new();

fn get_client_container() -> &'static Mutex<Option<Client>> {
    MATRIX_CLIENT.get_or_init(|| Mutex::new(None))
}

#[flutter_rust_bridge::frb]
pub async fn login_user(
    homeserver_url: String,
    username: String,
    password: String,
) -> Result<String, String> {
    let url = Url::parse(&homeserver_url).map_err(|e| e.to_string())?;
    let client = Client::new(url).await.map_err(|e| e.to_string())?;

    client
        .matrix_auth()
        .login_username(&username, &password)
        .initial_device_display_name("Flutter Desktop Client")
        .await
        .map_err(|e| e.to_string())?;

    let user_id = client
        .user_id()
        .ok_or("Erro ao obter ID do usuário")?
        .to_string();

    let mut client_lock = get_client_container().lock().await;
    *client_lock = Some(client);

    Ok(user_id)
}

#[flutter_rust_bridge::frb]
pub async fn logout() -> Result<(), String> {
    let mut client_lock = get_client_container().lock().await;

    if let Some(client) = client_lock.take() {
        client
            .matrix_auth()
            .logout()
            .await
            .map_err(|e| e.to_string())?;
    }

    Ok(())
}
