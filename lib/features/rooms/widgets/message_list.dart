import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_client/features/rooms/models/room_message.dart';
import 'package:matrix_client/features/rooms/repositories/matrix_room_repository.dart';
import 'package:matrix_client/features/rooms/widgets/chat_bubble.dart';

/// Shows the live message stream for a room as a scrolling list of bubbles.
class MessageList extends ConsumerWidget {
  /// Matrix room ID whose message stream should be displayed.
  final String roomId;

  /// Current Matrix user ID, used to distinguish outgoing messages.
  final String? currentUserId;

  /// Creates a message list for [roomId].
  const MessageList({
    super.key,
    required this.roomId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(roomMessagesStreamProvider(roomId));

    return messages.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(error.toString(), textAlign: TextAlign.center),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('Ainda não há mensagens nesta sala.'));
        }
        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final RoomMessage message = items[items.length - 1 - index];
            return ChatBubble(
              key: ValueKey(message.eventId),
              message: message,
              isMine: message.sender == currentUserId,
            );
          },
        );
      },
    );
  }
}
