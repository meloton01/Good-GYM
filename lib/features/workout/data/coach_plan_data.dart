import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/json_safe.dart';
import 'workout_collections.dart';
import 'workout_fields.dart';

/// Размер пачки удаления; меньше лимита батча Firestore в 500 операций.
const int _deleteChunk = 400;

/// Читает планы ученика с комментариями в виде, пригодном для JSON.
Future<List<Map<String, Object?>>> exportPlanData(
  FirebaseFirestore firestore,
  String athleteId,
) async {
  final plans = await firestore.plans(athleteId).get();
  final result = <Map<String, Object?>>[];
  for (final doc in plans.docs) {
    final comments = await doc.reference
        .collection(WorkoutFields.commentsCollection)
        .get();
    result.add({
      'id': doc.id,
      ...?jsonSafe(doc.data()) as Map<String, dynamic>?,
      WorkoutFields.commentsCollection: [
        for (final comment in comments.docs) jsonSafe(comment.data()),
      ],
    });
  }
  return result;
}

/// Удаляет все планы ученика с комментариями.
Future<void> deletePlanData(
  FirebaseFirestore firestore,
  String athleteId,
) async {
  final plans = await firestore.plans(athleteId).get();
  for (final doc in plans.docs) {
    await deletePlanWithComments(firestore, doc.reference);
  }
}

/// Удаляет комментарии плана пачками, затем сам план.
Future<void> deletePlanWithComments(
  FirebaseFirestore firestore,
  DocumentReference<Map<String, dynamic>> plan,
) async {
  final comments = plan.collection(WorkoutFields.commentsCollection);
  while (true) {
    final snapshot = await comments.limit(_deleteChunk).get();
    if (snapshot.docs.isEmpty) {
      break;
    }
    final batch = firestore.batch();
    for (final comment in snapshot.docs) {
      batch.delete(comment.reference);
    }
    await batch.commit();
  }
  await plan.delete();
}
