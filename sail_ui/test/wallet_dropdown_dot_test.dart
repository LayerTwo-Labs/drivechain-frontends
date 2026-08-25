import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

WalletMetadata _wallet(String id, String name) => WalletMetadata(
  id: id,
  name: name,
  gradient: WalletGradient(
    backgroundSvg: 'background_northern.svg',
    colors: const ['#000000', '#111111', '#222222'],
    stops: const [0, 0.5, 1],
    centerX: 0,
    centerY: 0,
    radius: 1.2,
    seed: 1,
  ),
  createdAt: DateTime(2026),
  lastUsed: DateTime(2026),
);

void main() {
  Widget host(Set<String> attention) => SailTheme(
    data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
    child: MaterialApp(
      home: Scaffold(
        body: WalletDropdown(
          currentWallet: _wallet('a', 'Main'),
          availableWallets: [_wallet('a', 'Main'), _wallet('b', 'Cold')],
          onWalletSelected: (_) {},
          onCreateWallet: () {},
          walletsNeedingAttention: attention,
        ),
      ),
    ),
  );

  // A wallet the user is not in can hold coins to claim, and the picker is the
  // only place that says so.
  testWidgets('a wallet with something to claim carries a dot', (tester) async {
    await tester.pumpWidget(host({'b'}));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(WalletDropdown));
    await tester.pumpAndSettle();

    final dots = tester.widgetList<Container>(find.byType(Container)).where((c) {
      final d = c.decoration;
      return d is BoxDecoration && d.shape == BoxShape.circle && c.constraints?.maxWidth == 8;
    });
    expect(dots.length, 1, reason: 'exactly the wallet with a claim gets a dot');
  });

  testWidgets('no dot without a claim', (tester) async {
    await tester.pumpWidget(host(const {}));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(WalletDropdown));
    await tester.pumpAndSettle();

    final dots = tester.widgetList<Container>(find.byType(Container)).where((c) {
      final d = c.decoration;
      return d is BoxDecoration && d.shape == BoxShape.circle && c.constraints?.maxWidth == 8;
    });
    expect(dots, isEmpty);
  });
}
