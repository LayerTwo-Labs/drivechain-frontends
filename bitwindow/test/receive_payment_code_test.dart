import 'package:bitwindow/pages/wallet/wallet_receive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

const _code =
    'PM8TJTLJbPRGxSbc8EJi42Wrr6QbNSaSSVJ5Y3E4pbCYiTHUskHg13935Ubb7q8tx9GVbh2UuRnBc3WSyJHhUrw8KhprKnn9eDznYGieTzFcwQRya4GA';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpSailPage(
    const Align(
      alignment: Alignment.topLeft,
      child: PaymentCodeField(code: _code),
    ),
  );
  if (SailStyleValues.phoneLayoutOverride == true) {
    await tester.usePhoneSize();
  }
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadBundledFonts);

  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  testWidgets('on a phone the payment code wraps with the copy button beside it', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await _pump(tester);

    final text = tester.getRect(find.byType(EditableText));
    final copy = tester.getRect(find.byType(CopyButton));
    expect(text.height, greaterThan(30));
    expect(copy.left, greaterThanOrEqualTo(text.right - 1));
    expect(copy.right, lessThanOrEqualTo(390));
  });

  testWidgets('on a desktop the payment code stays on one line', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await _pump(tester);

    expect(tester.widget<EditableText>(find.byType(EditableText)).maxLines, 1);
  });
}
