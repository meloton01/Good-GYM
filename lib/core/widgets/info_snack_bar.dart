import 'package:flutter/material.dart';

/// Показывает короткое информационное сообщение внизу экрана.
void showInfoSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
