import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/delete_in_chunks.dart';
import '../../../core/firebase/json_safe.dart';
import 'workout_collections.dart';
import 'workout_fields.dart';

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
  await deleteInChunks(
    firestore,
    plan.collection(WorkoutFields.commentsCollection),
  );
  await plan.delete();
}
