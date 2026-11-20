import 'package:bitwindow/widgets/network_unavailable_body.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _body() {
  return SailTheme(
    data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
    child: const Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 360,
          child: NetworkUnavailableBody(
            heading: 'Unlock Sidechains with BIP300',
            intro: 'Sidechains are only available on Drivechain-enabled networks.',
            sections: [('What are Sidechains?', 'Bitcoin-backed chains.')],
          ),
        ),
      ),
    ),
  );
}

void main() {
  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  testWidgets('a phone has no inset, a 16 px heading and 13 px subheads', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await tester.pumpWidget(_body());

    expect(tester.getRect(find.text('Unlock Sidechains with BIP300')).left, 0);
    expect(tester.widget<Text>(find.text('Unlock Sidechains with BIP300')).style!.fontSize, 16);
    expect(tester.widget<Text>(find.text('What are Sidechains?')).style!.fontSize, 13);
  });

  testWidgets('the desktop keeps the 20 px inset, the 20 px heading and the 15 px subheads', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await tester.pumpWidget(_body());

    expect(tester.getRect(find.text('Unlock Sidechains with BIP300')).left, 20);
    expect(tester.widget<Text>(find.text('Unlock Sidechains with BIP300')).style!.fontSize, 20);
    expect(tester.widget<Text>(find.text('What are Sidechains?')).style!.fontSize, 15);
  });
}
