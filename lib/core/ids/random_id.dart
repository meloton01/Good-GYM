import 'dart:math';

const String _alphabet =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
const int _length = 20;
final Random _random = Random.secure();

/// Случайный id из 20 букв и цифр, как у документов Firestore; нужен до записи на сервер.
String randomId() {
  return String.fromCharCodes(
    List.generate(
      _length,
      (_) => _alphabet.codeUnitAt(_random.nextInt(_alphabet.length)),
    ),
  );
}
