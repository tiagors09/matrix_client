use crate::matrix::client::{get_client, set_client, stop_sync};
use matrix_sdk::Client;
use serde::Serialize;
use url::Url;

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct AuthError {
    pub status_code: Option<u16>,
    pub error_code: String,
    pub message: String,
    pub details: Option<String>,
}

#[derive(Debug, Serialize)]
pub struct AuthLoginResponse {
    pub status_code: u16,
    pub user_id: String,
}

impl AuthError {
    fn to_json(&self) -> String {
        serde_json::to_string(self).expect("AuthError fields are always JSON-serializable")
    }
}

fn auth_error(error_code: &str, message: &str, details: Option<String>) -> String {
    AuthError {
        status_code: None,
        error_code: error_code.to_owned(),
        message: message.to_owned(),
        details,
    }
    .to_json()
}

impl AuthLoginResponse {
    fn to_json(&self) -> String {
        serde_json::to_string(self).expect("AuthLoginResponse is always JSON-serializable")
    }
}

fn matrix_auth_error(
    status_code: Option<u16>,
    error_code: Option<String>,
    details: String,
) -> String {
    let error_code = error_code.unwrap_or_else(|| "MATRIX_AUTH_ERROR".to_owned());
    let message = match status_code {
        Some(401 | 403) => "Usuário ou senha inválidos.",
        Some(500..=599) => "O homeserver apresentou um erro. Tente novamente mais tarde.",
        _ => "Não foi possível autenticar no homeserver.",
    };

    AuthError {
        status_code,
        error_code,
        message: message.to_owned(),
        details: Some(details),
    }
    .to_json()
}

fn matrix_sdk_auth_error(error: &matrix_sdk::Error) -> String {
    let api_error = error.as_client_api_error();
    let status_code = api_error.map(|api_error| api_error.status_code.as_u16());
    let error_code = api_error
        .and_then(|api_error| api_error.error_kind())
        .map(|kind| kind.errcode().to_string());

    matrix_auth_error(status_code, error_code, error.to_string())
}

fn matrix_http_auth_error(error: &matrix_sdk::HttpError) -> String {
    let api_error = error.as_client_api_error();
    let status_code = api_error.map(|api_error| api_error.status_code.as_u16());
    let error_code = api_error
        .and_then(|api_error| api_error.error_kind())
        .map(|kind| kind.errcode().to_string());

    matrix_auth_error(status_code, error_code, error.to_string())
}

#[flutter_rust_bridge::frb]
pub async fn login(
    homeserver_url: String,
    username: String,
    password: String,
) -> Result<String, String> {
    eprintln!("[matrix-auth] login started");

    let url = Url::parse(&homeserver_url).map_err(|error| {
        eprintln!("[matrix-auth] invalid homeserver URL: {error}");
        auth_error(
            "INVALID_HOMESERVER_URL",
            "A URL do homeserver é inválida.",
            Some(error.to_string()),
        )
    })?;
    eprintln!("[matrix-auth] homeserver URL parsed");

    let client = Client::new(url).await.map_err(|error| {
        eprintln!("[matrix-auth] client creation failed: {error}");
        auth_error(
            "HOMESERVER_CONNECTION_ERROR",
            "Não foi possível conectar ao homeserver.",
            Some(error.to_string()),
        )
    })?;
    eprintln!("[matrix-auth] client created");

    client
        .matrix_auth()
        .login_username(&username, &password)
        .initial_device_display_name("Flutter Desktop Client")
        .await
        .map_err(|error| {
            eprintln!("[matrix-auth] login request failed: {error}");
            matrix_sdk_auth_error(&error)
        })?;
    eprintln!("[matrix-auth] login request succeeded");

    let user_id = client
        .user_id()
        .ok_or_else(|| {
            eprintln!("[matrix-auth] login succeeded but no user ID was available");
            auth_error(
                "MISSING_USER_ID",
                "Não foi possível obter o ID do usuário.",
                None,
            )
        })?
        .to_string();

    set_client(client.clone()).await;
    crate::matrix::client::start_sync(client).await;
    eprintln!("[matrix-auth] authenticated session stored");

    Ok(AuthLoginResponse {
        status_code: 200,
        user_id,
    }
    .to_json())
}

#[flutter_rust_bridge::frb]
pub async fn logout() -> Result<(), String> {
    eprintln!("[matrix-auth] logout requested");
    stop_sync().await;

    if let Ok(client) = get_client().await {
        client.matrix_auth().logout().await.map_err(|error| {
            eprintln!("[matrix-auth] logout request failed: {error}");
            matrix_http_auth_error(&error)
        })?;
        set_client(None::<Client>).await;
        eprintln!("[matrix-auth] logout succeeded");
    } else {
        eprintln!("[matrix-auth] no active session to log out");
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::{auth_error, AuthLoginResponse};

    #[test]
    fn serializes_auth_error_with_dart_field_names() {
        let encoded = auth_error(
            "INVALID_HOMESERVER_URL",
            "A URL do homeserver é inválida.",
            Some("relative URL without a base".to_owned()),
        );
        let decoded: serde_json::Value =
            serde_json::from_str(&encoded).expect("AuthError should be valid JSON");

        assert_eq!(decoded["statusCode"], serde_json::Value::Null);
        assert_eq!(decoded["errorCode"], "INVALID_HOMESERVER_URL");
        assert_eq!(decoded["message"], "A URL do homeserver é inválida.");
        assert_eq!(decoded["details"], "relative URL without a base");
    }

    #[test]
    fn serializes_success_with_only_status_and_user_id() {
        let encoded = AuthLoginResponse {
            status_code: 200,
            user_id: "@alice:matrix.org".to_owned(),
        }
        .to_json();
        let decoded: serde_json::Value =
            serde_json::from_str(&encoded).expect("AuthLoginResponse should be valid JSON");
        let fields = decoded.as_object().expect("response should be an object");

        assert_eq!(fields.len(), 2);
        assert_eq!(decoded["status_code"], 200);
        assert_eq!(decoded["user_id"], "@alice:matrix.org");
    }
}
