import 'package:flutter/material.dart';

/// Obscured text field for entering the Matrix password.
class PasswordField extends StatelessWidget {
  /// Validation callback for the field.
  final FormFieldValidator<String>? validator;

  /// Callback used to save the field value.
  final FormFieldSetter<String>? onSaved;

  /// Toggle password visibility
  final bool obscureText;

  /// Callback invoked when the visibility control is pressed.
  final VoidCallback? onToggleVisibility;

  /// Creates a password field.
  const PasswordField({
    super.key,
    this.validator,
    this.onSaved,
    this.obscureText = true,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          tooltip: obscureText ? 'Show password' : 'Hide password',
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
          ),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
      obscureText: obscureText,
    );
  }
}
