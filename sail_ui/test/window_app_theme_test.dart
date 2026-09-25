import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'theme_toggle_regression_test.dart' show MockStore;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GetIt.I.reset();
    final log = Logger(level: Level.warning);
    GetIt.I.registerSingleton<Logger>(log);
    final settings = ClientSettings(store: MockStore(), log: log);
    await settings.setValue(ThemeSetting(newValue: SailThemeValues.dark));
    GetIt.I.registerSingleton<ClientSettings>(settings);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('the app builder reads the app theme, not the fallback', (tester) async {
    late SailThemeData builderTheme;
    await tester.pumpWidget(
      SailApp(
        dense: false,
        accentColor: SailColorScheme.orange,
        log: GetIt.I.get<Logger>(),
        builder: (context) {
          builderTheme = SailTheme.of(context);
          return const MaterialApp(home: SizedBox());
        },
      ),
    );
    await tester.pumpAndSettle();

    final appTheme = tester.state<SailAppState>(find.byType(SailApp)).theme;
    expect(appTheme.colors, isNot(SailTheme.kFallbackTheme.colors));
    expect(builderTheme.colors, appTheme.colors);
  });

  testWidgets('a sub-window paints its frame in the app theme', (tester) async {
    await tester.pumpWidget(
      buildSailWindowApp(GetIt.I.get<Logger>(), 'Message Signer', const SizedBox(), SailColorScheme.orange),
    );
    await tester.pumpAndSettle();

    final colors = tester.state<SailAppState>(find.byType(SailApp)).theme.colors;
    expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, colors.background);
    final titleStrip = tester.widget<Container>(
      find.ancestor(of: find.text('Message Signer'), matching: find.byType(Container)).first,
    );
    expect(titleStrip.color, colors.backgroundSecondary);
  });
}
