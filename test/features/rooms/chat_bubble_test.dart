import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_client/features/rooms/models/room_message.dart';
import 'package:matrix_client/features/rooms/widgets/chat_bubble.dart';

void main() {
  group('ChatBubble', () {
    const message = RoomMessage(
      eventId: r'$event:matrix.org',
      sender: '@alice:matrix.org',
      body: 'Hello',
      timestamp: 100,
    );

    testWidgets('aligns my messages to the right', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ChatBubble(message: message, isMine: true)),
        ),
      );

      expect(
        tester.widget<Align>(find.byType(Align)).alignment,
        Alignment.centerRight,
      );
    });

    testWidgets('aligns received messages to the left', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ChatBubble(message: message, isMine: false)),
        ),
      );

      expect(
        tester.widget<Align>(find.byType(Align)).alignment,
        Alignment.centerLeft,
      );
      expect(find.text(message.sender), findsOneWidget);
    });
  });
}
