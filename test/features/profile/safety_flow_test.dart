import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/scroll_to.dart';
import '../rating/rating_test_data.dart';

/// Открывает рекорд пользователя lifter из очереди модератора.
Future<TestBackend> openForeignRecord(
  WidgetTester tester, {
  double textScale = 1,
}) async {
  final backend = await pumpApp(
    tester,
    profiles: const [moderator],
    textScale: textScale,
  );
  await seedRecord(backend.firestore, 'rec1');
  await openRating(tester, tab: 'Review');
  await tester.tap(find.textContaining('lifter'));
  await tester.pumpAndSettle();
  return backend;
}

/// Открывает меню жалоб в шапке и выбирает пункт [item].
Future<void> chooseMenuItem(WidgetTester tester, String item) async {
  await tester.tap(find.byIcon(Icons.more_vert));
  await tester.pumpAndSettle();
  await tester.tap(find.text(item));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('user reports a record with a reason', (tester) async {
    final backend = await openForeignRecord(tester);

    await chooseMenuItem(tester, 'Report record');
    final send = find.widgetWithText(TextButton, 'Send');
    expect(tester.widget<TextButton>(send).onPressed, isNull);
    await tester.tap(find.text('Fake result'));
    await tester.enterText(find.byType(TextField), 'plates are empty');
    await tester.pumpAndSettle();
    await tester.tap(send);
    await tester.pumpAndSettle();

    expect(find.text('Report sent. A moderator will review it.'), findsOne);
    final report = await backend.firestore
        .doc('reports/uid-1_record_rec1')
        .get();
    expect(report.data(), containsPair('reason', 'cheating'));
    expect(report.data(), containsPair('targetUid', 'u2'));
    expect(report.data(), containsPair('comment', 'plates are empty'));
  });

  testWidgets('blocked user history is hidden until unblocked', (tester) async {
    final backend = await openForeignRecord(tester);

    await chooseMenuItem(tester, 'Block');
    expect(find.text('Block lifter?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Block'));
    await tester.pumpAndSettle();
    final block = await backend.firestore.doc('users/uid-1/blocks/u2').get();
    expect(block.exists, isTrue);

    await tester.tap(find.text('lifter'));
    await tester.pumpAndSettle();
    expect(find.text('You blocked this user'), findsOneWidget);

    await scrollToAndTap(
      tester,
      find.widgetWithText(OutlinedButton, 'Unblock'),
    );
    expect(find.text('You blocked this user'), findsNothing);
  });

  testWidgets('blocked users are listed in settings and can be unblocked', (
    tester,
  ) async {
    final backend = await pumpApp(tester);
    await backend.firestore.doc('users/uid-1/blocks/u2').set({
      'nickname': 'lifter',
      'createdAt': DateTime(2026, 11, 2),
    });
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await scrollToAndTap(tester, find.text('Blocked users'));
    expect(find.text('lifter'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Unblock'));
    await tester.pumpAndSettle();
    expect(find.text('No blocked users'), findsOneWidget);
  });

  testWidgets('report and block dialogs fit a narrow screen with 2x font', (
    tester,
  ) async {
    await openForeignRecord(tester, textScale: 2);

    await chooseMenuItem(tester, 'Report record');
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await chooseMenuItem(tester, 'Block');
    expect(tester.takeException(), isNull);
    await tester.tap(find.widgetWithText(TextButton, 'Block'));
    await tester.pumpAndSettle();
    await scrollToAndTap(tester, find.text('lifter'));
    expect(find.text('You blocked this user'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
