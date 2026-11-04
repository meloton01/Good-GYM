import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/json_safe.dart';
import 'workout_collections.dart';

/// Размер пачки удаления; меньше лимита батча Firestore в 500 операций.
const int _deleteChunk = 400;

/// Читает все тренировочные коллекции пользователя в виде, пригодном для JSON.
Future<Map<String, Object?>> exportWorkoutData(
  FirebaseFirestore firestore,
  String uid,
) async {
  final result = <String, Object?>{};
  for (final MapEntry(:key, :value) in firestore.workoutData(uid).entries) {
    final snapshot = await value.get();
    result[key] = [
      for (final doc in snapshot.docs)
        {'id': doc.id, ...?jsonSafe(doc.data()) as Map<String, dynamic>?},
    ];
  }
  return result;
}

/// Удаляет все тренировочные коллекции пользователя пачками.
Future<void> deleteWorkoutData(FirebaseFirestore firestore, String uid) async {
  for (final collection in firestore.workoutData(uid).values) {
    while (true) {
      final snapshot = await collection.limit(_deleteChunk).get();
      if (snapshot.docs.isEmpty) {
        break;
      }
      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
