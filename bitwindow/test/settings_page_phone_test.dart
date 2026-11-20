import 'package:bitwindow/pages/settings_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  setUp(() => SailStyleValues.phoneLayoutOverride = true);
  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  testWidgets('on a phone Settings opens on the section list', (tester) async {
    await tester.pumpSailPage(const SettingsPage());

    expect(tester.takeException(), isNull);
    expect(find.byType(SailStatList), findsOneWidget);
    for (final section in SettingsPage.sections) {
      expect(find.text(section.label), findsOneWidget);
    }
  });

  testWidgets('on a phone a requested section opens at once', (tester) async {
    await tester.pumpSailPage(SettingsPage(initialSection: 3));

    expect(find.byType(SailStatList), findsNothing);
    expect(find.byKey(const Key('settings-back')), findsOneWidget);
  });
}
