import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/coach_link.dart';
import '../domain/coach_link_repository.dart';
import '../domain/coach_plan.dart';
import '../domain/coach_plan_repository.dart';
import '../domain/plan_comment.dart';
import 'firestore_coach_link_repository.dart';
import 'firestore_coach_plan_repository.dart';

/// Репозиторий связей тренер-ученик; в тестах подменяется через overrides.
final coachLinkRepositoryProvider = Provider<CoachLinkRepository>(
  (ref) => FirestoreCoachLinkRepository(FirebaseFirestore.instance),
);

/// Репозиторий планов тренера; в тестах подменяется через overrides.
final coachPlanRepositoryProvider = Provider<CoachPlanRepository>(
  (ref) => FirestoreCoachPlanRepository(FirebaseFirestore.instance),
);

/// Связи пользователя по паре (uid, смотрит ли он как тренер).
final coachLinksProvider =
    StreamProvider.family<List<CoachLink>, (String, bool)>(
      (ref, key) => ref
          .watch(coachLinkRepositoryProvider)
          .watchLinks(key.$1, asCoach: key.$2),
    );

/// Планы ученика по паре (uid ученика, лимит).
final athletePlansProvider =
    StreamProvider.family<List<CoachPlan>, (String, int)>(
      (ref, key) => ref
          .watch(coachPlanRepositoryProvider)
          .watchAthletePlans(key.$1, limit: key.$2),
    );

/// Планы тренера для ученика по тройке (uid тренера, uid ученика, лимит).
final coachPlansProvider =
    StreamProvider.family<List<CoachPlan>, (String, String, int)>(
      (ref, key) => ref
          .watch(coachPlanRepositoryProvider)
          .watchCoachPlans(key.$1, key.$2, limit: key.$3),
    );

/// Один план по паре (uid ученика, id плана).
final coachPlanProvider = StreamProvider.family<CoachPlan?, (String, String)>(
  (ref, key) =>
      ref.watch(coachPlanRepositoryProvider).watchPlan(key.$1, key.$2),
);

/// Комментарии к плану по тройке (uid ученика, id плана, лимит).
final planCommentsProvider =
    StreamProvider.family<List<PlanComment>, (String, String, int)>(
      (ref, key) => ref
          .watch(coachPlanRepositoryProvider)
          .watchComments(key.$1, key.$2, limit: key.$3),
    );
