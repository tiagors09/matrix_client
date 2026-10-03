import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_client/features/auth/widgets/password_field.dart';

void main() {
  testWidgets('toggles password visibility', (tester) async {
    var obscureText = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => PasswordField(
              obscureText: obscureText,
              onToggleVisibility: () {
                setState(() => obscureText = !obscureText);
              },
            ),
          ),
        ),
      ),
    );

    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isTrue,
    );

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isFalse,
    );
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });
}
