import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/features/rooms/services/matrix_room_service.dart';

class RoomsViewModel extends Notifier<String?> {
  MatrixRoomService get _service => ref.read(matrixRoomServiceProvider);

  @override
  String? build() => null;

  void selectRoom(String roomId) {
    state = roomId;
  }

  Future<void> sendMessage(String body) async {
    final roomId = state;
    if (roomId == null) {
      throw StateError('Selecione uma sala antes de enviar uma mensagem.');
    }
    await _service.sendMessage(roomId, body);
  }
}

final roomsViewModelProvider = NotifierProvider<RoomsViewModel, String?>(
  RoomsViewModel.new,
);
