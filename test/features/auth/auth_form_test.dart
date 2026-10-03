import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_client/features/auth/widgets/auth_form.dart';

void main() {
  testWidgets('shows a Matrix user ID based on the current homeserver', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthForm(
            onLogin: (homeserverUrl, username, password) async {},
            onTogglePasswordVisibility: () {},
            isLoading: false,
          ),
        ),
      ),
    );

    InputDecoration usernameDecoration() => tester
        .widgetList<InputDecorator>(find.byType(InputDecorator))
        .elementAt(1)
        .decoration;

    expect(usernameDecoration().prefixText, '@');
    expect(usernameDecoration().suffixText, ':matrix.org');

    await tester.enterText(
      find.byType(TextFormField).first,
      'chat.example.org:8448',
    );
    await tester.pump();

    expect(usernameDecoration().suffixText, ':chat.example.org:8448');
  });

  testWidgets('disables credential fields and password toggle while loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthForm(
            onLogin: (homeserverUrl, username, password) async {},
            onTogglePasswordVisibility: () {},
            isLoading: true,
          ),
        ),
      ),
    );

    final fields = tester.widgetList<TextField>(find.byType(TextField));
    expect(fields, hasLength(3));
    expect(fields.every((field) => field.enabled == false), isTrue);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );
  });
}
