import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/features/workout/data/firestore_coach_link_repository.dart';
import 'package:good_gym/features/workout/data/firestore_coach_plan_repository.dart';
import 'package:good_gym/features/workout/domain/coach_link_status.dart';
import 'package:good_gym/features/workout/domain/plan_status.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/scroll_to.dart';
import 'coach_test_data.dart';

void main() {
  /// Открывает вкладку тренировок и раздел связи с подписью [tab].
  Future<void> openCoachTab(WidgetTester tester, String tab) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Workouts'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(tab));
    await tester.pumpAndSettle();
    await tester.tap(find.text(tab));
    await tester.pumpAndSettle();
  }

  testWidgets('athlete without coach role has no coach tab', (tester) async {
    await pumpApp(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Workouts'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Coach'), findsNothing);
    expect(find.text('Students'), findsNothing);
  });

  testWidgets('student accepts, trains the plan and comments', (tester) async {
    final backend = await pumpApp(tester, profiles: const [studentProfile]);
    await seedNicknames(backend.firestore);
    final links = FirestoreCoachLinkRepository(backend.firestore);
    await links.invite(me: otherCoach, nickname: studentProfile.nickname);
    await openCoachTab(tester, 'Coach');

    expect(find.text('Invites to you'), findsOneWidget);
    expect(find.text('Invites you as a student'), findsOneWidget);
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(find.text('Invites to you'), findsNothing);
    expect(find.text('coach.two'), findsOneWidget);

    await seedPlan(backend.firestore, otherCoach, studentProfile.uid);
    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();
    expect(find.text('Assigned · coach.two'), findsOneWidget);
    await tester.tap(find.text('Legs'));
    await tester.pumpAndSettle();
    expect(find.text('Coach: coach.two'), findsOneWidget);
    expect(find.text('5 × 100 kg · rest 1:30'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Comment'),
      'Knee hurts a bit',
    );
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();
    expect(find.text('Knee hurts a bit'), findsOneWidget);

    await scrollToAndTap(tester, find.widgetWithText(FilledButton, 'Start'));
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await scrollToAndTap(tester, find.text('Finish workout'));
    expect(find.widgetWithText(AppBar, 'Workout'), findsOneWidget);

    final plan = await tester.runAsync(
      () =>
          FirestoreCoachPlanRepository(backend.firestore)
              .watchPlan(studentProfile.uid, 'p1')
              .first,
    );
    expect(plan?.status, PlanStatus.completed);
    expect(plan?.workoutId, isNotNull);
  });

  testWidgets('coach invites, plans for the student and ends the link', (
    tester,
  ) async {
    final backend = await pumpApp(tester, profiles: const [coachProfile]);
    await seedNicknames(backend.firestore);
    await openCoachTab(tester, 'Students');
    expect(find.text('Students: 0 of 50'), findsOneWidget);

    await tester.tap(find.text('Invite student'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nickname'),
      'nobody.here',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Send'));
    await tester.pumpAndSettle();
    expect(
      find.text('No user with this nickname. Check the spelling.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Nickname'),
      otherStudent.nickname,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Send'));
    await tester.pumpAndSettle();
    expect(find.text('Waiting for an answer'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final links = FirestoreCoachLinkRepository(backend.firestore);
    final pending = await tester.runAsync(
      () => links.watchLinks(otherStudent.uid, asCoach: false).first,
    );
    await links.accept(pending!.single);
    await tester.pumpAndSettle();
    expect(find.text('Students: 1 of 50'), findsOneWidget);

    await tester.tap(find.text(otherStudent.nickname));
    await tester.pumpAndSettle();
    expect(find.text('No plans'), findsOneWidget);
    await tester.tap(find.text('New plan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Legs');
    await tester.tap(find.text('Add exercise'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Search'), 'squ');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();
    await scrollToAndTap(tester, find.widgetWithText(FilledButton, 'Save'));
    expect(find.text('Assigned'), findsOneWidget);
    expect(find.text('Legs'), findsOneWidget);

    await tester.tap(find.byTooltip('End link'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'End'));
    await tester.pumpAndSettle();
    expect(find.text('Students: 0 of 50'), findsOneWidget);
    final ended = await tester.runAsync(
      () => links.watchLinks(otherStudent.uid, asCoach: false).first,
    );
    expect(ended!.single.status, CoachLinkStatus.ended);
  });
}
