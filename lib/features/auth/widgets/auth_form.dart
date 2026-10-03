import 'package:flutter/material.dart';
import 'package:matrix_client/features/auth/widgets/homeserver_field.dart';
import 'package:matrix_client/features/auth/widgets/password_field.dart';
import 'package:matrix_client/features/auth/widgets/username_field.dart';
import 'package:matrix_client/features/auth/widgets/validation/auth_field_validation.dart';

/// Collects homeserver credentials and forwards submission to the view model.
class AuthForm extends StatefulWidget {
  /// Invoked with the form's homeserver, username, and password.
  final Future<void> Function(
    String homeserverUrl,
    String username,
    String password,
  )
  onLogin;

  /// Whether a login request is in progress.
  final bool isLoading;

  /// Optional message to display when authentication fails.
  final String? errorMessage;

  /// Toggle password visibility
  final bool obscureText;

  /// Called when the password visibility control is pressed.
  final VoidCallback onTogglePasswordVisibility;

  /// Creates a credential form that forwards submissions to [onLogin].
  const AuthForm({
    super.key,
    required this.onLogin,
    required this.isLoading,
    required this.onTogglePasswordVisibility,
    this.errorMessage,
    this.obscureText = true,
  });

  /// Creates the mutable state that stores form field values.
  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> with AuthFieldValidation {
  final _form = GlobalKey<FormState>();

  String _homeserverUrl = 'matrix.org';
  String _username = '';
  String _password = '';

  void _handleTogglePasswordVisibility() {
    widget.onTogglePasswordVisibility();
  }

  Future<void> _submit() async {
    final isValid = _form.currentState?.validate() ?? false;
    if (!isValid) return;

    _form.currentState?.save();

    await widget.onLogin(_homeserverUrl.trim(), _username.trim(), _password);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Center(
      child: SizedBox(
        width: size.width * .3,
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Text(
              'Matrix Client',
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  spacing: 32,
                  children: [
                    Form(
                      key: _form,
                      child: Column(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          HomeserverField(
                            initialValue: _homeserverUrl,
                            validator: validateHomeserver,
                            onSaved: (value) => _homeserverUrl = value ?? '',
                          ),
                          UsernameField(
                            validator: validateUsername,
                            onSaved: (value) => _username = value ?? '',
                          ),
                          PasswordField(
                            validator: validatePassword,
                            onSaved: (value) => _password = value ?? '',
                            obscureText: widget.obscureText,
                            onToggleVisibility: _handleTogglePasswordVisibility,
                          ),
                        ],
                      ),
                    ),
                    if (widget.errorMessage != null)
                      Text(
                        widget.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: widget.isLoading ? null : _submit,
                        child: widget.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Entrar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
