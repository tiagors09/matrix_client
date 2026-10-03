import 'package:flutter/material.dart';
import 'package:matrix_client/features/rooms/models/room_summary.dart';

/// Displays one selectable room in the room list.
class RoomsListTile extends StatelessWidget {
  /// Room represented by this tile.
  final RoomSummary room;

  /// Whether the room is currently selected.
  final bool selected;

  /// Callback invoked when this tile is tapped.
  final VoidCallback onTap;

  /// Creates a selectable tile for [room].
  const RoomsListTile({
    super.key,
    required this.room,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      leading: CircleAvatar(
        child: Text(
          room.name.isNotEmpty ? room.name.characters.first.toUpperCase() : '#',
        ),
      ),
      title: Text(room.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(room.roomId, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}
