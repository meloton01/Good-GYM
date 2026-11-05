import 'package:cloud_firestore/cloud_firestore.dart';

import '../errors/result.dart';
import '../pagination/paged_result.dart';
import 'firestore_failure_mapper.dart';

/// Читает страницу запроса после документа [cursor] из [collection]; повреждённые документы пропускаются.
Future<Result<PagedResult<T>>> fetchFirestorePage<T extends Object>(
  Query<Map<String, dynamic>> query,
  CollectionReference<Map<String, dynamic>> collection, {
  required String? cursor,
  required int limit,
  required T? Function(QueryDocumentSnapshot<Map<String, dynamic>> doc) map,
}) async {
  try {
    var request = query;
    if (cursor != null) {
      request = request.startAfterDocument(await collection.doc(cursor).get());
    }
    final snapshot = await request.limit(limit).get();
    return Success(
      PagedResult(
        items: [for (final doc in snapshot.docs) ?map(doc)],
        nextCursor: snapshot.docs.length == limit
            ? snapshot.docs.last.id
            : null,
      ),
    );
  } on FirebaseException catch (error) {
    return Failure(mapFirestoreFailure(error), cause: error);
  }
}
