import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/features/rooms/exceptions/matrix_service_exception.dart';
import 'package:matrix_client/features/rooms/models/room_message.dart';
import 'package:matrix_client/features/rooms/models/room_summary.dart';
import 'package:matrix_client/features/rooms/services/room_service.dart';
import 'package:matrix_client/src/rust/api/messages.dart' as rust_messages;
import 'package:matrix_client/src/rust/api/models.dart' as rust_models;
import 'package:matrix_client/src/rust/api/rooms.dart' as rust_rooms;

/// Implements [RoomService] using the generated Matrix Rust API.
class MatrixRoomService implements RoomService {
  final Future<List<rust_models.RoomSummary>> Function() _loadRooms;
  final Stream<List<rust_models.RoomSummary>> Function() _watchRooms;
  final Future<List<rust_models.RoomMessage>> Function(String roomId)
  _loadMessages;
  final Stream<List<rust_models.RoomMessage>> Function(String roomId)
  _watchMessages;
  final Future<void> Function(String roomId, String body) _sendMessage;

  /// Creates the service with its Matrix operations.
  const MatrixRoomService({
    required this._loadRooms,
    required this._watchRooms,
    required this._loadMessages,
    required this._watchMessages,
    required this._sendMessage,
  });

  /// Loads rooms and maps Rust models to application models.
  @override
  Future<List<RoomSummary>> joinedRooms() async =>
      (await _guard(_loadRooms)).map(_mapRoomSummary).toList();

  /// Streams rooms and maps each Rust update to application models.
  @override
  Stream<List<RoomSummary>> watchJoinedRooms() =>
      _guardStream(_watchRooms())
          .map((rooms) => rooms.map(_mapRoomSummary).toList());

  /// Loads messages for [roomId] and maps them to application models.
  @override
  Future<List<RoomMessage>> roomMessages(String roomId) =>
      _guard(() => _loadMessages(roomId))
          .then((messages) => messages.map(_mapRoomMessage).toList());

  /// Streams message updates for [roomId] as application models.
  @override
  Stream<List<RoomMessage>> watchRoomMessages(String roomId) =>
      _guardStream(_watchMessages(roomId))
          .map((messages) => messages.map(_mapRoomMessage).toList());

  /// Sends [body] to [roomId].
  @override
  Future<void> sendMessage(String roomId, String body) =>
      _guard(() => _sendMessage(roomId, body));

  RoomSummary _mapRoomSummary(rust_models.RoomSummary room) =>
      RoomSummary(roomId: room.roomId, name: room.name);

  RoomMessage _mapRoomMessage(rust_models.RoomMessage message) => RoomMessage(
    eventId: message.eventId,
    sender: message.sender,
    body: message.body,
    timestamp: message.timestamp,
  );

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on String catch (errorJson) {
      throw MatrixServiceException.fromJson(errorJson);
    }
  }

  Stream<T> _guardStream<T>(Stream<T> stream) => stream.transform(
    StreamTransformer<T, T>.fromHandlers(
      handleError: (error, stackTrace, sink) {
        if (error is String) {
          sink.addError(MatrixServiceException.fromJson(error), stackTrace);
        } else {
          sink.addError(error, stackTrace);
        }
      },
    ),
  );
}

/// Provides the Matrix-backed room service.
final matrixRoomServiceProvider = Provider<RoomService>(
  (ref) => MatrixRoomService(
    loadRooms: rust_rooms.joinedRooms,
    watchRooms: rust_rooms.watchJoinedRooms,
    loadMessages: (roomId) => rust_messages.getRoomMessages(roomId: roomId),
    watchMessages: (roomId) => rust_messages.watchRoomMessages(roomId: roomId),
    sendMessage: (roomId, body) =>
        rust_messages.sendMessage(roomId: roomId, body: body),
  ),
);
