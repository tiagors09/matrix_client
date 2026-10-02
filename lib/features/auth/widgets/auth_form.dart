import 'package:flutter/material.dart';

class AuthForm extends StatelessWidget {
  final Function(String, String, String)? onLogin;

  const new({super.key, this.onLogin});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: SizedBox(
        width: size.width * .3,
        height: size.width * .3,

        child: Column(
          spacing: 16,
          mainAxisAlignment: .center,
          mainAxisSize: .max,
          children: [
            Text(
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
                  mainAxisSize: .max,
                  mainAxisAlignment: .spaceAround,
                  spacing: 32,
                  children: [
                    Form(
                      child: Column(
                        spacing: 8,
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .center,
                        mainAxisSize: .max,
                        children: [
                          TextFormField(),
                          TextFormField(),
                          TextFormField(),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onLogin != null
                            ? () => onLogin!('', '', '')
                            : null,
                        child: Text('Entrar'),
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
