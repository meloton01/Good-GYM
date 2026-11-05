import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/leaderboard_metric.dart';
import '../domain/leaderboard_query.dart';
import 'record_fields.dart';

/// Запрос строк таблицы по фильтру на дату [now]; индексы описаны в firestore.indexes.json.
Query<Map<String, dynamic>> leaderboardRequest(
  CollectionReference<Map<String, dynamic>> collection,
  LeaderboardQuery query,
  DateTime now,
) {
  var request = collection
      .where(RecordFields.exerciseId, isEqualTo: query.exercise.id)
      .where(RecordFields.period, isEqualTo: query.period.keyAt(now))
      .where(
        RecordFields.scope,
        isEqualTo: query.gymId ?? RecordFields.globalScope,
      );
  final weightClass = query.weightClass;
  final sex = query.sex;
  if (weightClass != null) {
    request = request.where(
      RecordFields.weightClass,
      isEqualTo: weightClass.id,
    );
  } else if (sex != null) {
    request = request.where(RecordFields.sex, isEqualTo: sex.name);
  }
  return request.orderBy(
    query.metric == LeaderboardMetric.maxWeight
        ? RecordFields.bestWeightKg
        : RecordFields.bestE1rmKg,
    descending: true,
  );
}
