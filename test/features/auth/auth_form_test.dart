import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_client/features/auth/widgets/auth_form.dart';

void main() {
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
