import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/pages/unlock_wallet_page.dart' show BootTitle;
import 'package:sail_ui/sail_ui.dart' hide BootTitle;

Widget _title() {
  return SailTheme(
    data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
    child: const Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 358,
          child: BootTitle(
            title: 'Decrypt Your Wallet',
            subtitle: 'Your wallet is encrypted. Please enter your password to unlock it.',
          ),
        ),
      ),
    ),
  );
}

double _fontSize(WidgetTester tester) => tester.widget<Text>(find.text('Decrypt Your Wallet')).style!.fontSize!;

void main() {
  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  testWidgets('on a phone the decrypt title is 24 px', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await tester.pumpWidget(_title());

    expect(_fontSize(tester), 24);
  });

  testWidgets('on the desktop the decrypt title stays 40 px', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await tester.pumpWidget(_title());

    expect(_fontSize(tester), 40);
  });
}
