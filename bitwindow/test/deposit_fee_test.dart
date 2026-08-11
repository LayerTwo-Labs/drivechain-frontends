import 'package:bitwindow/utils/deposit_fee.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class _FakeWalletRPC implements OrchestratorWalletRPC {
  double? rate;
  final List<int> targets = [];

  @override
  Future<double?> estimateFee(int confTarget) async {
    targets.add(confTarget);
    return rate;
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

void main() {
  late _FakeOrchestrator orchestrator;
  late DepositFeeEstimate estimate;

  setUp(() async {
    await GetIt.I.reset();
    orchestrator = _FakeOrchestrator();
    GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);
    estimate = DepositFeeEstimate(TextEditingController());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('the fee comes from the estimated rate, not a fixed amount', () async {
    orchestrator.wallet.rate = 4;

    await estimate.refresh(1);

    final feeSats = 4 * estimate.vBytes;
    expect(estimate.feeSats, feeSats);
    expect(estimate.controller.text, satoshiToBTC(feeSats).toStringAsFixed(8));
    expect(estimate.hint, contains('4 sat/vB'));
  });

  test('another target reads that target', () async {
    orchestrator.wallet.rate = 2;

    await estimate.refresh(6);

    expect(orchestrator.wallet.targets, [6]);
    expect(estimate.confTarget, 6);
    expect(estimate.feeSats, 2 * estimate.vBytes);
  });

  // Without an estimate the deposit must still be payable, so it falls back to
  // the minimum rate instead of leaving the field empty.
  test('no estimate falls back to the minimum rate', () async {
    orchestrator.wallet.rate = null;

    await estimate.refresh(1);

    expect(estimate.estimated, isFalse);
    expect(estimate.feeSats, estimate.vBytes);
    expect(estimate.controller.text.isNotEmpty, isTrue);
    expect(estimate.hint, contains('minimum'));
  });

  // The field stays editable, so a fee typed while the first read is in flight
  // must survive it.
  test('the first estimate keeps a fee the user typed', () async {
    orchestrator.wallet.rate = 4;

    final pending = estimate.refresh(1, keepEdits: true);
    estimate.controller.text = '0.00005000';
    await pending;

    expect(estimate.controller.text, '0.00005000');
  });

  test('picking a target replaces a typed fee', () async {
    orchestrator.wallet.rate = 4;
    estimate.controller.text = '0.00005000';

    await estimate.refresh(3);

    expect(estimate.controller.text, satoshiToBTC(4 * estimate.vBytes).toStringAsFixed(8));
  });

  // The old fixed fee was 0.0001 BTC, orders of magnitude above a real one.
  test('an estimated fee is far below the fixed fee it replaces', () async {
    orchestrator.wallet.rate = 4;

    await estimate.refresh(1);

    expect(satoshiToBTC(estimate.feeSats), lessThan(0.0001));
  });
}
