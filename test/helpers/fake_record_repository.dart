import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:good_gym/core/constants/app_limits.dart';
import 'package:good_gym/core/errors/app_failure.dart';
import 'package:good_gym/core/errors/result.dart';
import 'package:good_gym/core/pagination/paged_result.dart';
import 'package:good_gym/features/profile/domain/user_profile.dart';
import 'package:good_gym/features/rating/data/firebase_record_repository.dart';
import 'package:good_gym/features/rating/domain/gym_record.dart';
import 'package:good_gym/features/rating/domain/leaderboard_entry.dart';
import 'package:good_gym/features/rating/domain/leaderboard_period.dart';
import 'package:good_gym/features/rating/domain/leaderboard_query.dart';
import 'package:good_gym/features/rating/domain/record_badge.dart';
import 'package:good_gym/features/rating/domain/record_repository.dart';
import 'package:good_gym/features/rating/domain/record_submission.dart';
import 'package:good_gym/features/rating/domain/video_upload.dart';

/// Рекорды поверх Firestore в памяти; запись повторяет поведение Cloud Functions.
class FakeRecordRepository implements RecordRepository {
  /// Создаёт репозиторий от имени [currentUid]; ник и зал берутся из [profileOf].
  FakeRecordRepository(this.firestore, this.currentUid, this.profileOf)
    : _reads = FirebaseRecordRepository(
        firestore,
        functions: () => throw UnimplementedError(),
        storage: () => throw UnimplementedError(),
      );

  final FakeFirebaseFirestore firestore;
  final String Function() currentUid;
  final UserProfile? Function(String uid) profileOf;
  final FirebaseRecordRepository _reads;

  /// Последняя запущенная загрузка видео.
  FakeVideoUpload? lastUpload;

  CollectionReference<Map<String, dynamic>> get _records =>
      firestore.collection('records');

  /// Таблица из Firestore в памяти.
  @override
  Future<Result<PagedResult<LeaderboardEntry>>> fetchLeaderboard(
    LeaderboardQuery query, {
    required DateTime now,
    String? cursor,
    int limit = AppLimits.pageSize,
  }) => _reads.fetchLeaderboard(query, now: now, cursor: cursor, limit: limit);

  /// Свои рекорды из Firestore в памяти.
  @override
  Stream<List<GymRecord>> watchMyRecords(
    String uid, {
    int limit = AppLimits.pageSize,
  }) => _reads.watchMyRecords(uid, limit: limit);

  /// Рекорд из Firestore в памяти.
  @override
  Stream<GymRecord?> watchRecord(String recordId) =>
      _reads.watchRecord(recordId);

  /// История из Firestore в памяти.
  @override
  Future<Result<PagedResult<GymRecord>>> fetchApprovedRecords(
    String uid, {
    String? cursor,
    int limit = AppLimits.pageSize,
  }) => _reads.fetchApprovedRecords(uid, cursor: cursor, limit: limit);

  /// Значки из Firestore в памяти.
  @override
  Future<Result<Set<RecordBadge>>> fetchBadges(String uid) =>
      _reads.fetchBadges(uid);

  /// Загрузка, которой управляет тест.
  @override
  VideoUpload uploadVideo({
    required String uid,
    required String uploadId,
    required String localPath,
  }) => lastUpload = FakeVideoUpload();

  /// Создаёт рекорд на проверке, как submitRecord.
  @override
  Future<Result<void>> submitRecord(RecordSubmission submission) async {
    final uid = currentUid();
    final profile = profileOf(uid);
    final gymId = profile?.gymId;
    if (profile == null || gymId == null) {
      return const Failure(AppFailure.noGym);
    }
    await _records.doc(submission.uploadId).set({
      'uid': uid,
      'nickname': profile.nickname,
      'gymId': gymId,
      'gymName': profile.gymName,
      'exerciseId': submission.exercise.id,
      'weightKg': submission.weightKg,
      'reps': submission.reps,
      'e1rmKg': submission.weightKg * (1 + submission.reps / 30),
      'sex': submission.sex.name,
      'weightClass': submission.sex.name == 'male' ? 'm83' : 'f63',
      'status': 'pending',
      'appealed': false,
      'performedAt': submission.performedAt,
      'createdAt': DateTime.now(),
    });
    return const Success(null);
  }

  /// Возвращает отклонённый рекорд на проверку.
  @override
  Future<Result<void>> appealRecord(String recordId) async {
    await _records.doc(recordId).update({
      'status': 'pending',
      'appealed': true,
    });
    return const Success(null);
  }

  /// Очередь из Firestore в памяти.
  @override
  Future<Result<PagedResult<GymRecord>>> fetchModerationQueue({
    String? cursor,
    int limit = AppLimits.pageSize,
  }) => _reads.fetchModerationQueue(cursor: cursor, limit: limit);

  /// Одобряет рекорд и пишет строки таблиц за всё время, как approveRecord.
  @override
  Future<Result<void>> approveRecord(String recordId) async {
    final record = (await _records.doc(recordId).get()).data()!;
    if (record['uid'] == currentUid()) {
      return const Failure(AppFailure.ownRecord);
    }
    await _records.doc(recordId).update({
      'status': 'approved',
      'moderatorId': currentUid(),
    });
    final period = LeaderboardPeriod.allTime.keyAt(DateTime.now());
    for (final scope in ['global', record['gymId']]) {
      await firestore
          .doc(
            'leaderboard/${record['exerciseId']}_${period}_${scope}_${record['uid']}',
          )
          .set({
            'exerciseId': record['exerciseId'],
            'period': period,
            'scope': scope,
            'uid': record['uid'],
            'nickname': record['nickname'],
            'gymName': record['gymName'],
            'bestWeightKg': record['weightKg'],
            'bestWeightRecordId': recordId,
            'bestE1rmKg': record['e1rmKg'],
            'bestE1rmRecordId': recordId,
            'sex': record['sex'],
            'weightClass': record['weightClass'],
          });
    }
    return const Success(null);
  }

  /// Отклоняет рекорд с причиной.
  @override
  Future<Result<void>> rejectRecord(
    String recordId, {
    required String reason,
  }) async {
    await _records.doc(recordId).update({
      'status': 'rejected',
      'rejectionReason': reason,
      'moderatorId': currentUid(),
    });
    return const Success(null);
  }

  /// Ссылка на видео недоступна в тестах.
  @override
  Future<Result<Uri>> videoUrl(String recordId) async =>
      const Failure(AppFailure.network);

  /// Свои рекорды из Firestore в памяти.
  @override
  Future<Result<List<Map<String, Object?>>>> exportData(String uid) =>
      _reads.exportData(uid);

  /// Удаляет рекорды и строки таблиц текущего пользователя.
  @override
  Future<Result<void>> deleteAllData() async {
    final uid = currentUid();
    for (final name in ['records', 'leaderboard']) {
      final docs = await firestore
          .collection(name)
          .where('uid', isEqualTo: uid)
          .get();
      for (final doc in docs.docs) {
        await doc.reference.delete();
      }
    }
    return const Success(null);
  }
}

/// Загрузка видео, которую тест завершает вызовом [complete].
class FakeVideoUpload implements VideoUpload {
  final _progress = StreamController<double>.broadcast();
  final _done = Completer<Result<void>>();

  /// Прогресс, который отправляет тест.
  @override
  Stream<double> get progress => _progress.stream;

  /// Итог, который задаёт тест.
  @override
  Future<Result<void>> get done => _done.future;

  /// Сообщает прогресс [value].
  void report(double value) => _progress.add(value);

  /// Завершает загрузку результатом [result].
  void complete([Result<void> result = const Success(null)]) {
    if (!_done.isCompleted) {
      _done.complete(result);
    }
  }

  /// Пауза ничего не делает.
  @override
  Future<void> pause() async {}

  /// Продолжение ничего не делает.
  @override
  Future<void> resume() async {}

  /// Отмена завершает загрузку отменой.
  @override
  Future<void> cancel() async => complete(const Failure(AppFailure.cancelled));
}
