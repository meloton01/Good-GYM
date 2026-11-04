import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:good_gym/app/router/app_routes.dart';
import 'package:good_gym/features/auth/domain/auth_user.dart';
import 'package:good_gym/features/profile/presentation/profile_setup_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  const tabsByLanguage = {
    'en': ['Home', 'Rating', 'Workouts', 'Profile', 'Settings'],
    'uk': ['Головна', 'Рейтинг', 'Тренування', 'Профіль', 'Налаштування'],
    'ru': ['Главная', 'Рейтинг', 'Тренировки', 'Профиль', 'Настройки'],
  };

  /// Прокручивает текущий экран до конца и проверяет, что overflow не было.
  Future<void> scrollThrough(WidgetTester tester) async {
    expect(tester.takeException(), isNull);
    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 8; i++) {
      await tester.drag(scrollable, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  }

  for (final entry in tabsByLanguage.entries) {
    testWidgets('profile and settings screens fit 2x font, ${entry.key}', (
      tester,
    ) async {
      await pumpApp(
        tester,
        textScale: 2,
        preferences: {'settings.languageCode': entry.key},
      );
      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      for (final route in [
        '/settings',
        AppRoutes.appearance,
        '/profile',
        AppRoutes.profileEdit,
        AppRoutes.changePassword,
      ]) {
        router.go(route);
        await tester.pumpAndSettle();
        await scrollThrough(tester);
      }
    });

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

    testWidgets('auth screens fit 360x640 with 2x font, ${entry.key}', (
      tester,
    ) async {
      final backend = await pumpApp(
        tester,
        textScale: 2,
        user: null,
        profiles: [],
        preferences: {'settings.languageCode': entry.key},
      );
      expect(tester.takeException(), isNull);

      for (final route in [AppRoutes.signUp, AppRoutes.resetPassword]) {
        unawaited(
          GoRouter.of(tester.element(find.byType(Scaffold).first)).push(route),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      backend.auth.emit(
        const AuthUser(uid: 'u', email: 'u@example.com', usesPassword: true),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      backend.auth.emit(testUser);
      await tester.pumpAndSettle();
      expect(find.byType(ProfileSetupScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
