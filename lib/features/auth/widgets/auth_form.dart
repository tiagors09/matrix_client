import 'dart:developer';

import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final Future<void> Function(
    String homeserverUrl,
    String username,
    String password,
  )?
  onLogin;
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;

  const AuthForm({
    super.key,
    this.onLogin,
    required this.isLoading,
    required this.isAuthenticated,
    this.errorMessage,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _form = GlobalKey<FormState>();

  String _homeserverUrl = 'matrix.org';
  String _username = '';
  String _password = '';

  Future<void> _submit() async {
    final isValid = _form.currentState?.validate() ?? false;
    if (!isValid || widget.onLogin == null) return;

    _form.currentState?.save();

    try {
      await widget.onLogin!(_homeserverUrl.trim(), _username.trim(), _password);
    } finally {}
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
                          TextFormField(
                            initialValue: _homeserverUrl,
                            decoration: const InputDecoration(
                              prefixText: 'https://',
                              labelText: 'Homeserver URL',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a homeserver URL';
                              }
                              log(value);
                              return null;
                            },
                            onSaved: (value) => _homeserverUrl = value ?? '',
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a username';
                              }
                              return null;
                            },
                            onSaved: (value) => _username = value ?? '',
                          ),
                          TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              return null;
                            },
                            onSaved: (value) => _password = value ?? '',
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
                      child: ElevatedButton(
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
