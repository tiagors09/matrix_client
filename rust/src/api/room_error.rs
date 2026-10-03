use serde::Serialize;

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
/// Structured room error serialized for the Dart service layer.
pub struct RoomError {
    /// HTTP status code, when available.
    pub status_code: Option<u16>,
    /// Matrix error code or application-defined code.
    pub error_code: String,
    /// User-facing description of the failure.
    pub message: String,
    /// Optional diagnostic details.
    pub details: Option<String>,
}

impl RoomError {
    /// Serializes this error using the Dart-facing JSON field names.
    pub fn to_json(&self) -> String {
        serde_json::to_string(self).expect("RoomError fields are always JSON-serializable")
    }

    /// Builds and serializes an application-defined room error.
    pub fn new(
        status_code: Option<u16>,
        error_code: &str,
        message: &str,
        details: Option<String>,
    ) -> String {
        Self {
            status_code,
            error_code: error_code.to_owned(),
            message: message.to_owned(),
            details,
        }
        .to_json()
    }

    /// Converts a Matrix SDK error into the room error JSON contract.
    pub fn matrix_sdk(error: &matrix_sdk::Error) -> String {
        let api_error = error.as_client_api_error();
        let status_code = api_error.map(|error| error.status_code.as_u16());
        let error_code = api_error
            .and_then(|error| error.error_kind())
            .map(|kind| kind.errcode().to_string())
            .unwrap_or_else(|| "MATRIX_ROOM_ERROR".to_owned());

        Self::matrix_response(status_code, error_code, error.to_string())
    }

    fn matrix_response(status_code: Option<u16>, error_code: String, details: String) -> String {
        let message = match status_code {
            Some(401 | 403) => "Acesso negado à sala.",
            Some(404) => "Sala não encontrada.",
            Some(500..=599) => "O homeserver apresentou um erro. Tente novamente mais tarde.",
            _ => "Não foi possível concluir a operação na sala.",
        };

        Self::new(status_code, &error_code, message, Some(details))
    }
}

#[cfg(test)]
mod tests {
    use super::RoomError;

    #[test]
    fn serializes_structured_room_error_with_camel_case_fields() {
        let encoded = RoomError::new(
            Some(404),
            "ROOM_NOT_FOUND",
            "Sala não encontrada.",
            Some("room does not exist".to_owned()),
        );
        let decoded: serde_json::Value =
            serde_json::from_str(&encoded).expect("RoomError should be valid JSON");

        assert_eq!(decoded["statusCode"], 404);
        assert_eq!(decoded["errorCode"], "ROOM_NOT_FOUND");
        assert_eq!(decoded["message"], "Sala não encontrada.");
        assert_eq!(decoded["details"], "room does not exist");
    }
}
