import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/features/profile/domain/user_profile.dart';
import 'package:good_gym/features/profile/domain/user_role.dart';

const athleteWithGym = UserProfile(
  uid: 'uid-1',
  nickname: 'iron.athlete',
  role: UserRole.athlete,
  gymId: 'g1',
  gymName: 'Iron Temple',
);

const moderator = UserProfile(
  uid: 'uid-1',
  nickname: 'gym.moderator',
  role: UserRole.moderator,
  gymId: 'g1',
  gymName: 'Iron Temple',
);

/// Кладёт рекорд в формате функции submitRecord.
Future<void> seedRecord(
  FakeFirebaseFirestore firestore,
  String id, {
  String uid = 'u2',
  String nickname = 'lifter',
  String status = 'pending',
  Map<String, Object?> extra = const {},
}) {
  return firestore.doc('records/$id').set({
    'uid': uid,
    'nickname': nickname,
    'gymId': 'g1',
    'gymName': 'Iron Temple',
    'exerciseId': 'squat',
    'weightKg': 140,
    'reps': 3,
    'e1rmKg': 154,
    'sex': 'male',
    'weightClass': 'm83',
    'status': status,
    'appealed': false,
    'performedAt': DateTime(2026, 11, 2),
    'createdAt': DateTime(2026, 11, 2),
    ...extra,
  });
}

/// Открывает вкладку рейтинга и вложенную вкладку [tab], если она задана.
Future<void> openRating(WidgetTester tester, {String? tab}) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Rating'),
    ),
  );
  await tester.pumpAndSettle();
  if (tab != null) {
    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text(tab)),
    );
    await tester.pumpAndSettle();
  }
}
