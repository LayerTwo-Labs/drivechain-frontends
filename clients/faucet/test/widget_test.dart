import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() async {
  testWidgets('can build page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpSailPage(
      SailRawCard(title: 'nice', subtitle: 'learn about teh niceties of nice', child: SailText.primary10('nice')),
    );
  });
}
