import 'dart:convert';

import 'package:bitwindow/pages/wallet/psbt_signer_tab.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

const _unsignedPsbt =
    'cHNidP8BAHECAAAAAfrxs4O1d0Fw5EbFFqHZ9aOjCXx5s2pPYl5wL9QcF2u6AAAAAAD9////AoCWmAAAAAAAFgAUdBPeN7LqUbDX2iYcJ+JkHLvS4bbYxdQXAAAAABYAFM8A+FQwFOsNOo+uKP0jlUk25DxZAAAAAAAAAAA=';

void main() {
  test('isBase64Psbt accepts a PSBT and rejects other base64', () {
    expect(isBase64Psbt(_unsignedPsbt), isTrue);
    expect(isBase64Psbt(base64.encode(utf8.encode('hello world'))), isFalse);
    expect(isBase64Psbt(base64.encode([0x70, 0x73, 0x62, 0x74])), isFalse);
    expect(isBase64Psbt('not base64 !!'), isFalse);
  });

  testWidgets('base64 that is not a PSBT shows the error and opens no dialog', (tester) async {
    await tester.pumpSailPage(const PsbtSignerTab());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), base64.encode(utf8.encode('hello world')));
    await tester.tap(find.text('Sign with external signer').hitTestable());
    await tester.pumpAndSettle();

    expect(find.text('Not a valid base64 PSBT'), findsOneWidget);
    expect(find.text('External signer (airgap)'), findsNothing);
  });
}
