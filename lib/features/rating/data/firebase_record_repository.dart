import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/constants/app_limits.dart';
import '../../../core/errors/result.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/firebase/firestore_page.dart';
import '../../../core/firebase/json_safe.dart';
import '../../../core/pagination/paged_result.dart';
import '../domain/gym_record.dart';
import '../domain/leaderboard_entry.dart';
import '../domain/leaderboard_query.dart';
import '../domain/record_badge.dart';
import '../domain/record_repository.dart';
import '../domain/record_submission.dart';
import '../domain/video_upload.dart';
import 'leaderboard_request.dart';
import 'record_badges_query.dart';
import 'record_fields.dart';
import 'record_functions_client.dart';
import 'record_mapper.dart';
import 'storage_video_upload.dart';

/// Рекорды: чтение из Firestore, загрузка видео в Storage, изменения через Cloud Functions.
class FirebaseRecordRepository implements RecordRepository {
  /// Создаёт репозиторий; Functions и Storage создаются при первом обращении.
  FirebaseRecordRepository(
    this._firestore, {
    required FirebaseFunctions Function() functions,
    required FirebaseStorage Function() storage,
  }) : _functions = RecordFunctionsClient(functions),
       _storageFactory = storage;

  final FirebaseFirestore _firestore;
  final RecordFunctionsClient _functions;
  final FirebaseStorage Function() _storageFactory;

  CollectionReference<Map<String, dynamic>> get _records =>
      _firestore.collection(RecordFields.records);

  /// Страница таблицы по фильтру, лучшие сверху.
  @override
  Future<Result<PagedResult<LeaderboardEntry>>> fetchLeaderboard(
    LeaderboardQuery query, {
    required DateTime now,
    String? cursor,
    int limit = AppLimits.pageSize,
  }) {
    final collection = _firestore.collection(RecordFields.leaderboard);
    return fetchFirestorePage(
      leaderboardRequest(collection, query, now),
      collection,
      cursor: cursor,
      limit: limit,
      map: (doc) => RecordMapper.entryFromMap(doc.data()),
    );
  }

  /// Поток своих рекордов, новые сверху.
  @override
  Stream<List<GymRecord>> watchMyRecords(
    String uid, {
    int limit = AppLimits.pageSize,
  }) {
    return _records
        .where(RecordFields.uid, isEqualTo: uid)
        .orderBy(RecordFields.createdAt, descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RecordMapper.recordFromMap(doc.id, doc.data()))
              .nonNulls
              .toList(),
        );
  }

  /// Поток одного рекорда.
  @override
  Stream<GymRecord?> watchRecord(String recordId) {
    return _records.doc(recordId).snapshots().map((doc) {
      final data = doc.data();
      return data == null ? null : RecordMapper.recordFromMap(doc.id, data);
    });
  }

  /// Страница одобренных рекордов пользователя; правила проверяют его видимость рекордов.
  @override
  Future<Result<PagedResult<GymRecord>>> fetchApprovedRecords(
    String uid, {
    String? cursor,
    int limit = AppLimits.pageSize,
  }) {
    return fetchFirestorePage(
      _records
          .where(RecordFields.uid, isEqualTo: uid)
          .where(RecordFields.status, isEqualTo: 'approved')
          .orderBy(RecordFields.performedAt, descending: true),
      _records,
      cursor: cursor,
      limit: limit,
      map: (doc) => RecordMapper.recordFromMap(doc.id, doc.data()),
    );
  }

  /// Значки по строкам таблиц за всё время.
  @override
  Future<Result<Set<RecordBadge>>> fetchBadges(String uid) async {
    try {
      return Success(await fetchRecordBadges(_firestore, uid));
    } on FirebaseException catch (error) {
      return Failure(mapFirestoreFailure(error), cause: error);
    }
  }

  /// Запускает загрузку файла в records/{uid}/{uploadId}.mp4.
  @override
  VideoUpload uploadVideo({
    required String uid,
    required String uploadId,
    required String localPath,
  }) {
    final task = _storageFactory()
        .ref(RecordFields.videoPathFor(uid, uploadId))
        .putFile(
          File(localPath),
          SettableMetadata(contentType: RecordFields.videoContentType),
        );
    return StorageVideoUpload(task);
  }

  /// Создаёт рекорд через функцию; e1rm и категорию считает сервер.
  @override
  Future<Result<void>> submitRecord(RecordSubmission submission) {
    return _functions.call(RecordFields.submitRecord, {
      RecordFields.uploadId: submission.uploadId,
      RecordFields.exerciseId: submission.exercise.id,
      RecordFields.weightKg: submission.weightKg,
      RecordFields.reps: submission.reps,
      RecordFields.performedAt: submission.performedAt.millisecondsSinceEpoch,
      RecordFields.sex: submission.sex.name,
      RecordFields.bodyWeightKg: submission.bodyWeightKg,
    });
  }

  /// Возвращает отклонённый рекорд на проверку.
  @override
  Future<Result<void>> appealRecord(String recordId) => _functions.call(
    RecordFields.appealRecord,
    {RecordFields.recordId: recordId},
  );

  /// Очередь модератора, старые заявки сверху.
  @override
  Future<Result<PagedResult<GymRecord>>> fetchModerationQueue({
    String? cursor,
    int limit = AppLimits.pageSize,
  }) {
    return fetchFirestorePage(
      _records
          .where(RecordFields.status, isEqualTo: 'pending')
          .orderBy(RecordFields.createdAt),
      _records,
      cursor: cursor,
      limit: limit,
      map: (doc) => RecordMapper.recordFromMap(doc.id, doc.data()),
    );
  }

  /// Одобряет рекорд через функцию.
  @override
  Future<Result<void>> approveRecord(String recordId) => _functions.call(
    RecordFields.approveRecord,
    {RecordFields.recordId: recordId},
  );

  /// Отклоняет рекорд через функцию.
  @override
  Future<Result<void>> rejectRecord(
    String recordId, {
    required String reason,
  }) => _functions.call(RecordFields.rejectRecord, {
    RecordFields.recordId: recordId,
    RecordFields.reason: reason,
  });

  /// Подписанная ссылка на видео от функции.
  @override
  Future<Result<Uri>> videoUrl(String recordId) =>
      _functions.videoUrl(recordId);

  /// Все свои рекорды для выгрузки.
  @override
  Future<Result<List<Map<String, Object?>>>> exportData(String uid) async {
    try {
      final snapshot = await _records
          .where(RecordFields.uid, isEqualTo: uid)
          .get();
      return Success([
        for (final doc in snapshot.docs)
          {'id': doc.id, ...?jsonSafe(doc.data()) as Map<String, dynamic>?},
      ]);
    } on FirebaseException catch (error) {
      return Failure(mapFirestoreFailure(error), cause: error);
    }
  }

  /// Удаляет данные рейтинга через функцию: у клиента нет прав на записи рекордов.
  @override
  Future<Result<void>> deleteAllData() =>
      _functions.call(RecordFields.deleteRecordData, const <String, Object>{});
}
