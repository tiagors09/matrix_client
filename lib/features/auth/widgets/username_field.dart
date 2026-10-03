import 'package:flutter/material.dart';

/// Text field for entering the Matrix username.
class UsernameField extends StatelessWidget {
  /// Whether the field accepts input.
  final bool enabled;

  /// Validation callback for the field.
  final FormFieldValidator<String>? validator;

  /// Callback used to save the field value.
  final FormFieldSetter<String>? onSaved;

  /// Creates a username field.
  const UsernameField({
    super.key,
    this.enabled = true,
    this.validator,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      decoration: const InputDecoration(
        labelText: 'Username',
        border: OutlineInputBorder(),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}
