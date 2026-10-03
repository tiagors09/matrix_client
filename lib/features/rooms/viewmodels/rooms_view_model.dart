/// UI commands and selection state for the rooms and conversation view.
abstract interface class RoomsViewModel {
  /// ID of the currently selected room, or `null` when none is selected.
  String? get selectedRoomId;

  /// Selects a room to display its conversation.
  void selectRoom(String roomId);

  /// Sends a message to the selected room.
  Future<void> sendMessage(String body);
}
