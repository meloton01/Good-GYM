import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/core/errors/result.dart';
import 'package:good_gym/core/pagination/paged_result.dart';
import 'package:good_gym/features/profile/data/firestore_safety_repository.dart';
import 'package:good_gym/features/profile/domain/blocked_user.dart';
import 'package:good_gym/features/profile/domain/report_reason.dart';
import 'package:good_gym/features/profile/domain/user_report.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreSafetyRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreSafetyRepository(firestore);
  });

  test('block and unblock change the blocked flag', () async {
    Future<bool> blocked() =>
        repository.watchIsBlocked(uid: 'u1', otherUid: 'u2').first;
    expect(await blocked(), isFalse);

    await repository.block('u1', const BlockedUser(uid: 'u2', nickname: 'bob'));
    expect(await blocked(), isTrue);
    final block = await firestore.doc('users/u1/blocks/u2').get();
    expect(block.data()?['nickname'], 'bob');

    await repository.unblock(uid: 'u1', otherUid: 'u2');
    expect(await blocked(), isFalse);
  });

  test('blocked users come in pages, newest first', () async {
    for (var index = 0; index < 3; index++) {
      await firestore.doc('users/u1/blocks/b$index').set({
        'nickname': 'user$index',
        'createdAt': DateTime(2026, 1, index + 1),
      });
    }
    final first = await repository.fetchBlocked('u1', limit: 2);
    final page = (first as Success<PagedResult<BlockedUser>>).value;
    expect(page.items.map((user) => user.nickname), ['user2', 'user1']);
    expect(page.hasMore, isTrue);

    final next = await repository.fetchBlocked(
      'u1',
      cursor: page.nextCursor,
      limit: 2,
    );
    final rest = (next as Success<PagedResult<BlockedUser>>).value;
    expect(rest.items.single.nickname, 'user0');
    expect(rest.hasMore, isFalse);
  });

  test(
    'one report per reporter and target, a repeat keeps the first',
    () async {
      const userReport = UserReport(
        reporterId: 'u1',
        targetUid: 'u2',
        reason: ReportReason.spam,
        comment: 'ads in bio',
      );
      const recordReport = UserReport(
        reporterId: 'u1',
        targetUid: 'u2',
        recordId: 'r1',
        reason: ReportReason.cheating,
      );
      expect(userReport.id, 'u1_user_u2');
      expect(recordReport.id, 'u1_record_r1');

      expect(await repository.report(userReport), isA<Success<void>>());
      expect(await repository.report(recordReport), isA<Success<void>>());
      final repeat = userReport.copyWith(reason: ReportReason.abuse);
      expect(await repository.report(repeat), isA<Success<void>>());

      final user = await firestore.doc('reports/u1_user_u2').get();
      expect(user.data(), containsPair('reason', 'spam'));
      expect(user.data(), containsPair('status', 'open'));
      expect(user.data()!.containsKey('recordId'), isFalse);
      final record = await firestore.doc('reports/u1_record_r1').get();
      expect(record.data(), containsPair('recordId', 'r1'));
    },
  );

  test('export and deletion cover blocks and own reports only', () async {
    await repository.block('u1', const BlockedUser(uid: 'u2', nickname: 'bob'));
    await repository.report(
      const UserReport(
        reporterId: 'u1',
        targetUid: 'u2',
        reason: ReportReason.other,
      ),
    );
    await repository.report(
      const UserReport(
        reporterId: 'u3',
        targetUid: 'u1',
        reason: ReportReason.spam,
      ),
    );

    final export = await repository.exportData('u1');
    final data = (export as Success<Map<String, Object?>>).value;
    expect(data['blocks'], hasLength(1));
    expect(data['reports'], hasLength(1));

    expect(await repository.deleteAllData('u1'), isA<Success<void>>());
    final blocks = await firestore.collection('users/u1/blocks').get();
    expect(blocks.docs, isEmpty);
    final reports = await firestore.collection('reports').get();
    expect(reports.docs.single.id, 'u3_user_u1');
  });
}
