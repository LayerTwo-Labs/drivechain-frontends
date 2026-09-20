import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget wrap(Widget child) => MaterialApp(
  home: SailTheme(
    data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
    child: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('a hover opens the title and the words', (tester) async {
    await tester.pumpWidget(
      wrap(
        const SailInfoIcon(
          title: 'Hashrate',
          message: 'How many guesses per second your miners make.',
        ),
      ),
    );

    expect(find.text('Hashrate'), findsNothing);

    final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await pointer.addPointer(location: Offset.zero);
    addTearDown(pointer.removePointer);
    await pointer.moveTo(tester.getCenter(find.byType(SailInfoIcon)));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Hashrate'), findsOneWidget);
    expect(find.text('How many guesses per second your miners make.'), findsOneWidget);

    // The bubble stays while the pointer rests on the icon.
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Hashrate'), findsOneWidget);

    await pointer.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(find.text('Hashrate'), findsNothing);
  });

  testWidgets('a stat tile carries the icon', (tester) async {
    await tester.pumpWidget(
      wrap(
        const SizedBox(
          width: 320,
          child: SailCardStats(
            title: 'Best share',
            value: '1.12 M',
            subtitle: 'of 2.39 M needed for a block',
            icon: SailSVGAsset.scatterChart,
            info: 'The closest your miner came to a block.',
          ),
        ),
      ),
    );

    expect(find.byType(SailInfoIcon), findsOneWidget);
    expect(find.text('of 2.39 M needed for a block'), findsOneWidget);
  });
}
