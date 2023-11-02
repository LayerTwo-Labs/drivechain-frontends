import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
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
          return SailText.primary14(
            'Withdrawal bundle status: ${viewModel.withdrawalBundleStatus}',
          );
        }),
      ),
    );
  }
}

class WithdrawalBundleTabPageViewModel extends BaseViewModel {
  SidechainRPC get _rpc => GetIt.I.get<SidechainRPC>();

  WithdrawalBundleTabPageViewModel() {
    _startWithdrawalBundleFetch();
  }

  Timer? _withdrawalBundleTimer;
  String withdrawalBundleStatus = 'unknown';

  void _startWithdrawalBundleFetch() {
    _withdrawalBundleTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final state = await _rpc.fetchWithdrawalBundleStatus();
      withdrawalBundleStatus = state;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _withdrawalBundleTimer?.cancel();
    super.dispose();
  }
}
