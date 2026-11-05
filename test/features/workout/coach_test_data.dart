import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:good_gym/features/profile/domain/user_profile.dart';
import 'package:good_gym/features/profile/domain/user_role.dart';
import 'package:good_gym/features/workout/data/firestore_coach_link_repository.dart';
import 'package:good_gym/features/workout/data/firestore_coach_plan_repository.dart';
import 'package:good_gym/features/workout/domain/built_in_exercises.dart';
import 'package:good_gym/features/workout/domain/coach_plan.dart';
import 'package:good_gym/features/workout/domain/workout_exercise.dart';
import 'package:good_gym/features/workout/domain/workout_set.dart';

/// Вошедший пользователь uid-1 в роли ученика.
const studentProfile = UserProfile(
  uid: 'uid-1',
  nickname: 'iron.athlete',
  role: UserRole.student,
);

/// Вошедший пользователь uid-1 в роли тренера.
const coachProfile = UserProfile(
  uid: 'uid-1',
  nickname: 'iron.athlete',
  role: UserRole.coach,
);

/// Тренер другого пользователя.
const otherCoach = UserProfile(
  uid: 'c2',
  nickname: 'coach.two',
  role: UserRole.coach,
);

/// Ученик другого пользователя.
const otherStudent = UserProfile(
  uid: 's2',
  nickname: 'student.two',
  role: UserRole.student,
);

/// Регистрирует ники всех тестовых пользователей.
Future<void> seedNicknames(FakeFirebaseFirestore firestore) async {
  for (final user in [studentProfile, otherCoach, otherStudent]) {
    await firestore.doc('nicknames/${user.nickname}').set({'uid': user.uid});
  }
}

/// Создаёт активную связь [coach] и [athlete].
Future<void> seedActiveLink(
  FakeFirebaseFirestore firestore,
  UserProfile coach,
  UserProfile athlete,
) async {
  final links = FirestoreCoachLinkRepository(firestore);
  await links.invite(me: coach, nickname: athlete.nickname);
  final pending = await links.watchLinks(coach.uid, asCoach: true).first;
  await links.accept(pending.single);
}

/// Назначает ученику [athleteId] план «Legs» с одним подходом приседа.
Future<void> seedPlan(
  FakeFirebaseFirestore firestore,
  UserProfile coach,
  String athleteId,
) {
  return FirestoreCoachPlanRepository(firestore).createPlan(
    CoachPlan(
      id: 'p1',
      coachId: coach.uid,
      athleteId: athleteId,
      coachNickname: coach.nickname,
      title: 'Legs',
      note: 'Keep the back straight during every repetition',
      exercises: [
        const WorkoutExercise(
          exercise: BuiltInExercises.squat,
          sets: [WorkoutSet(reps: 5, restSeconds: 90, weightKg: 100)],
        ),
      ],
    ),
  );
}
