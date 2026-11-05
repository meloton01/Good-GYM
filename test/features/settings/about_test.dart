import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/core/constants/legal_links.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/scroll_to.dart';

void main() {
  /// Открывает настройки и нажимает строку [title] в «О приложении».
  Future<void> tapAboutRow(WidgetTester tester, String title) async {
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await scrollToAndTap(tester, find.text(title));
  }

  testWidgets('privacy policy opens in the app language', (tester) async {
    final backend = await pumpApp(tester);
    await tapAboutRow(tester, 'Privacy policy');

    expect(backend.openedLinks, [LegalLinks.privacyPolicy('en')]);
  });

  testWidgets('terms of use open in the browser', (tester) async {
    final backend = await pumpApp(tester);
    await tapAboutRow(tester, 'Terms of use');

    expect(backend.openedLinks, [LegalLinks.terms('en')]);
  });

  testWidgets('failed link shows what to do', (tester) async {
    final backend = await pumpApp(tester);
    backend.linkOpens = false;
    await tapAboutRow(tester, 'Privacy policy');

    expect(
      find.text(
        'Could not open the link. Install or enable a browser and try again.',
      ),
      findsOneWidget,
    );
  });

  test('unsupported language falls back to English documents', () {
    expect(
      LegalLinks.privacyPolicy('ar').path,
      endsWith('privacy-policy.en.md'),
    );
    expect(LegalLinks.terms('uk').path, endsWith('terms.uk.md'));
  });
}
