import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  const tabsByLanguage = {
    'en': ['Home', 'Rating', 'Workouts', 'Profile', 'Settings'],
    'uk': ['Головна', 'Рейтинг', 'Тренування', 'Профіль', 'Налаштування'],
    'ru': ['Главная', 'Рейтинг', 'Тренировки', 'Профиль', 'Настройки'],
  };

  for (final entry in tabsByLanguage.entries) {
    testWidgets('no overflow on 360x640 with 2x font, ${entry.key}', (
      tester,
    ) async {
      await pumpApp(
        tester,
        textScale: 2,
        preferences: {'settings.languageCode': entry.key},
      );
      for (final label in entry.value) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}
