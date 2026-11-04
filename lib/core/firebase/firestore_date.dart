import 'package:cloud_firestore/cloud_firestore.dart';

/// Читает дату из Timestamp Firestore, DateTime или миллисекунд; null для других значений.
DateTime? readFirestoreDate(Object? value) {
  return switch (value) {
    Timestamp() => value.toDate(),
    DateTime() => value,
    int() => DateTime.fromMillisecondsSinceEpoch(value),
    _ => null,
  };
}
