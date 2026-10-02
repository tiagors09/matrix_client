import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/src/rust/api/messages.dart' as rust_messages;
import 'package:matrix_client/src/rust/api/models.dart';
import 'package:matrix_client/src/rust/api/rooms.dart' as rust_rooms;

class MatrixServiceException implements Exception {
  final int? statusCode;
  final String message;

  const MatrixServiceException({this.statusCode, required this.message});

  factory MatrixServiceException.from(Object error) {
    if (error is MatrixServiceException) return error;
    final message = error.toString();
    final explicitStatus = RegExp(r'\b([45]\d{2})\b')
        .firstMatch(message)
        ?.group(1);
    final matrixErrcode = RegExp(r'\bM_[A-Z0-9_]+\b')
        .firstMatch(message)
        ?.group(0);
    final matrixStatus = switch (matrixErrcode) {
      'M_UNAUTHORIZED' => 401,
      'M_FORBIDDEN' => 403,
      'M_NOT_FOUND' => 404,
      'M_INVALID_PARAM' => 400,
      'M_LIMIT_EXCEEDED' => 429,
      _ => null,
    };
    return MatrixServiceException(
      statusCode: explicitStatus == null
          ? matrixStatus
          : int.parse(explicitStatus),
      message: message,
    );
  }

  @override
  String toString() => statusCode == null
      ? message
      : 'Matrix request failed ($statusCode): $message';
}

class MatrixRoomService {
  final Future<List<RoomSummary>> Function() _loadRooms;
  final Stream<List<RoomSummary>> Function() _watchRooms;
  final Future<List<RoomMessage>> Function(String roomId) _loadMessages;
  final Stream<List<RoomMessage>> Function(String roomId) _watchMessages;
  final Future<void> Function(String roomId, String body) _sendMessage;

  MatrixRoomService({
    Future<List<RoomSummary>> Function()? loadRooms,
    Stream<List<RoomSummary>> Function()? watchRooms,
    Future<List<RoomMessage>> Function(String roomId)? loadMessages,
    Stream<List<RoomMessage>> Function(String roomId)? watchMessages,
    Future<void> Function(String roomId, String body)? sendMessage,
  }) : _loadRooms = loadRooms ?? rust_rooms.joinedRooms,
       _watchRooms = watchRooms ?? rust_rooms.watchJoinedRooms,
       _loadMessages =
           loadMessages ??
           ((roomId) => rust_messages.getRoomMessages(roomId: roomId)),
       _watchMessages =
           watchMessages ??
           ((roomId) => rust_messages.watchRoomMessages(roomId: roomId)),
       _sendMessage =
           sendMessage ??
           ((roomId, body) =>
               rust_messages.sendMessage(roomId: roomId, body: body));

  Future<List<RoomSummary>> joinedRooms() => _guard(_loadRooms);

  Stream<List<RoomSummary>> watchJoinedRooms() => _guardStream(_watchRooms());

  Future<List<RoomMessage>> roomMessages(String roomId) =>
      _guard(() => _loadMessages(roomId));

  Stream<List<RoomMessage>> watchRoomMessages(String roomId) =>
      _guardStream(_watchMessages(roomId));

  Future<void> sendMessage(String roomId, String body) =>
      _guard(() => _sendMessage(roomId, body));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on Object catch (error) {
      throw MatrixServiceException.from(error);
    }
  }

  Stream<T> _guardStream<T>(Stream<T> stream) => stream.transform(
    StreamTransformer<T, T>.fromHandlers(
      handleError: (error, stackTrace, sink) {
        sink.addError(MatrixServiceException.from(error), stackTrace);
      },
    ),
  );
}

final matrixRoomServiceProvider = Provider<MatrixRoomService>(
  (ref) => MatrixRoomService(),
);

final joinedRoomsStreamProvider = StreamProvider<List<RoomSummary>>(
  (ref) => ref.watch(matrixRoomServiceProvider).watchJoinedRooms(),
);

final roomMessagesStreamProvider =
    StreamProvider.family<List<RoomMessage>, String>((ref, roomId) {
      return ref.watch(matrixRoomServiceProvider).watchRoomMessages(roomId);
    });
