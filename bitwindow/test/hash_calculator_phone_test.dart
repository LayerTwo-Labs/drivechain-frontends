import 'package:bitwindow/widgets/hash_calculator_modal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

const _sha256d = '4f8b42c22dd3729b519ba6f68d2da7cc5b2d606d05daed5ad5128cc03e6c6358';

void main() {
  tearDown(() {
    SailStyleValues.phoneLayoutOverride = null;
    return GetIt.I.reset();
  });

  Future<void> pumpCalculator(WidgetTester tester) async {
    await tester.pumpSailPage(const HashCalculator());
    await tester.enterText(find.byType(EditableText).first, 'abc');
    await tester.pumpAndSettle();
  }

  Future<void> pumpPhone(WidgetTester tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await loadBundledFonts();
    await tester.pumpSailPage(const HashCalculator());
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.enterText(find.byType(EditableText).first, 'abc');
    await tester.pumpAndSettle();
  }

  testWidgets('on a phone the header has a title with ? at the right, and labels sit above values', (tester) async {
    await pumpPhone(tester);

    expect(tester.takeException(), isNull);
    final title = tester.getRect(find.text('Hash Calculator'));
    final help = tester.getRect(find.widgetWithText(SailButton, '?'));
    expect(help.center.dy, closeTo(title.center.dy, 8));
    expect(help.left, greaterThan(title.right));

    expect(tester.getCenter(find.text('Paste')).dy, closeTo(tester.getCenter(find.text('Input')).dy, 4));
    expect(tester.getRect(find.text('Paste')).right, greaterThan(300));

    final label = tester.getRect(find.text('SHA256D:'));
    final value = tester.getRect(find.text(_sha256d));
    expect(value.top, greaterThanOrEqualTo(label.bottom));
    expect(value.left, closeTo(label.left, 1));

    final copy = find.byWidgetPredicate((w) => w is CopyButton && w.text == _sha256d);
    expect(copy, findsOneWidget);
    expect(tester.getRect(copy).left, greaterThanOrEqualTo(value.right));
  });

  testWidgets('on desktop the label and value share a row and the header has no title', (tester) async {
    await pumpCalculator(tester);

    expect(find.text('Hash Calculator'), findsNothing);
    expect(find.byType(CopyButton), findsNothing);
    final label = tester.getRect(find.text('SHA256D: '));
    final value = tester.getRect(find.text(_sha256d));
    expect(value.center.dy, closeTo(label.center.dy, 1));
    expect(value.left, greaterThan(label.right));
  });

  testWidgets('on a phone the input controls fit at 390 px in hex and HMAC mode', (tester) async {
    await pumpPhone(tester);
    await tester.tap(find.text('Hex'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('HMAC'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    for (final label in ['Input', 'Hex', 'HMAC', 'Clear', 'Paste', 'Flip Bytes']) {
      final rect = tester.getRect(find.text(label));
      expect(rect.right, lessThanOrEqualTo(390), reason: label);
    }
    final hmac = tester.getRect(find.text('HMAC'));
    expect(tester.getRect(find.byType(SailTextField).first).top, greaterThan(hmac.bottom));
  });
}
