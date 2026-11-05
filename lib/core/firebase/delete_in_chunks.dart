import 'package:cloud_firestore/cloud_firestore.dart';

/// Размер пачки удаления; меньше лимита батча Firestore в 500 операций.
const int _deleteChunk = 400;

/// Удаляет все документы запроса пачками, пока они не закончатся.
Future<void> deleteInChunks(
  FirebaseFirestore firestore,
  Query<Map<String, dynamic>> query,
) async {
  while (true) {
    final snapshot = await query.limit(_deleteChunk).get();
    if (snapshot.docs.isEmpty) {
      return;
    }
    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
