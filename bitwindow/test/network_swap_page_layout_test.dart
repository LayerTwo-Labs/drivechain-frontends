import 'package:bitwindow/pages/settings/network_swap_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

const _page = NetworkSwapPage(
  fromNetwork: BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
  toNetwork: BitcoinNetwork.BITCOIN_NETWORK_REGTEST,
);

void main() {
  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  testWidgets('on a phone the switch is one panel with the title at the left and the buttons inside', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await tester.pumpSailPage(_page);

    expect(tester.takeException(), isNull);
    expect(find.byType(SailPanelPage), findsOneWidget);
    expect(find.byType(BottomActionBar), findsNothing);
    expect(find.text('Switch Bitcoin Network'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(SailPanelPage), matching: find.text('Cancel')),
      findsWidgets,
    );
  });

  testWidgets('on a desktop the switch keeps its centered title and the bottom bar', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await tester.pumpSailPage(_page);

    expect(find.byType(SailPanelPage), findsNothing);
    expect(find.byType(BottomActionBar), findsOneWidget);
  });
}
