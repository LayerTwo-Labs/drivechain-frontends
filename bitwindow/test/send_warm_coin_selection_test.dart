import 'package:bitwindow/pages/wallet/wallet_send.dart';
import 'package:bitwindow/utils/fee_estimation.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

class _PreviewWallet implements OrchestratorWalletRPC {
  final previews = <Map<String, int>>[];
  Object? error;

  @override
  Future<wmpb.PreviewSendResponse> previewSend({
    required String walletId,
    required Map<String, int> destinations,
    required int feeRateSatPerVbyte,
    bool subtractFeeFromAmount = false,
    List<UnspentOutput>? requiredInputs,
  }) async {
    expect(walletId, 'w1');
    expect(requiredInputs, isNull);
    previews.add(destinations);
    if (error case final e?) {
      throw e;
    }
    return wmpb.PreviewSendResponse(feeSats: Int64(141));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final coin = UnspentOutput(output: 'aa:0', address: 'bcrt1qown', valueSats: Int64(100000));

  test('the send page prices one dust payment to a coin of the wallet', () async {
    final wallet = _PreviewWallet();

    await SendPageViewModel.warmCoinSelection(wallet, 'w1', [coin]);

    expect(wallet.previews, [
      {'bcrt1qown': dustSats},
    ]);
  });

  test('a wallet with no coin sends no preview', () async {
    final wallet = _PreviewWallet();

    await SendPageViewModel.warmCoinSelection(wallet, 'w1', []);
    await SendPageViewModel.warmCoinSelection(wallet, null, [coin]);

    expect(wallet.previews, isEmpty);
  });

  test('a failed preview stays out of the page', () async {
    final wallet = _PreviewWallet()..error = Exception('insufficient funds');

    await SendPageViewModel.warmCoinSelection(wallet, 'w1', [coin]);

    expect(wallet.previews, hasLength(1));
  });
}
