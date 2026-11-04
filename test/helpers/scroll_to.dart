import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Прокручивает основной список до [finder], полностью показывает его и нажимает.
Future<void> scrollToAndTap(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
