import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/core/errors/app_failure.dart';
import 'package:good_gym/core/errors/result.dart';
import 'package:good_gym/features/profile/data/firestore_user_profile_repository.dart';
import 'package:good_gym/features/profile/domain/body_metrics.dart';
import 'package:good_gym/features/profile/domain/user_profile.dart';
import 'package:good_gym/features/profile/domain/user_role.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreUserProfileRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreUserProfileRepository(firestore);
  });

  test('creates profile and reserves the nickname', () async {
    final result = await repository.createProfile(
      uid: 'u1',
      nickname: 'iron',
      role: UserRole.student,
    );

    expect(result, isA<Success<void>>());
    final nickname = await firestore.doc('nicknames/iron').get();
    expect(nickname.data(), {'uid': 'u1'});
    expect(
      await repository.watchProfile('u1').first,
      const UserProfile(uid: 'u1', nickname: 'iron', role: UserRole.student),
    );
  });

  test('rejects a nickname owned by another user', () async {
    await firestore.doc('nicknames/iron').set({'uid': 'someone-else'});

    final result = await repository.createProfile(
      uid: 'u1',
      nickname: 'iron',
      role: UserRole.athlete,
    );

    expect((result as Failure<void>).failure, AppFailure.nicknameTaken);
    expect((await firestore.doc('users/u1').get()).exists, isFalse);
  });

  test('never assigns the moderator role from the client', () async {
    final created = await repository.createProfile(
      uid: 'u1',
      nickname: 'iron',
      role: UserRole.moderator,
    );
    final updated = await repository.updateRole(
      uid: 'u1',
      role: UserRole.moderator,
    );

    expect((created as Failure<void>).failure, AppFailure.invalidInput);
    expect((updated as Failure<void>).failure, AppFailure.invalidInput);
  });

  test('changes role of an existing profile', () async {
    await repository.createProfile(
      uid: 'u1',
      nickname: 'iron',
      role: UserRole.athlete,
    );

    await repository.updateRole(uid: 'u1', role: UserRole.student);

    final profile = await repository.watchProfile('u1').first;
    expect(profile?.role, UserRole.student);
  });

  test('returns null for a user without profile', () async {
    expect(await repository.watchProfile('missing').first, isNull);
  });

  group('stage 2', () {
    setUp(
      () => repository.createProfile(
        uid: 'u1',
        nickname: 'iron',
        role: UserRole.athlete,
      ),
    );

    test('nickname change moves the reservation', () async {
      expect((await firestore.doc('users/u1').get()).data(), isNotNull);
      final profile = (await repository.watchProfile('u1').first)!;

      final result = await repository.updateProfile(
        profile.copyWith(nickname: 'steel', bio: 'Deadlifts'),
      );

      expect(result, isA<Success<void>>());
      expect((await firestore.doc('nicknames/iron').get()).exists, isFalse);
      expect((await firestore.doc('nicknames/steel').get()).data(), {
        'uid': 'u1',
      });
      final updated = await repository.watchProfile('u1').first;
      expect(updated?.nickname, 'steel');
      expect(updated?.bio, 'Deadlifts');
    });

    test('nickname change to a taken nickname is rejected', () async {
      await firestore.doc('nicknames/steel').set({'uid': 'other'});
      final profile = (await repository.watchProfile('u1').first)!;

      final result = await repository.updateProfile(
        profile.copyWith(nickname: 'steel'),
      );

      expect((result as Failure<void>).failure, AppFailure.nicknameTaken);
      expect((await repository.watchProfile('u1').first)?.nickname, 'iron');
    });

    test('body data is stored privately and read back', () async {
      await repository.saveBodyMetrics(
        'u1',
        const BodyMetrics(weightKg: 82.5, heightCm: 180),
      );

      expect(
        await repository.watchBodyMetrics('u1').first,
        const BodyMetrics(weightKg: 82.5, heightCm: 180),
      );
      expect((await firestore.doc('users/u1/private/body').get()).data(), {
        'weightKg': 82.5,
        'heightCm': 180,
      });
    });

    test('export contains profile and body as JSON-safe values', () async {
      await repository.saveBodyMetrics('u1', const BodyMetrics(weightKg: 80));

      final result = await repository.exportData('u1');

      final data = (result as Success<Map<String, Object?>>).value;
      final profile = data['profile']! as Map<String, Object?>;
      expect(profile['nickname'], 'iron');
      expect(profile['createdAt'], isA<String>());
      expect((data['body']! as Map<String, Object?>)['weightKg'], 80);
    });

    test('delete removes profile, nickname and body', () async {
      await repository.saveBodyMetrics('u1', const BodyMetrics(weightKg: 80));

      final result = await repository.deleteAllData('u1');

      expect(result, isA<Success<void>>());
      for (final path in [
        'users/u1',
        'nicknames/iron',
        'users/u1/private/body',
      ]) {
        expect((await firestore.doc(path).get()).exists, isFalse, reason: path);
      }
    });
  });
}
