/// Shared validation rules for the authentication form fields.
mixin AuthFieldValidation {
  /// Ensures a required field contains non-whitespace text.
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  /// Validates the homeserver field.
  String? validateHomeserver(String? value) =>
      validateRequired(value, 'a homeserver URL');

  /// Validates the username field.
  String? validateUsername(String? value) =>
      validateRequired(value, 'a username');

  /// Validates the password field.
  String? validatePassword(String? value) =>
      validateRequired(value, 'a password');
}
