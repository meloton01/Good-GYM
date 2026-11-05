import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/features/profile/domain/user_role.dart';
import 'package:good_gym/features/rating/domain/sex.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/scroll_to.dart';
import 'rating_test_data.dart';

void main() {
  testWidgets('submitted record waits for review and stays out of the table', (
    tester,
  ) async {
    final backend = await pumpApp(tester, profiles: const [athleteWithGym]);
    await openRating(tester);
    expect(find.text('No records yet'), findsOneWidget);

    await tester.tap(find.text('Upload record'));
    await tester.pumpAndSettle();
    expect(find.text('Send for review'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Weight, kg'),
      '140',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Reps'), '3');
    await scrollToAndTap(tester, find.byType(DropdownButtonFormField<Sex>));
    await tester.tap(find.text('Men').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Body weight, kg'),
      '82',
    );

    await scrollToAndTap(tester, find.text('Choose video'));
    expect(find.text('Uploading: 0%'), findsOneWidget);
    backend.records.lastUpload!.report(0.5);
    await tester.pumpAndSettle();
    expect(find.text('Uploading: 50%'), findsOneWidget);
    backend.records.lastUpload!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Video uploaded'), findsOneWidget);

    await scrollToAndTap(tester, find.text('Send for review'));
    expect(find.text('Record sent for review'), findsOneWidget);
    expect(find.text('No records yet'), findsOneWidget);

    await tester.tap(find.text('My records'));
    await tester.pumpAndSettle();
    expect(find.text('Under review'), findsOneWidget);
    expect(find.text('Squat'), findsOneWidget);
  });

  testWidgets('moderator approves a record and it enters the table', (
    tester,
  ) async {
    final backend = await pumpApp(tester, profiles: const [moderator]);
    await seedRecord(backend.firestore, 'rec1');
    await seedRecord(
      backend.firestore,
      'own1',
      uid: 'uid-1',
      nickname: 'gym.moderator',
    );
    await openRating(tester, tab: 'Review');
    expect(find.textContaining('lifter'), findsOneWidget);

    await tester.tap(find.textContaining('lifter'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Video requirements'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await scrollToAndTap(tester, find.text('Approve'));
    expect(find.text('Record approved'), findsOneWidget);
    expect(find.text('Approved'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Table'));
    await tester.pumpAndSettle();
    expect(find.textContaining('lifter'), findsOneWidget);
    expect(find.text('140 kg'), findsOneWidget);
  });

  testWidgets('moderator cannot review own record', (tester) async {
    final backend = await pumpApp(tester, profiles: const [moderator]);
    await seedRecord(
      backend.firestore,
      'own1',
      uid: 'uid-1',
      nickname: 'gym.moderator',
    );
    await openRating(tester, tab: 'My records');
    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('This is your record. Another moderator will review it.'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Approve'), findsNothing);
  });

  testWidgets('author appeals a rejection once', (tester) async {
    final backend = await pumpApp(tester, profiles: const [athleteWithGym]);
    await seedRecord(
      backend.firestore,
      'rej1',
      uid: 'uid-1',
      status: 'rejected',
      extra: {'rejectionReason': 'Plates are not visible'},
    );
    await openRating(tester, tab: 'My records');
    expect(find.text('Rejected'), findsOneWidget);
    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();
    expect(find.text('Plates are not visible'), findsOneWidget);

    await scrollToAndTap(tester, find.widgetWithText(FilledButton, 'Appeal'));
    await tester.tap(find.widgetWithText(TextButton, 'Appeal'));
    await tester.pumpAndSettle();
    expect(find.text('Appeal sent'), findsOneWidget);
    expect(find.text('Appeal under review'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Appeal'), findsNothing);
  });

  testWidgets('without a gym the gym table and submission ask to choose one', (
    tester,
  ) async {
    await pumpApp(tester);
    await openRating(tester);
    expect(find.text('All gyms'), findsOneWidget);
    expect(find.text('No records yet'), findsOneWidget);

    await tester.tap(find.text('All gyms'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My gym'));
    await tester.pumpAndSettle();
    expect(find.text('No gym chosen'), findsOneWidget);

    await tester.tap(find.text('Upload record'));
    await tester.pumpAndSettle();
    expect(find.text('No gym chosen'), findsOneWidget);
  });

  testWidgets('rating screens fit a narrow screen with large text', (
    tester,
  ) async {
    final backend = await pumpApp(
      tester,
      textScale: 2,
      profiles: [moderator.copyWith(role: UserRole.moderator)],
    );
    await seedRecord(backend.firestore, 'rec1');
    await openRating(tester, tab: 'Review');
    await tester.tap(find.textContaining('lifter'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload record'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Send for review'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Rating').first, warnIfMissed: false);
  });
}
