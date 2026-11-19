import 'package:bitwindow/widgets/airgap_sign_step.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

const _unsignedPsbt =
    'cHNidP8BAHECAAAAAfrxs4O1d0Fw5EbFFqHZ9aOjCXx5s2pPYl5wL9QcF2u6AAAAAAD9////AoCWmAAAAAAAFgAUdBPeN7LqUbDX2iYcJ+JkHLvS4bbYxdQXAAAAABYAFM8A+FQwFOsNOo+uKP0jlUk25DxZAAAAAAAAAAA=';

void main() {
  testWidgets('the export actions stay visible when the dialog is short', (tester) async {
    await tester.pumpSailPage(
      Center(
        child: SizedBox(
          width: 560,
          height: 400,
          child: AirgapSignStep(
            unsignedPsbtBase64: _unsignedPsbt,
            onSigned: (_) {},
            onCancel: () {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(find.text('Cancel').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Next: import signed').hitTestable());
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Or paste signed PSBT (base64)'), findsOneWidget);
  });
}
