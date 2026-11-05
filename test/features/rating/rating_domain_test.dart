import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/core/errors/app_failure.dart';
import 'package:good_gym/features/rating/data/functions_failure_mapper.dart';
import 'package:good_gym/features/rating/data/record_mapper.dart';
import 'package:good_gym/features/rating/domain/leaderboard_period.dart';
import 'package:good_gym/features/rating/domain/rating_exercise.dart';
import 'package:good_gym/features/rating/domain/record_status.dart';
import 'package:good_gym/features/rating/domain/sex.dart';
import 'package:good_gym/features/rating/domain/weight_class.dart';

void main() {
  group('period keys match the functions', () {
    test('ISO week belongs to the year of its Thursday', () {
      expect(
        LeaderboardPeriod.week.keyAt(DateTime.utc(2026, 11, 5)),
        'w2026-45',
      );
      expect(LeaderboardPeriod.week.keyAt(DateTime.utc(2027)), 'w2026-53');
      expect(
        LeaderboardPeriod.week.keyAt(DateTime.utc(2025, 12, 29)),
        'w2026-01',
      );
    });

    test('month and all time', () {
      expect(
        LeaderboardPeriod.month.keyAt(DateTime.utc(2026, 11, 5)),
        'm2026-11',
      );
      expect(LeaderboardPeriod.allTime.keyAt(DateTime.utc(2026)), 'all');
    });
  });

  test('weight class ids match the server', () {
    final male = WeightClass.forSex(Sex.male);
    expect(male.first.id, 'm59');
    expect(male.last.id, 'm120plus');
    expect(WeightClass.forSex(Sex.female).last.id, 'f84plus');
    expect(WeightClass.fromId('m83')?.upperKg, 83);
    expect(WeightClass.fromId('x1'), isNull);
  });

  group('record mapper', () {
    final data = <String, dynamic>{
      'uid': 'u1',
      'nickname': 'lifter',
      'gymName': 'Iron Temple',
      'exerciseId': 'bench_press',
      'weightKg': 100,
      'reps': 5,
      'e1rmKg': 116.7,
      'sex': 'female',
      'weightClass': 'f63',
      'status': 'rejected',
      'appealed': false,
      'rejectionReason': 'Plates are not visible',
      'performedAt': DateTime.utc(2026, 11),
    };

    test('reads a record', () {
      final record = RecordMapper.recordFromMap('r1', data)!;
      expect(record.exercise, RatingExercise.benchPress);
      expect(record.weightKg, 100.0);
      expect(record.status, RecordStatus.rejected);
      expect(record.canAppeal, isTrue);
      expect(record.copyWith(appealed: true).canAppeal, isFalse);
    });

    test('skips damaged documents', () {
      expect(
        RecordMapper.recordFromMap('r1', {...data, 'status': 'done'}),
        isNull,
      );
      expect(
        RecordMapper.recordFromMap('r1', {...data, 'exerciseId': 'curl'}),
        isNull,
      );
      expect(RecordMapper.entryFromMap({'uid': 'u1'}), isNull);
    });
  });

  test('function errors map by reason, then by code', () {
    FirebaseFunctionsException error(String code, [String? reason]) =>
        FirebaseFunctionsException(
          code: code,
          message: code,
          details: reason == null ? null : {'reason': reason},
        );
    expect(
      mapFunctionsFailure(error('failed-precondition', 'no-gym')),
      AppFailure.noGym,
    );
    expect(
      mapFunctionsFailure(error('permission-denied', 'own-record')),
      AppFailure.ownRecord,
    );
    expect(
      mapFunctionsFailure(error('failed-precondition', 'appeal-unavailable')),
      AppFailure.appealUnavailable,
    );
    expect(
      mapFunctionsFailure(error('resource-exhausted')),
      AppFailure.tooManyRequests,
    );
    expect(mapFunctionsFailure(error('internal')), AppFailure.unknown);
  });
}
