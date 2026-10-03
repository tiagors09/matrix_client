# Matrix Client

A desktop Matrix client built with Flutter and Dart, with Matrix operations
implemented in Rust using the Matrix SDK and exposed to Dart through
Flutter Rust Bridge (FRB).

## Features

- Sign in to a Matrix homeserver with a username and password.
- Browse joined rooms in a responsive room drawer/sidebar.
- Select a room and receive its messages as a stream.
- Distinguish sent and received messages with aligned chat bubbles.
- Send plain-text messages.
- Receive structured authentication and room errors across the Rust/Dart
  boundary.

## Architecture

The app uses a feature-oriented MVVM structure:

```text
Flutter view and widgets
        |
ViewModel interface / Riverpod implementation
        |
Repository interface / implementation
        |
Service interface / Matrix implementation
        |
Generated FRB Dart API
        |
Rust API -> Matrix SDK -> Matrix homeserver
```

- **Views and widgets** render state and forward user interactions.
- **View models** manage UI state and coordinate user actions.
- **Repositories** expose feature data to view models and delegate to services.
- **Services** own transport-specific behavior, including FRB integration,
  JSON decoding, status validation, and conversion to app models.
- **Rust** manages the Matrix SDK client, login/logout, room/message operations,
  and streams.

Room and message streams are exposed through Riverpod stream providers. The
current user ID is retained in authentication state and used to align the
current user's messages to the right.

## Requirements

- Flutter 3.47 or later (Dart 3.13 or later).
- Rust toolchain supported by the Flutter Rust Bridge Cargokit builder.
- A desktop toolchain for the target platform:
  - Linux: CMake, Ninja, and a C/C++ compiler.
  - macOS: Xcode command-line tools.
  - Windows: Visual Studio with the C++ desktop workload.
- A reachable Matrix homeserver and a valid account.

## Getting started

Fetch Flutter dependencies:

```sh
flutter pub get
```

Run the desktop client (choose an installed Flutter desktop target):

```sh
flutter run -d linux
```

Other supported Flutter targets include `macos` and `windows`.

The Rust library is built by the `rust_lib_matrix_client` Flutter plugin. When
running the app, Cargokit builds the native library for the selected target.

## Flutter Rust Bridge

The bridge configuration is in [`flutter_rust_bridge.yaml`](flutter_rust_bridge.yaml).
Rust API source files are under `rust/src/api/`; generated Dart bindings are
under `lib/src/rust/` and should not be edited by hand.

After changing an FRB-exposed Rust API, regenerate the bindings with the
project's installed code generator:

```sh
flutter_rust_bridge_codegen generate
```

If the executable is not on `PATH`, run the code generator using the
installation method documented by Flutter Rust Bridge.

## Error and response contracts

Login success is JSON with exactly `status_code` and `user_id`, for example:

```json
{"status_code":200,"user_id":"@alice:matrix.org"}
```

Rust errors are JSON objects with `statusCode`, `errorCode`, `message`, and
optional `details` fields. Dart services parse these transport payloads into
typed exceptions and validate success status codes before returning domain
data.

## Tests and analysis

Run all Flutter tests:

```sh
flutter test
```

Run static analysis:

```sh
flutter analyze
```

Run Rust tests and type-check the native library:

```sh
cargo test --manifest-path rust/Cargo.toml
cargo check --manifest-path rust/Cargo.toml
```

## API documentation

Public Dart APIs use `///` documentation comments. Generate browsable API
documentation with:

```sh
dart doc
```

The generated site is written to `doc/api/`. Rust API functions and public
Rust data structures use Rust documentation comments and can be browsed with:

```sh
cargo doc --manifest-path rust/Cargo.toml --no-deps --open
```
