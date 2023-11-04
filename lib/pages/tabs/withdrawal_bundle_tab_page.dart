import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/config/this_sidechain.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/rpc/rpc_withdrawal_bundle.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class WithdrawalBundleTabPage extends StatelessWidget {
  const WithdrawalBundleTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SailPage(
      title: 'Withdrawal bundles',
      body: ViewModelBuilder.reactive(
        viewModelBuilder: () => WithdrawalBundleTabPageViewModel(),
        builder: ((context, viewModel, child) {
          return SailText.primary13(
            'Withdrawal bundle status: ${viewModel.message}',
          );
        }),
      ),
    );
  }
}

class WithdrawalBundleTabPageViewModel extends BaseViewModel {
  SidechainRPC get _sidechain => GetIt.I.get<SidechainRPC>();
  MainchainRPC get _mainchain => GetIt.I.get<MainchainRPC>();

  WithdrawalBundleTabPageViewModel() {
    _startWithdrawalBundleFetch();
  }

  Timer? _withdrawalBundleTimer;

  String? message;

  WithdrawalBundle? currentBundle;
  FutureWithdrawalBundle? nextBundle;

  int? votes;
  final int votesRequired = 131; // higher on mainnet. take into consideration, somehow

  void _fetchWithdrawalBundle() async {
    try {
      currentBundle = await _sidechain.currentWithdrawalBundle();
      nextBundle = await _sidechain.nextWithdrawalBundle();
      votes = await _mainchain.getWithdrawalBundleWorkScore(ThisSidechain.slot, currentBundle!.hash);
      message = 'lookie, a bundle';
    } on RPCException catch (err) {
      if (err.errorCode != RPCError.errNoWithdrawalBundle) {
        rethrow;
      }
      message = 'No withdrawal bundle created. Need at least 10 withdrawals!';
    } finally {
      notifyListeners();
    }
  }

  void _startWithdrawalBundleFetch() {
    _withdrawalBundleTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _fetchWithdrawalBundle();
    });
  }

  @override
  void dispose() {
    _withdrawalBundleTimer?.cancel();
    super.dispose();
  }
}
