import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

const _track = Color(0xFF123456);

Widget _slider({Color? trackColor}) {
  return SailTheme(
    data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 300,
          child: SailSlider(value: 2, min: 0, max: 9, onChanged: (_) {}, showSteps: false, trackColor: trackColor),
        ),
      ),
    ),
  );
}

Finder _trackWith(Color color) => find.byWidgetPredicate(
  (w) => w is Container && w.decoration is BoxDecoration && (w.decoration! as BoxDecoration).color == color,
);

void main() {
  testWidgets('the empty track takes the track color across the full width', (tester) async {
    await tester.pumpWidget(_slider(trackColor: _track));

    final track = _trackWith(_track);
    expect(track, findsOneWidget);
    expect(tester.getSize(track).width, closeTo(300 - 20, 1));
  });

  testWidgets('with no track color the track keeps the secondary background', (tester) async {
    await tester.pumpWidget(_slider());

    expect(_trackWith(_track), findsNothing);
    final theme = SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter);
    expect(_trackWith(theme.colors.backgroundSecondary), findsOneWidget);
  });
}
