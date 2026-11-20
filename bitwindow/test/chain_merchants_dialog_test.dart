import 'package:bitwindow/pages/merchants/chain_merchants_dialog.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  for (final size in const [Size(1200, 600), Size(1024, 700)]) {
    testWidgets('the dialog fits a ${size.width.toInt()}x${size.height.toInt()} window', (tester) async {
      await tester.pumpSailPage(const Center(child: ChainMerchantsDialog()));
      await tester.binding.setSurfaceSize(size);
      await tester.pumpAndSettle();

      final card = tester.getRect(find.byType(SailCard));
      expect(card.top, greaterThanOrEqualTo(0));
      expect(card.bottom, lessThanOrEqualTo(size.height));
      final scroll = tester.state<ScrollableState>(
        find.descendant(of: find.byType(SailDialog), matching: find.byType(Scrollable)).first,
      );
      expect(scroll.position.maxScrollExtent, 0);
    });
  }

  testWidgets('each name is in line with its description', (tester) async {
    await tester.pumpSailPage(const Center(child: ChainMerchantsDialog()));
    await tester.pumpAndSettle();

    for (final merchant in ChainMerchantsDialog.merchants) {
      final name = tester.getRect(find.text(merchant.name));
      final description = tester.getRect(find.text(merchant.description));
      expect(name.top, moreOrLessEquals(description.top, epsilon: 2));
      expect(name.bottom, moreOrLessEquals(description.bottom, epsilon: 2));
    }
  });
}
