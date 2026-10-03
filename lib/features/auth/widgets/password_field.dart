import 'package:flutter/material.dart';

/// Obscured text field for entering the Matrix password.
class PasswordField extends StatelessWidget {
  /// Validation callback for the field.
  final FormFieldValidator<String>? validator;

  /// Callback used to save the field value.
  final FormFieldSetter<String>? onSaved;

  /// Creates a password field.
  const PasswordField({super.key, this.validator, this.onSaved});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}
