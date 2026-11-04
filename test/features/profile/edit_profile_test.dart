import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/features/profile/domain/body_metrics.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/scroll_to.dart';

void main() {
  Finder field(String label) => find.widgetWithText(TextFormField, label);

  Future<void> openEdit(WidgetTester tester) async {
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();
  }

  testWidgets('saves nickname, bio and body data in metric units', (
    tester,
  ) async {
    final backend = await pumpApp(
      tester,
      preferences: {'settings.weightUnit': 'pounds'},
    );
    await openEdit(tester);

    await tester.enterText(field('Nickname'), 'Iron.Max');
    await tester.enterText(field('About me'), 'Squats on Mondays');
    await tester.enterText(field('Weight, lb'), '220,5');
    await tester.enterText(field('Height, cm'), '181');
    await scrollToAndTap(tester, find.widgetWithText(FilledButton, 'Save'));

    expect(find.text('Profile saved.'), findsOneWidget);
    expect(find.text('iron.max'), findsOneWidget);
    expect(find.text('Squats on Mondays'), findsOneWidget);
    final body = backend.profiles.bodies[testUser.uid]!;
    expect(body.weightKg, closeTo(100.0, 0.05));
    expect(body.heightCm, 181);
  });

  testWidgets('rejects values outside the allowed range', (tester) async {
    final backend = await pumpApp(tester);
    await openEdit(tester);

    await tester.enterText(field('Weight, kg'), '5');
    await scrollToAndTap(tester, find.widgetWithText(FilledButton, 'Save'));

    expect(find.text('Enter a number from 30 to 300'), findsOneWidget);
    expect(backend.profiles.bodies, isEmpty);
  });

  testWidgets('profile tab shows private body data in chosen units', (
    tester,
  ) async {
    final backend = await pumpApp(
      tester,
      preferences: {'settings.lengthUnit': 'inches'},
    );
    await backend.profiles.saveBodyMetrics(
      testUser.uid,
      const BodyMetrics(weightKg: 80, heightCm: 182.88),
    );
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('72 in'), 100);

    expect(find.text('80 kg'), findsOneWidget);
    expect(find.text('72 in'), findsOneWidget);
  });
}
