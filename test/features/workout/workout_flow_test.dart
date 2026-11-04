import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/scroll_to.dart';

void main() {
  /// Открывает вкладку тренировок через нижнюю навигацию.
  Future<void> openWorkouts(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Workouts'),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Составляет план «Legs» с одним подходом приседа 5 × 100 кг.
  Future<void> planSquatWorkout(WidgetTester tester) async {
    await tester.tap(find.text('New workout'));
    await tester.pumpAndSettle();
    expect(find.text('Workout plan'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Legs');
    await tester.tap(find.text('Add exercise'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Search'), 'squ');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Set 1'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Reps'), '5');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Weight, kg'),
      '100',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('5 × 100 kg · rest 1:30'), findsOneWidget);
  }

  testWidgets('plan, train, then see history, records and chart', (
    tester,
  ) async {
    final backend = await pumpApp(tester);
    await openWorkouts(tester);
    expect(find.text('No workouts yet'), findsOneWidget);

    await planSquatWorkout(tester);
    await scrollToAndTap(tester, find.widgetWithText(FilledButton, 'Start'));
    expect(find.widgetWithText(AppBar, 'Legs'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(find.text('Rest'), findsOneWidget);
    expect(backend.restAlarm.scheduledAt, isNotNull);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(backend.restAlarm.scheduledAt, isNull);

    await scrollToAndTap(tester, find.text('Finish workout'));
    expect(find.widgetWithText(AppBar, 'Workout'), findsOneWidget);
    expect(find.text('5 × 100 kg'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Legs'), findsOneWidget);
    expect(find.text('Resume workout'), findsNothing);

    await tester.tap(find.text('Records'));
    await tester.pumpAndSettle();
    expect(find.text('1RM ≈ 116.7 kg · heaviest 100 kg'), findsOneWidget);
    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();
    expect(find.byType(LineChart), findsOneWidget);
    expect(find.text('Based on 1 workout'), findsOneWidget);
  });

  testWidgets('finishing without completed sets keeps the workout', (
    tester,
  ) async {
    await pumpApp(tester);
    await openWorkouts(tester);
    await planSquatWorkout(tester);
    await scrollToAndTap(tester, find.widgetWithText(FilledButton, 'Start'));

    await scrollToAndTap(tester, find.text('Finish workout'));
    await tester.tap(find.widgetWithText(TextButton, 'Finish workout'));
    await tester.pumpAndSettle();
    expect(
      find.text('Mark at least one completed set to save the workout.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(AppBar, 'Legs'), findsOneWidget);
  });

  testWidgets('plan saved as template starts from the templates tab', (
    tester,
  ) async {
    await pumpApp(tester);
    await openWorkouts(tester);
    await planSquatWorkout(tester);
    await scrollToAndTap(tester, find.text('Save as template'));
    expect(find.text('Template saved.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Templates'));
    await tester.pumpAndSettle();
    expect(find.text('Legs'), findsOneWidget);

    await tester.tap(find.byTooltip('Start'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Legs'), findsOneWidget);
    expect(find.text('Exercise 1 of 1'), findsOneWidget);
  });

  testWidgets('workout in progress is restored after restart', (tester) async {
    await pumpApp(
      tester,
      preferences: {
        'workout.active':
            '{"id":"w1","ownerId":"uid-1","title":"Pull","note":"",'
            '"startedAt":1793800000000,"exerciseIds":["pull_up"],'
            '"exercises":[{"exerciseId":"pull_up","muscleGroup":"back",'
            '"sets":[{"reps":8,"restSeconds":60,"completed":false}]}]}',
      },
    );
    await openWorkouts(tester);
    await tester.tap(find.text('Resume workout'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Pull'), findsOneWidget);
    expect(find.text('Pull-up'), findsOneWidget);
    expect(find.text('8 reps · rest 1:00'), findsOneWidget);
  });
}
