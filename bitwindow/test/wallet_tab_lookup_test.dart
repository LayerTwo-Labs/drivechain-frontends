import 'package:bitwindow/pages/wallet/wallet_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  final tabs = <TabItem>[
    const SingleTabItem(label: 'Overview', child: SizedBox()),
    const SingleTabItem(label: 'UTXOs', child: SizedBox()),
    MultiSelectTabItem(
      title: 'Tools',
      items: const [
        TabItem(label: 'Deniability', child: SizedBox()),
        TabItem(label: 'Consolidate', child: SizedBox()),
      ],
    ),
  ];

  test('finds a top level tab', () {
    final found = walletTabIndexForLabel(tabs, 'UTXOs')!;

    expect(found.index, 1);
    expect(found.subLabel, isNull);
  });

  test('finds an item inside the Tools tab', () {
    final found = walletTabIndexForLabel(tabs, WalletPage.consolidateSubtabLabel)!;

    expect(found.index, 2);
    expect(found.subLabel, 'Consolidate');
  });

  test('returns nothing for a label no tab carries', () {
    expect(walletTabIndexForLabel(tabs, 'Nothing'), isNull);
  });
}
