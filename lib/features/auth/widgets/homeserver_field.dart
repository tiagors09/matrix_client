import 'package:flutter/material.dart';

/// Text field for entering the Matrix homeserver host.
class HomeserverField extends StatelessWidget {
  /// Initial value displayed in the field.
  final String initialValue;

  /// Whether the field accepts input.
  final bool enabled;

  /// Validation callback for the field.
  final FormFieldValidator<String>? validator;

  /// Callback used to save the field value.
  final FormFieldSetter<String>? onSaved;

  /// Creates a homeserver field.
  const HomeserverField({
    super.key,
    this.initialValue = '',
    this.enabled = true,
    this.validator,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      enabled: enabled,
      decoration: const InputDecoration(
        prefixText: 'https://',
        labelText: 'Homeserver URL',
        border: OutlineInputBorder(),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}
