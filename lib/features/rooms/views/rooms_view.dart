import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/features/auth/viewsmodels/auth_view_model_impl.dart';
import 'package:matrix_client/features/rooms/models/room_summary.dart';
import 'package:matrix_client/features/rooms/viewmodels/rooms_view_model_impl.dart';
import 'package:matrix_client/features/rooms/widgets/message_composer.dart';
import 'package:matrix_client/features/rooms/widgets/message_list.dart';
import 'package:matrix_client/features/rooms/widgets/no_room_selected.dart';
import 'package:matrix_client/features/rooms/widgets/rooms_list.dart';

/// Displays joined rooms and the selected room's live conversation.
class RoomsView extends ConsumerStatefulWidget {
  const RoomsView({super.key});

  @override
  ConsumerState<RoomsView> createState() => _RoomsViewState();
}

class _RoomsViewState extends ConsumerState<RoomsView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final selectedRoomId = ref.watch(roomsViewModelProvider);
    final roomsViewModel = ref.read(roomsViewModelCommandsProvider);
    final currentUserId = ref.watch(
      authViewModelProvider.select((state) => state.userId),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final showPermanentRoomList = constraints.maxWidth >= 800;
        final roomsList = RoomsList(
          onRoomSelected: (room) =>
              _selectRoom(room, roomsViewModel.selectRoom),
        );

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(selectedRoomId == null ? 'Matrix Client' : 'Conversas'),
          ),
          drawer: showPermanentRoomList
              ? null
              : Drawer(
                  child: SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Salas',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Expanded(child: roomsList),
                      ],
                    ),
                  ),
                ),
          body: Row(
            children: [
              if (showPermanentRoomList)
                SizedBox(
                  width: 320,
                  child: Drawer(
                    child: SafeArea(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Salas',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Expanded(child: roomsList),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: selectedRoomId == null
                    ? const NoRoomSelected()
                    : Column(
                        children: [
                          Expanded(
                            child: MessageList(
                              roomId: selectedRoomId,
                              currentUserId: currentUserId,
                            ),
                          ),
                          MessageComposer(onSend: roomsViewModel.sendMessage),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectRoom(RoomSummary room, void Function(String) selectRoom) {
    selectRoom(room.roomId);
    _scaffoldKey.currentState?.closeDrawer();
  }
}
