import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/core/errors/app_failure.dart';
import 'package:good_gym/core/errors/result.dart';
import 'package:good_gym/features/profile/data/firestore_user_profile_repository.dart';
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
      role: UserRole.coach,
    );

    expect(result, isA<Success<void>>());
    final nickname = await firestore.doc('nicknames/iron').get();
    expect(nickname.data(), {'uid': 'u1'});
    expect(
      await repository.watchProfile('u1').first,
      const UserProfile(uid: 'u1', nickname: 'iron', role: UserRole.coach),
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
}
