import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/record_badge.dart';
import 'record_fields.dart';

/// Значки пользователя по таблицам за всё время: строки таблиц публичны, история может быть скрыта.
Future<Set<RecordBadge>> fetchRecordBadges(
  FirebaseFirestore firestore,
  String uid,
) async {
  final leaderboard = firestore.collection(RecordFields.leaderboard);
  final own = await leaderboard
      .where(RecordFields.uid, isEqualTo: uid)
      .where(RecordFields.period, isEqualTo: _allTime)
      .get();
  if (own.docs.isEmpty) {
    return const {};
  }
  final badges = {RecordBadge.firstRecord};
  final gymEntries = own.docs.where(
    (doc) => doc.data()[RecordFields.scope] != RecordFields.globalScope,
  );
  for (final entry in gymEntries) {
    final data = entry.data();
    final top = await leaderboard
        .where(
          RecordFields.exerciseId,
          isEqualTo: data[RecordFields.exerciseId],
        )
        .where(RecordFields.period, isEqualTo: _allTime)
        .where(RecordFields.scope, isEqualTo: data[RecordFields.scope])
        .orderBy(RecordFields.bestWeightKg, descending: true)
        .limit(_topSize)
        .get();
    if (top.docs.any((doc) => doc.data()[RecordFields.uid] == uid)) {
      badges.add(RecordBadge.gymTop3);
      break;
    }
  }
  return badges;
}

const String _allTime = 'all';
const int _topSize = 3;
