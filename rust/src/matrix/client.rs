use matrix_sdk::{config::SyncSettings, Client};
use std::sync::OnceLock;
use tokio::{sync::Mutex, task::JoinHandle};

static MATRIX_CLIENT: OnceLock<Mutex<Option<Client>>> = OnceLock::new();
static SYNC_TASK: OnceLock<Mutex<Option<JoinHandle<()>>>> = OnceLock::new();

fn client_container() -> &'static Mutex<Option<Client>> {
    MATRIX_CLIENT.get_or_init(|| Mutex::new(None))
}

fn sync_task_container() -> &'static Mutex<Option<JoinHandle<()>>> {
    SYNC_TASK.get_or_init(|| Mutex::new(None))
}

pub async fn get_client() -> Result<Client, String> {
    client_container()
        .lock()
        .await
        .as_ref()
        .cloned()
        .ok_or_else(|| "Nenhuma sessão Matrix ativa".to_string())
}

pub async fn set_client(client: impl Into<Option<Client>>) {
    *client_container().lock().await = client.into();
}

pub async fn start_sync(client: Client) {
    let mut task = sync_task_container().lock().await;
    if task.as_ref().is_some_and(|handle| !handle.is_finished()) {
        return;
    }

    *task = Some(tokio::spawn(async move {
        if let Err(error) = client.sync(SyncSettings::default()).await {
            eprintln!("[matrix-sync] sync stopped: {error}");
        }
    }));
}

pub async fn stop_sync() {
    if let Some(task) = sync_task_container().lock().await.take() {
        task.abort();
    }
}
