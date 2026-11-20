import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/models/multisig_transaction.dart';
import 'package:bitwindow/widgets/create_multisig_modal.dart';
import 'package:bitwindow/widgets/sign_preview_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

const _destination = 'tb1qq9t2a6fz8x4m1k3p5v7n9c0d2f4h6j8l1s3a5';

final _group = MultisigGroup(
  id: 'g1',
  name: 'Cold storage',
  n: 3,
  m: 2,
  created: 0,
  keys: [
    MultisigKey(owner: 'MyKey0', xpub: 'x0', derivationPath: "m/84'/1'/0'", isWallet: true),
    MultisigKey(owner: 'Alice', xpub: 'x1', derivationPath: "m/84'/1'/0'", isWallet: false),
    MultisigKey(owner: 'Bob', xpub: 'x2', derivationPath: "m/84'/1'/0'", isWallet: false),
  ],
);

final _tx = MultisigTransaction(
  id: 'tx_a41f',
  groupId: 'g1',
  initialPSBT: 'psbt',
  keyPSBTs: const [
    KeyPSBTStatus(keyId: 'x0', psbt: 'p0', isSigned: false),
    KeyPSBTStatus(keyId: 'x1', psbt: 'p1', isSigned: true),
    KeyPSBTStatus(keyId: 'x2', psbt: 'p2', isSigned: false),
  ],
  type: TxType.withdrawal,
  created: DateTime(2026, 11, 1),
  amount: 0.2,
  destination: _destination,
  fee: 0.00000282,
  inputs: const [],
);

Future<void> _pump(WidgetTester tester, {required bool phone}) async {
  SailStyleValues.phoneLayoutOverride = phone;
  await tester.pumpSailPage(SignPreviewModal(transaction: _tx, group: _group, onSignConfirm: () async {}));
  await tester.binding.setSurfaceSize(phone ? const Size(390, 1000) : const Size(1200, 900));
  await tester.pump();
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

  testWidgets('on a phone the details are label and value rows, with the destination under its label', (
    tester,
  ) async {
    await _pump(tester, phone: true);

    expect(tester.takeException(), isNull);
    expect(find.byType(SailStatList), findsNWidgets(3));
    final label = tester.getRect(find.text('Group'));
    final value = tester.getRect(find.text('Cold storage'));
    expect(value.left, greaterThan(label.right));
    expect(value.center.dy, closeTo(label.center.dy, 1));

    final destinationLabel = tester.getRect(find.text('Destination'));
    final destination = tester.getRect(find.text(_destination));
    expect(destination.top, greaterThan(destinationLabel.bottom));
    expect(destination.left, destinationLabel.left);
    expect(find.text('Keys to be signed'), findsOneWidget);
  });

  testWidgets('on a phone the key status is one box with a row per key', (tester) async {
    await _pump(tester, phone: true);

    final box = find.ancestor(of: find.text('Alice'), matching: find.byType(SailStatList));
    for (final owner in ['MyKey0', 'Alice', 'Bob']) {
      expect(find.descendant(of: box, matching: find.text(owner)), findsOneWidget);
    }
    expect(find.descendant(of: box, matching: find.text('Ready to sign')), findsOneWidget);
    expect(find.descendant(of: box, matching: find.text('Signed')), findsOneWidget);
    expect(find.descendant(of: box, matching: find.text('Awaiting external signature')), findsOneWidget);
    expect(find.descendant(of: box, matching: find.text('Wallet Key')), findsOneWidget);
  });

  testWidgets('the desktop keeps the colon labels', (tester) async {
    await _pump(tester, phone: false);

    expect(find.byType(SailStatList), findsNothing);
    expect(find.text('Destination:'), findsOneWidget);
  });
}
