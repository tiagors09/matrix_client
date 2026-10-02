import 'package:flutter/material.dart';
import 'package:matrix_client/matrix_client_app.dart';
import 'package:matrix_client/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MatrixClientApp());
}
