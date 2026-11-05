import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/delete_in_chunks.dart';
import '../../../core/firebase/json_safe.dart';
import 'workout_collections.dart';

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
    await deleteInChunks(firestore, collection);
  }
}
