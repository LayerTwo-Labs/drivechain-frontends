import 'dart:async';

import 'package:bitwindow/pages/welcome/multisig_config_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

String _descriptor(int keys) {
  final xpubs = List.generate(
    keys,
    (i) =>
        'xpub6BhcZ6e2B4xn98Joc61f6XUdhzJK5Jfzm8H1eiMuU17VGPQcnrZQJfbE9t2C5uRYBujDir9ZKKECakVT3HJSQD9jdxzwgciw3qLYKMwbYSp$i',
  ).join(',');
  return 'wsh(sortedmulti(3,$xpubs/0/*))#hcnr7ydd';
}

void main() {
  testWidgets('the export dialog fits five keys without overflow', (tester) async {
    tester.view.physicalSize = const Size(1280, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: const SizedBox.expand(),
        ),
      ),
    );

    unawaited(
      showMultisigExportDialog(
        tester.element(find.byType(SizedBox).first),
        receive: _descriptor(5),
        change: _descriptor(5),
        coldcardConfig: 'Name: w\nPolicy: 3 of 5\nFormat: P2WSH\n${_descriptor(5)}',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Multisig wallet created'), findsOneWidget);
  });
}
