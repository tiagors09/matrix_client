import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/features/rooms/models/room_summary.dart';
import 'package:matrix_client/features/rooms/repositories/matrix_room_repository.dart';
import 'package:matrix_client/features/rooms/viewmodels/rooms_view_model_impl.dart';
import 'package:matrix_client/features/rooms/widgets/rooms_list_tile.dart';

/// Displays joined rooms from the repository's live room stream.
class RoomsList extends ConsumerWidget {
  /// Called when a room is selected.
  final ValueChanged<RoomSummary> onRoomSelected;

  /// Creates a room list that reports selection through [onRoomSelected].
  const RoomsList({super.key, required this.onRoomSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(joinedRoomsStreamProvider);
    final selectedRoomId = ref.watch(roomsViewModelProvider);

    return rooms.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            error.toString(),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('Você ainda não participa de salas.'));
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final room = items[index];
            return RoomsListTile(
              room: room,
              selected: room.roomId == selectedRoomId,
              onTap: () => onRoomSelected(room),
            );
          },
        );
      },
    );
  }
}
