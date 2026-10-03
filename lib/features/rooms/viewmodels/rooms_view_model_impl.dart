import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/features/rooms/repositories/matrix_room_repository.dart';
import 'package:matrix_client/features/rooms/repositories/room_repository.dart';
import 'package:matrix_client/features/rooms/viewmodels/rooms_view_model.dart';

/// Riverpod notifier implementation for [RoomsViewModel].
class RoomsViewModelImpl extends Notifier<String?> implements RoomsViewModel {
  RoomRepository get _repository => ref.read(roomRepositoryProvider);

  @override
  String? build() => null;

  @override
  String? get selectedRoomId => state;

  @override
  void selectRoom(String roomId) {
    state = roomId;
  }

  @override
  Future<void> sendMessage(String body) async {
    final roomId = state;
    if (roomId == null) {
      throw StateError('Selecione uma sala antes de enviar uma mensagem.');
    }
    await _repository.sendMessage(roomId, body);
  }
}

/// Provides the selected room ID as state and exposes view model commands.
final roomsViewModelProvider = NotifierProvider<RoomsViewModelImpl, String?>(
  RoomsViewModelImpl.new,
);

/// Exposes view model commands through the Riverpod-independent interface.
final roomsViewModelCommandsProvider = Provider<RoomsViewModel>(
  (ref) => ref.read(roomsViewModelProvider.notifier),
);
