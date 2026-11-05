import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/core/errors/app_failure.dart';
import 'package:good_gym/core/errors/result.dart';
import 'package:good_gym/features/profile/domain/user_profile.dart';
import 'package:good_gym/features/profile/domain/user_role.dart';
import 'package:good_gym/features/workout/data/firestore_coach_link_repository.dart';
import 'package:good_gym/features/workout/data/firestore_coach_plan_repository.dart';
import 'package:good_gym/features/workout/domain/built_in_exercises.dart';
import 'package:good_gym/features/workout/domain/coach_limits.dart';
import 'package:good_gym/features/workout/domain/coach_link.dart';
import 'package:good_gym/features/workout/domain/coach_link_status.dart';
import 'package:good_gym/features/workout/domain/coach_plan.dart';
import 'package:good_gym/features/workout/domain/plan_status.dart';
import 'package:good_gym/features/workout/domain/workout_exercise.dart';
import 'package:good_gym/features/workout/domain/workout_set.dart';

const coach = UserProfile(
  uid: 'c1',
  nickname: 'coach.one',
  role: UserRole.coach,
);
const student = UserProfile(
  uid: 's1',
  nickname: 'student.one',
  role: UserRole.student,
);

Matcher failsWith(AppFailure failure) =>
    isA<Failure<void>>().having((f) => f.failure, 'failure', failure);

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreCoachLinkRepository links;
  late FirestoreCoachPlanRepository plans;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    links = FirestoreCoachLinkRepository(firestore);
    plans = FirestoreCoachPlanRepository(firestore);
    for (final user in [coach, student]) {
      await firestore.doc('nicknames/${user.nickname}').set({'uid': user.uid});
    }
  });

  Future<CoachLink> onlyLink(String uid, {required bool asCoach}) async =>
      (await links.watchLinks(uid, asCoach: asCoach).first).single;

  Future<Map<String, dynamic>?> data(String path) async =>
      (await firestore.doc(path).get()).data();

  test('invite needs an existing nickname and is not duplicated', () async {
    expect(
      await links.invite(me: coach, nickname: 'nobody'),
      failsWith(AppFailure.userNotFound),
    );
    expect(
      await links.invite(me: coach, nickname: student.nickname),
      isA<Success<void>>(),
    );
    expect(
      await links.invite(me: student, nickname: coach.nickname),
      failsWith(AppFailure.alreadyInvited),
    );
    final link = await onlyLink(student.uid, asCoach: false);
    expect(link.status, CoachLinkStatus.pending);
    expect(link.isIncomingFor(student.uid), isTrue);
    expect(link.partnerNickname(student.uid), coach.nickname);
  });

  test('athlete without coach or student role cannot invite', () async {
    const athlete = UserProfile(
      uid: 'a1',
      nickname: 'plain.one',
      role: UserRole.athlete,
    );
    expect(
      await links.invite(me: athlete, nickname: coach.nickname),
      failsWith(AppFailure.inviteUnavailable),
    );
  });

  test('accept locks the student and counts; end releases both', () async {
    await links.invite(me: student, nickname: coach.nickname);
    final pending = await onlyLink(coach.uid, asCoach: true);
    expect(await links.accept(pending), isA<Success<void>>());

    final active = await onlyLink(coach.uid, asCoach: true);
    expect(active.status, CoachLinkStatus.active);
    expect((await data('studentCoach/s1'))?['coachId'], coach.uid);
    expect((await data('coachStudents/c1'))?['count'], 1);
    expect(
      await links.invite(me: coach, nickname: student.nickname),
      failsWith(AppFailure.alreadyLinked),
    );

    expect(await links.end(active), isA<Success<void>>());
    expect(
      (await onlyLink(student.uid, asCoach: false)).status,
      CoachLinkStatus.ended,
    );
    expect(await data('studentCoach/s1'), isNull);
    expect((await data('coachStudents/c1'))?['count'], 0);

    expect(
      await links.invite(me: coach, nickname: student.nickname),
      isA<Success<void>>(),
    );
    expect(
      (await onlyLink(coach.uid, asCoach: true)).status,
      CoachLinkStatus.pending,
    );
  });

  test(
    'accept is refused when the coach has the maximum of students',
    () async {
      await firestore.doc('coachStudents/c1').set({
        'count': CoachLimits.maxStudents,
      });
      await links.invite(me: coach, nickname: student.nickname);
      final pending = await onlyLink(student.uid, asCoach: false);
      expect(
        await links.accept(pending),
        failsWith(AppFailure.coachLimitReached),
      );
      expect(await data('studentCoach/s1'), isNull);
    },
  );

  test('declined invite disappears for both sides', () async {
    await links.invite(me: coach, nickname: student.nickname);
    await links.remove(await onlyLink(student.uid, asCoach: false));
    expect(await links.watchLinks(coach.uid, asCoach: true).first, isEmpty);
  });

  test('plan is created, completed, commented and deleted', () async {
    final plan = CoachPlan(
      id: 'p1',
      coachId: coach.uid,
      athleteId: student.uid,
      coachNickname: coach.nickname,
      title: 'Legs',
      exercises: [
        const WorkoutExercise(
          exercise: BuiltInExercises.squat,
          sets: [WorkoutSet(reps: 5, restSeconds: 90, weightKg: 100)],
        ),
      ],
    );
    expect(await plans.createPlan(plan), isA<Success<void>>());
    expect(
      (await plans.watchCoachPlans(coach.uid, student.uid).first).single.title,
      'Legs',
    );
    expect(
      await plans.createPlan(plan.copyWith(id: 'p2', exercises: const [])),
      failsWith(AppFailure.invalidInput),
    );

    await plans.completePlan(student.uid, 'p1', 'w1');
    final done = await plans.watchPlan(student.uid, 'p1').first;
    expect(done?.status, PlanStatus.completed);
    expect(done?.workoutId, 'w1');

    expect(
      await plans.addComment(
        student.uid,
        'p1',
        authorId: student.uid,
        authorNickname: student.nickname,
        text: '  Done  ',
      ),
      isA<Success<void>>(),
    );
    expect(
      await plans.addComment(
        student.uid,
        'p1',
        authorId: student.uid,
        authorNickname: student.nickname,
        text: '   ',
      ),
      failsWith(AppFailure.invalidInput),
    );
    final comments = await plans.watchComments(student.uid, 'p1').first;
    expect(comments.single.text, 'Done');

    final exported = await plans.exportData(student.uid);
    expect((exported as Success).value, hasLength(1));

    expect(await plans.deletePlan(student.uid, 'p1'), isA<Success<void>>());
    expect(await plans.watchPlan(student.uid, 'p1').first, isNull);
    expect(
      (await firestore.collection('users/s1/plans/p1/comments').get()).docs,
      isEmpty,
    );
  });

  test('account deletion ends active links and removes them', () async {
    await links.invite(me: coach, nickname: student.nickname);
    await links.accept(await onlyLink(student.uid, asCoach: false));
    expect(await links.deleteAllData(student.uid), isA<Success<void>>());
    expect(await links.watchLinks(coach.uid, asCoach: true).first, isEmpty);
    expect(await data('studentCoach/s1'), isNull);
    expect((await data('coachStudents/c1'))?['count'], 0);
  });
}
