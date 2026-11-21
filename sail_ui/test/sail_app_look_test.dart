import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  tearDown(() => GetIt.I.reset());

  testWidgets('a given look draws the first frame', (tester) async {
    SailThemeData? first;
    await tester.pumpWidget(
      SailApp(
        log: Logger(level: Level.off),
        dense: true,
        accentColor: SailColorScheme.orange,
        look: const SailAppLook(
          theme: SailThemeValues.light,
          font: SailFontValues.ibmMono,
          fontScale: 1.25,
          style: SailThemeStyle.sail,
        ),
        builder: (context) {
          first ??= SailTheme.of(context);
          return const SizedBox();
        },
      ),
    );

    expect(first!.type, SailThemeValues.light);
    expect(first!.font, SailFontValues.ibmMono);
    expect(first!.style, SailThemeStyle.sail);
  });
}
