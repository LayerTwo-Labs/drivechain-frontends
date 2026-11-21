import 'package:bitwindow/pages/remove_encryption_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  testWidgets('on a phone the page is one panel with the title at the left', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await tester.pumpSailPage(const RemoveEncryptionPage());

    expect(tester.takeException(), isNull);
    expect(find.byType(SailPanelPage), findsOneWidget);
    expect(find.text('Remove Encryption'), findsOneWidget);
    expect(find.text('Current Password'), findsOneWidget);

    await tester.tap(find.text('REMOVE ENCRYPTION'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(SailPanelPage), matching: find.text('Please enter your password')),
      findsOneWidget,
    );
  });

  testWidgets('on a desktop the page keeps its centered title', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await tester.pumpSailPage(const RemoveEncryptionPage());

    expect(find.byType(SailPanelPage), findsNothing);
    expect(find.text('REMOVE ENCRYPTION'), findsNWidgets(2));
  });
}
