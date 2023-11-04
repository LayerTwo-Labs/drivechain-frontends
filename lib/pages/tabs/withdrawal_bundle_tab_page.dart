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
import 'package:sidesail/pages/tabs/dashboard_tab_page.dart';
import 'package:sidesail/widgets/containers/tabs/dashboard_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class WithdrawalBundleTabPage extends StatelessWidget {
  const WithdrawalBundleTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => WithdrawalBundleTabPageViewModel(),
      builder: ((context, viewModel, child) {
        return SailPage(
          title: 'Withdrawal bundles',
          body: SingleChildScrollView(
            child: Column(
              children: [
                DashboardGroup(
                  title: 'Unbundled transactions',
                  children: [
                    SailColumn(
                      spacing: 0,
                      withDivider: true,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: viewModel.nextBundle?.withdrawals
                              .map(
                                (tx) => WithdrawalView(
                                  withdrawal: tx,
                                ),
                              )
                              .toList() ??
                          [],
                    ),
                  ],
                ),
                const SailSpacing(SailStyleValues.padding30),
                DashboardGroup(
                  title: 'Current withdrawal bundle',
                  endWidget: SailText.primary12(
                    [
                      'Created at block height ${viewModel.currentBundle?.blockHeight}',
                      '${viewModel.votes}/${viewModel.votesRequired} votes',
                      '${viewModel.currentBundle?.bundleSize}/${viewModel.currentBundle?.maxBundleSize} vbytes',
                    ].join(', '),
                  ),
                  children: [
                    SailColumn(
                      spacing: 0,
                      withDivider: true,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: viewModel.currentBundle?.withdrawals
                              .map(
                                (tx) => WithdrawalView(withdrawal: tx),
                              )
                              .toList() ??
                          [],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class WithdrawalBundleTabPageViewModel extends BaseViewModel {
  SidechainRPC get _sidechain => GetIt.I.get<SidechainRPC>();
  MainchainRPC get _mainchain => GetIt.I.get<MainchainRPC>();

  final searchController = TextEditingController();

  WithdrawalBundleTabPageViewModel() {
    _startWithdrawalBundleFetch();
  }

  Timer? _withdrawalBundleTimer;

  WithdrawalBundle? currentBundle;
  FutureWithdrawalBundle? nextBundle;

  int? votes;
  final int votesRequired = 131; // higher on mainnet. take into consideration, somehow

  void _fetchWithdrawalBundle() async {
    try {
      currentBundle = await _sidechain.currentWithdrawalBundle();
      nextBundle = await _sidechain.nextWithdrawalBundle();
      votes = await _mainchain.getWithdrawalBundleWorkScore(ThisSidechain.slot, currentBundle!.hash);
    } on RPCException catch (err) {
      if (err.errorCode != RPCError.errNoWithdrawalBundle) {
        rethrow;
      }
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
    super.dispose();
    _withdrawalBundleTimer?.cancel();
  }
}

class WithdrawalView extends StatefulWidget {
  final Withdrawal withdrawal;

  const WithdrawalView({super.key, required this.withdrawal});

  @override
  State<WithdrawalView> createState() => _WithdrawalViewState();
}

class _WithdrawalViewState extends State<WithdrawalView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: SailStyleValues.padding15,
        horizontal: SailStyleValues.padding10,
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleValueView(
            width: 70,
            icon: Tooltip(
              message: 'Unconfirmed',
              child: SailSVG.icon(SailSVGAsset.iconPending, width: 13),
            ),
            copyable: false,
            label: 'TODO',
            value: extractTitle(widget.withdrawal),
          ),
        ],
      ),
    );
  }

  String extractTitle(Withdrawal withdrawal) {
    final title = '${(withdrawal.amountSatoshi / 100000000).toStringAsFixed(8)} SBTC';

    return '$title to ${withdrawal.address}';
  }
}
