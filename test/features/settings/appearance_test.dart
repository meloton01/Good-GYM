import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/app/theme/app_colors.dart';
import 'package:good_gym/app/theme/app_palette.dart';
import 'package:good_gym/app/theme/app_radii.dart';
import 'package:good_gym/app/theme/appearance_colors.dart';
import 'package:good_gym/features/settings/domain/accent_id.dart';
import 'package:good_gym/features/settings/domain/corner_style.dart';
import 'package:good_gym/features/settings/domain/palette_id.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/scroll_to.dart';

void main() {
  AppColors colorsOf(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(Scaffold).last))
          .extension<AppColors>()!;

  AppRadii radiiOf(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(Scaffold).last))
          .extension<AppRadii>()!;

  Future<void> openAppearance(WidgetTester tester) async {
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();
  }

  testWidgets('palette, accent and corners apply at once and persist', (
    tester,
  ) async {
    await pumpApp(tester, preferences: {'settings.themeMode': 'dark'});
    await openAppearance(tester);
    expect(colorsOf(tester).accent, AppPalette.yellow);

    await scrollToAndTap(tester, find.text('Graphite & Orange'));
    expect(colorsOf(tester).accent, AppPalette.orange);
    expect(colorsOf(tester).background, AppPalette.graphiteWarm);

    await scrollToAndTap(tester, find.bySemanticsLabel('Pink'));
    expect(colorsOf(tester).accent, AppPalette.pink);

    await scrollToAndTap(tester, find.text('Round'));
    expect(radiiOf(tester), AppRadii.forStyle(CornerStyle.round));

    await pumpApp(
      tester,
      preferences: {
        'settings.themeMode': 'dark',
        'settings.palette': 'graphiteOrange',
        'settings.accent': 'pink',
        'settings.cornerStyle': 'round',
      },
    );
    expect(colorsOf(tester).accent, AppPalette.pink);
    expect(radiiOf(tester), AppRadii.forStyle(CornerStyle.round));
  });

  test('every accent keeps readable content on its fill in both themes', () {
    double luminance(Color color) => color.computeLuminance();
    double contrast(Color a, Color b) {
      final (light, dark) = luminance(a) > luminance(b) ? (a, b) : (b, a);
      return (luminance(light) + 0.05) / (luminance(dark) + 0.05);
    }

    for (final brightness in Brightness.values) {
      for (final palette in PaletteId.values) {
        for (final accent in AccentId.values) {
          final colors = AppearanceColors.resolve(brightness, palette, accent);
          expect(
            contrast(colors.accent, colors.onAccent),
            greaterThanOrEqualTo(4.5),
            reason: '$brightness $palette $accent',
          );
          expect(
            contrast(colors.accentContent, colors.background),
            greaterThanOrEqualTo(4.5),
            reason: '$brightness $palette $accent on background',
          );
          expect(
            contrast(colors.textSecondary, colors.surface),
            greaterThanOrEqualTo(4.5),
          );
        }
      }
    }
  });
}
