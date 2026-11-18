import 'package:bitwindow/pages/settings/settings_reset.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart' hide SettingsReset;

import 'test_utils.dart';

void main() {
  tearDown(() => GetIt.I.reset());

  testWidgets('Reset Selected sits below every option row in a short window', (tester) async {
    await tester.pumpSailPage(const SizedBox(height: 420, child: SettingsReset()));

    final button = tester.getRect(find.widgetWithText(SailButton, 'Reset Selected'));
    final list = tester.getRect(find.byType(SailSettingsBody));
    expect(button.top, greaterThanOrEqualTo(list.bottom));

    for (final row in tester.widgetList<SailSettingsRow>(find.byType(SailSettingsRow))) {
      final rect = tester.getRect(find.byWidget(row));
      final visible = rect.intersect(list);
      if (visible.height > 0) {
        expect(visible.overlaps(button), isFalse, reason: '${row.label} is under the button');
      }
    }
  });
}
