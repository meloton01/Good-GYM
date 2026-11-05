import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/features/rating/data/record_mapper.dart';
import 'package:good_gym/features/rating/domain/gym_record.dart';
import 'package:good_gym/features/rating/domain/rating_exercise.dart';
import 'package:good_gym/features/rating/domain/record_status.dart';
import 'package:good_gym/features/rating/domain/sex.dart';

void main() {
  final pending = GymRecord(
    id: 'r1',
    uid: 'author',
    nickname: 'lifter',
    gymName: 'Iron Temple',
    exercise: RatingExercise.squat,
    weightKg: 140,
    reps: 3,
    e1rmKg: 154,
    sex: Sex.male,
    weightClassId: 'm83',
    status: RecordStatus.pending,
    performedAt: DateTime.utc(2026, 11, 2),
  );

  test('only a pending record of another user can be reviewed', () {
    expect(pending.isReviewableBy('moderator'), isTrue);
    expect(pending.isReviewableBy('author'), isFalse);
    for (final status in [RecordStatus.approved, RecordStatus.rejected]) {
      expect(
        pending.copyWith(status: status).isReviewableBy('moderator'),
        isFalse,
      );
    }
  });

  test('appeal is possible once and only after a rejection', () {
    final rejected = pending.copyWith(status: RecordStatus.rejected);
    expect(rejected.canAppeal, isTrue);
    expect(rejected.copyWith(appealed: true).canAppeal, isFalse);
    expect(pending.canAppeal, isFalse);
    expect(pending.copyWith(status: RecordStatus.approved).canAppeal, isFalse);
  });

  test('appealed record goes back to the queue', () {
    final appealed = pending.copyWith(appealed: true);
    expect(appealed.isReviewableBy('moderator'), isTrue);
    expect(appealed.canAppeal, isFalse);
  });

  test('every stored status is read, unknown ones are skipped', () {
    Map<String, dynamic> stored(String status) => {
      'uid': 'author',
      'nickname': 'lifter',
      'gymName': 'Iron Temple',
      'exerciseId': 'squat',
      'weightKg': 140,
      'reps': 3,
      'e1rmKg': 154,
      'sex': 'male',
      'weightClass': 'm83',
      'status': status,
      'performedAt': DateTime.utc(2026, 11, 2),
    };
    for (final status in RecordStatus.values) {
      final record = RecordMapper.recordFromMap('r1', stored(status.name));
      expect(record?.status, status);
    }
    expect(RecordMapper.recordFromMap('r1', stored('approved_by_me')), isNull);
  });
}
