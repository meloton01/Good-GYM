import 'package:cloud_firestore/cloud_firestore.dart';

/// Переводит Timestamp и DateTime в строки ISO 8601 на любой глубине, чтобы данные сериализовались в JSON.
Object? jsonSafe(Object? value) {
  return switch (value) {
    Timestamp() => value.toDate().toUtc().toIso8601String(),
    DateTime() => value.toUtc().toIso8601String(),
    Map<String, dynamic>() => value.map(
      (key, item) => MapEntry(key, jsonSafe(item)),
    ),
    List<dynamic>() => value.map(jsonSafe).toList(),
    _ => value,
  };
}
