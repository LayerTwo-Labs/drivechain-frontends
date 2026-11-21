import 'dart:io';

import 'package:bitwindow/pages/wallet/bump_fee_dialog.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

import 'test_utils.dart';

class _FakeWalletRPC implements OrchestratorWalletRPC {
  @override
  Future<wmpb.PreviewBumpFeeResponse> previewBumpFee({
    required String walletId,
    required String txid,
    int? newFeeRate,
    int? feeFromVout,
  }) async {
    return wmpb.PreviewBumpFeeResponse(
      inputCount: 1,
      vsizeVbytes: Int64(141),
      oldFeeSats: Int64(141),
      oldFeeRateSatVb: 1,
      suggestedFeeRate: Int64(5),
      canReplace: true,
      outputs: [wmpb.BumpFeeOutput(vout: 0, address: 'tb1qpayment', amountSats: Int64(100000))],
      reason: 'The transaction has no change output',
      cancel: wmpb.CancelPlan(feeSats: Int64(500), recoveredSats: Int64(99500)),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  final _FakeWalletRPC wallet = _FakeWalletRPC();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _WalletReader extends WalletReaderProvider {
  _WalletReader() : super(Directory.systemTemp) {
    activeWalletId = 'wallet-1';
  }
}

Finder _button(String label) => find.byWidgetPredicate((w) => w is SailButton && w.label == label);

Future<void> _pumpDialog(WidgetTester tester, {bool phone = false}) async {
  await tester.pumpSailPage(const BumpFeeDialog(txid: 'ab12'));
  if (phone) {
    await tester.usePhoneSize();
  }
  await tester.pumpAndSettle();
}

// A sheet as wide as the phone, with no dialog inset.
Future<void> _pumpSheetBody(WidgetTester tester) async {
  await tester.pumpSailPage(const BumpFeeDialog(txid: 'ab12'));
  await tester.binding.setSurfaceSize(const Size(470, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadBundledFonts);

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());
    GetIt.I.registerSingleton<WalletReaderProvider>(_WalletReader());
    GetIt.I.registerSingleton<TransactionProvider>(TransactionProvider());
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  testWidgets('on a phone Replace is full width, Cancel and RBF share a row, Close comes last', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await _pumpSheetBody(tester);

    final replace = tester.getRect(_button('Replace transaction'));
    final cancel = tester.getRect(_button('Cancel transaction'));
    final rbf = tester.getRect(_button('I want to RBF it'));
    final close = tester.getRect(_button('Close'));
    expect(cancel.top, greaterThan(replace.bottom - 1));
    expect(rbf.center.dy, closeTo(cancel.center.dy, 1));
    expect(rbf.left, greaterThan(cancel.right - 1));
    expect(close.top, greaterThan(cancel.bottom - 1));
    expect(close.width, closeTo(replace.width, 1));
    expect(rbf.right - cancel.left, closeTo(replace.width, 1));
  });

  testWidgets('in a 390 px dialog the narrow button pair stacks with no overflow', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await _pumpDialog(tester, phone: true);

    final cancel = tester.getRect(_button('Cancel transaction'));
    final rbf = tester.getRect(_button('I want to RBF it'));
    expect(rbf.top, greaterThan(cancel.bottom - 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('on a phone the headings are 13 px', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await _pumpDialog(tester, phone: true);

    expect(tester.widget<Text>(find.text('This transaction')).style?.fontSize, 13);
    expect(tester.widget<Text>(find.text('New fee')).style?.fontSize, 13);
  });

  testWidgets('on a desktop the buttons share one row and the headings are 15 px', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await _pumpDialog(tester);

    final replace = tester.getRect(_button('Replace transaction'));
    final close = tester.getRect(_button('Close'));
    expect(close.center.dy, closeTo(replace.center.dy, 1));
    expect(tester.widget<Text>(find.text('This transaction')).style?.fontSize, 15);
  });

  testWidgets('on a phone the cancel labels take a 148 px column', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await _pumpDialog(tester, phone: true);

    await tester.tap(_button('Cancel transaction'));
    await tester.pumpAndSettle();

    final label = tester.getRect(find.text('Returns to this wallet'));
    expect(tester.getTopLeft(find.text('Fee')).dx, closeTo(label.left, 1));
    expect(tester.getTopLeft(find.textContaining('0.0009')).dx, closeTo(label.left + 148, 1));
    expect(tester.getTopLeft(find.text('ab12')).dx, closeTo(label.left + 148, 1));
  });

  testWidgets('on a phone the bump values start 132 px from the labels', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await _pumpDialog(tester, phone: true);

    final label = tester.getRect(find.text('Inputs'));
    expect(tester.getTopLeft(find.textContaining('1 coins')).dx, closeTo(label.left + 132, 1));
    expect(tester.takeException(), isNull);
  });
}
