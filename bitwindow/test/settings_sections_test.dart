import 'package:bitwindow/gen/version.dart';
import 'package:bitwindow/pages/settings_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  setUpAll(() async {
    await registerTestDependencies();
    if (!GetIt.I.isRegistered<UpdateProvider>()) {
      GetIt.I.registerSingleton<UpdateProvider>(
        UpdateProvider(
          log: GetIt.I.get<Logger>(),
          binaryType: BinaryType.BINARY_TYPE_BITWINDOWD,
          currentVersion: AppVersion.version,
        ),
      );
    }
  });

  testWidgets('the About section stays selectable', (tester) async {
    final last = SettingsPage.sections.length - 1;
    expect(SettingsPage.sections[last].label, 'About');

    await tester.pumpSailPage(SettingsPage(initialSection: last));

    expect(find.text('Build date'), findsOneWidget);
    expect(find.text('Commit'), findsOneWidget);
  });
}
