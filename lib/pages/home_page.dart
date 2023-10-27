import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/console.dart';
import 'package:sidesail/deposit_address.dart';
import 'package:sidesail/rpc/rpc.dart';
import 'package:sidesail/withdrawals.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SailPage(
      title: 'SideSail',
      body: ViewModelBuilder.reactive(
        viewModelBuilder: () => HomePageViewModel(),
        builder: ((context, viewModel, child) {
          return Center(
            child: SizedBox(
              width: 1200,
              child: Column(
                children: [
                  const Row(
                    children: [
                      Expanded(child: RpcWidget()),
                    ],
                  ),
                  const Row(
                    children: [Text('Withdrawal stuff')],
                  ),
                  Row(
                    children: [
                      Text(
                          'Withdrawal bundle status: ${viewModel.withdrawalBundleStatus}'),
                    ],
                  ),
                  Row(
                    children: [
                      // TODO: this needs to be a P2PKH address. Validate this,
                      // somehow.
                      // can probably use https://github.com/dart-bitcoin/bitcoin_flutter
                      // addressToOutputScript
                      const Text('Mainchain address: '),
                      Expanded(
                        child: TextField(
                          controller: viewModel.withdrawalAddress,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Amount: '),
                      Expanded(
                        child: TextField(
                          controller: viewModel.withdrawalAmount,
                          inputFormatters: [
                            // digits plus dot
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[.0-9]')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => viewModel.onWithdraw(context),
                        child: const Text('Submit withdrawal'),
                      ),
                    ],
                  ),
                  const Withdrawals(),
                  const Row(
                    children: [Text('Deposit stuff')],
                  ),
                  Row(
                    children: [
                      DepositAddress(viewModel.depositAddress),
                      ElevatedButton(
                        onPressed: viewModel.generateDepositAddress,
                        child: const Text('Generate'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class HomePageViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  RPC get _rpc => GetIt.I.get<RPC>();

  final TextEditingController withdrawalAddress = TextEditingController();
  final TextEditingController withdrawalAmount = TextEditingController();

  String depositAddress = 'none';

  Timer? _withdrawalBundleTimer;
  String withdrawalBundleStatus = 'unknown';

  HomePageViewModel() {
    _startWithdrawalBundleFetch();
  }

  void _startWithdrawalBundleFetch() {
    _withdrawalBundleTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
      final state = await _rpc.fetchWithdrawalBundleStatus();
      withdrawalBundleStatus = state;
      notifyListeners();
    });
  }

  void onWithdraw(BuildContext context) async {
    // 1. Get refund address. This can be any address we control on the SC.
    final refund = await _rpc
        .callRAW('getnewaddress', ['Sidechain withdrawal refund']) as String;

    log.d('got refund address: $refund');

    // 2. Get SC fee estimate
    final estimate =
        await _rpc.callRAW('estimatesmartfee', [6]) as Map<String, dynamic>;

    if (estimate.containsKey('errors')) {
      log.w("could not estimate fee: ${estimate["errors"]}");
    }

    final btcPerKb = estimate.containsKey('feerate')
        ? estimate['feerate'] as double
        : 0.0001; // 10 sats/byte

    // Who knows!
    const kbyteInWithdrawal = 5;

    final sidechainFee = btcPerKb * kbyteInWithdrawal;

    log.d('withdrawal: adding SC fee of $sidechainFee');

    // 3. Get MC fee
    // This happens with the `getaveragemainchainfees` RPC. This
    // is passed straight on to the mainchain `getaveragefee`,
    // which is added in the Drivechain implementation of Bitcoin
    // Core.
    // This, as opposed to `estimatesmartfee`, is used is because
    // we need everyone to get the same results for withdrawal
    // bundle validation.
    //
    // The above might not actually be correct... What's the best
    // way of doing this?

    const mainchainFee = 0.001;

    final address = withdrawalAddress.text;
    final amount = double.parse(withdrawalAmount.text);

    // ignore: use_build_context_synchronously
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm withdrawal'),
        content: Text(
          'Confirm withdrawal: $amount BTC to $address for $sidechainFee SC fee and $mainchainFee MC fee',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              log.i(
                'doing withdrawal: $amount BTC to $address for $sidechainFee SC fee and $mainchainFee MC fee',
              );

              final withdrawalTxid = await _rpc.callRAW('createwithdrawal', [
                address,
                refund,
                amount,
                sidechainFee,
                mainchainFee,
              ]);

              log.i('txid: $withdrawalTxid');

              // ignore: use_build_context_synchronously
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Success'),
                  content: Text(
                    'Submitted withdrawal successfully! TXID: $withdrawalTxid',
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK')),
                  ],
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> generateDepositAddress() async {
    var address = await _rpc.generateDepositAddress();
    depositAddress = address;
    notifyListeners();
  }

  @override
  void dispose() {
    _withdrawalBundleTimer?.cancel();
    super.dispose();
  }
}
