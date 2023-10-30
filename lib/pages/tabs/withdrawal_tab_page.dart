import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/rpc/rpc.dart';
import 'package:sidesail/withdrawals.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class WithdrawalTabPage extends StatelessWidget {
  const WithdrawalTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SailPage(
      title: 'Withdraw',
      body: ViewModelBuilder.reactive(
        viewModelBuilder: () => WithdrawalTabPageViewModel(),
        builder: ((context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.primary14(
                  'Your sidechain balance: ${viewModel.sidechainBalance} SBTC',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  onChanged: ((value) {
                    viewModel.withdrawalAddress = value;
                  }),
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    hintText: 'Mainchain Bitcoin Address',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Withdrawal',
                          suffixText: 'SBTC',
                        ),
                        inputFormatters: [
                          // digits plus dot
                          FilteringTextInputFormatter.allow(RegExp(r'[.0-9]')),
                        ],
                        onChanged: (value) {
                          // TODO: this doesn't update the final cost value...
                          viewModel.withdrawalAmount = double.tryParse(value) ?? 0.0;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        initialValue: viewModel.mainchainFee.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Mainchain Fee',
                          suffixText: 'SBTC',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  readOnly: true,
                  initialValue: viewModel.transactionFee.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Transaction Fee',
                    suffixText: 'SBTC',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    SailText.primary14('Total cost:'),
                    const SizedBox(width: 10),
                    SailText.primary14(
                      '${(viewModel.withdrawalAmount + viewModel.mainchainFee + viewModel.transactionFee)} SBTC',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    viewModel.onWithdraw(context);
                  },
                  child: SailText.primary14(
                    'Withdraw',
                  ),
                ),
                // TODO: this just caps the table...
                const SingleChildScrollView(
                  child: SizedBox(
                    height: 300, // TODO: how to get this number
                    child: Withdrawals(),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class WithdrawalTabPageViewModel extends MultipleFutureViewModel {
  RPC get _rpc => GetIt.I.get<RPC>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();

  double get sidechainBalance => _balanceProvider.balance;

  double withdrawalAmount = 0.0;
  double get transactionFee => dataMap?[_SidechainFeeFuture];

  // TODO: estimate this
  final double mainchainFee = 0.001;

  String withdrawalAddress = '';

  Timer? balanceTimer;

  WithdrawalTabPageViewModel() {
    // by adding a listener, we subscribe to changes to the balance
    // provider. We don't use the updates for anything other than
    // showing the new value though, so we keep it simple, and just
    // pass notifyListeners of this view model directly
    _balanceProvider.addListener(notifyListeners);

    balanceTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      // fetchAndUpdateBalance();
    });
  }

  @override
  Map<String, Future Function()> get futuresMap => {
        _SidechainFeeFuture: estimateSidechainFee,
      };

  Future<double> estimateSidechainFee() async {
    final estimate = await _rpc.callRAW('estimatesmartfee', [6]) as Map<String, dynamic>;
    if (estimate.containsKey('errors')) {
      log.w("could not estimate fee: ${estimate["errors"]}");
    }

    final btcPerKb = estimate.containsKey('feerate') ? estimate['feerate'] as double : 0.0001; // 10 sats/byte

    // Who knows!
    const kbyteInWithdrawal = 5;

    return btcPerKb * kbyteInWithdrawal;
  }

  void onWithdraw(BuildContext context) async {
    // 1. Get refund address. This can be any address we control on the SC.
    final refund = await _rpc.callRAW('getnewaddress', ['Sidechain withdrawal refund']) as String;

    log.d('got refund address: $refund');

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

    final address = withdrawalAddress;

    // Because the function is async, the view might disappear/unmount
    // by the time it's used. The linter doesn't like that, and wants
    // you to check whether the view is mounted before using it
    if (!context.mounted) {
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: SailText.primary14(
          'Confirm withdrawal',
        ),
        content: SailText.primary14(
          'Confirm withdrawal: $withdrawalAmount BTC to $address for $transactionFee SC fee and $mainchainFee MC fee',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: SailText.primary14('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Pop the currently visible dialog
              Navigator.of(context).pop();

              // This creates a new dialog on success
              _doWithdraw(
                context,
                address,
                refund,
                withdrawalAmount,
                transactionFee,
              );
            },
            child: SailText.primary14(
              'OK',
            ),
          ),
        ],
      ),
    );
  }

  // TODO: add error case popup
  void _doWithdraw(
    BuildContext context,
    String address,
    String refund,
    double amount,
    double sidechainFee,
  ) async {
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

    // refresh balance, but dont await, so dialog is showed instantly
    unawaited(_balanceProvider.fetch());

    if (!context.mounted) {
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: SailText.primary14(
          'Success',
        ),
        content: SailText.primary14(
          'Submitted withdrawal successfully! TXID: $withdrawalTxid',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: SailText.primary14('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _balanceProvider.removeListener(notifyListeners);
  }
}

const _SidechainFeeFuture = 'sidechainFee';
