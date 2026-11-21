import 'package:bitwindow/pages/transaction_censorship_page.dart';
import 'package:bitwindow/providers/mempool_watch_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    final provider = MempoolWatchProvider()
      ..initialized = true
      ..status = GetMempoolWatchStatusResponse(enabled: true, running: true);
    GetIt.I.registerSingleton<MempoolWatchProvider>(provider);
  });

  tearDown(() {
    SailStyleValues.phoneLayoutOverride = null;
    return GetIt.I.reset();
  });

  Finder button(String label) => find.widgetWithText(SailButton, label);

  testWidgets('on a phone Stop watching and Reset tracker are small outline buttons on one row', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await loadBundledFonts();
    await tester.pumpSailPage(const TransactionCensorshipPage());
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pump();

    expect(tester.takeException(), isNull);
    for (final label in ['Stop watching', 'Reset tracker']) {
      final widget = tester.widget<SailButton>(button(label));
      expect(widget.variant, ButtonVariant.outline);
      expect(widget.small, isTrue);
    }
    final stop = tester.getRect(button('Stop watching'));
    final reset = tester.getRect(button('Reset tracker'));
    expect(reset.center.dy, closeTo(stop.center.dy, 1));
    expect(tester.getRect(find.byType(SailTextField)).top, greaterThan(stop.bottom));
  });

  testWidgets('on desktop the buttons keep their size and share a row with the search', (tester) async {
    await tester.pumpSailPage(const TransactionCensorshipPage());
    await tester.pump();

    final stop = tester.widget<SailButton>(button('Stop watching'));
    expect(stop.variant, ButtonVariant.secondary);
    expect(stop.small, isFalse);
    expect(
      tester.getRect(find.byType(SailTextField)).center.dy,
      closeTo(tester.getRect(button('Stop watching')).center.dy, 4),
    );
  });
}
