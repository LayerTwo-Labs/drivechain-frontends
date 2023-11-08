import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sail_ui/widgets/loading_indicator.dart';
import 'package:sidesail/bitcoin.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_testchain.dart';
import 'package:sidesail/rpc/rpc_withdrawal_bundle.dart';
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
          body: SingleChildScrollView(
            child: Column(
              children: [
                SailRow(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: SailStyleValues.padding10,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SailStyleValues.padding30,
                        vertical: SailStyleValues.padding15,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: SailTextField(
                          controller: viewModel.searchController,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding05),
                            child: SailSVG.icon(SailSVGAsset.iconSearch),
                          ),
                          prefixIconConstraints: const BoxConstraints(maxHeight: 20),
                          hintText: 'Search for TXID',
                        ),
                      ),
                    ),
                    // eat up the rest of the space by adding an empty expanded
                    Expanded(
                      child: Container(),
                    ),
                  ],
                ),
                DashboardGroup(
                  title: 'Unbundled transactions',
                  widgetTrailing: SailText.secondary13('${viewModel.nextBundle?.withdrawals.length ?? 0}'),
                  children: [
                    SailColumn(
                      spacing: 0,
                      withDivider: true,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (viewModel.nextBundle?.withdrawals ?? [])
                          .map((e) => UnbundledWithdrawalView(withdrawal: e))
                          .toList(),
                    ),
                  ],
                ),
                const SailSpacing(SailStyleValues.padding30),
                DashboardGroup(
                  title: 'Bundle history',
                  widgetTrailing: SailText.secondary13('${viewModel.bundleCount} bundle(s)'),
                  children: [
                    SailColumn(
                      spacing: 0,
                      withDivider: true,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!viewModel.hasDoneInitialFetch) LoadingIndicator.overlay(),
                        viewModel.currentBundle == null
                            // TODO: proper no bundle view
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(SailStyleValues.padding30),
                                  child: SailText.primary20('No withdrawal bundle'),
                                ),
                              )
                            : BundleView(
                                bundle: viewModel.currentBundle!,
                                votes: viewModel.votes ?? 0,
                              ),
                      ],
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
  TestchainRPC get _sidechain => GetIt.I.get<TestchainRPC>();
  MainchainRPC get _mainchain => GetIt.I.get<MainchainRPC>();

  final searchController = TextEditingController();

  WithdrawalBundleTabPageViewModel() {
    _startWithdrawalBundleFetch();
  }

  Timer? _withdrawalBundleTimer;

  bool hasDoneInitialFetch = false;
  WithdrawalBundle? currentBundle;
  FutureWithdrawalBundle? nextBundle;

  int? votes;

  // TODO: add support for historic bundles
  int get bundleCount => currentBundle == null ? 0 : 1;

  void _fetchWithdrawalBundle() async {
    try {
      currentBundle = await _sidechain.mainCurrentWithdrawalBundle();
      nextBundle = await _sidechain.mainNextWithdrawalBundle();
      votes = await _mainchain.getWithdrawalBundleWorkScore(_sidechain.chain.slot, currentBundle!.hash);
      hasDoneInitialFetch = true;
    } on RPCException catch (err) {
      if (err.errorCode != TestchainRPCError.errNoWithdrawalBundle) {
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

class UnbundledWithdrawalView extends StatefulWidget {
  const UnbundledWithdrawalView({
    super.key,
    required this.withdrawal,
  });

  final Withdrawal withdrawal;

  @override
  State<UnbundledWithdrawalView> createState() => _UnbundledWithdrawalViewState();
}

class _UnbundledWithdrawalViewState extends State<UnbundledWithdrawalView> {
  bool expanded = false;

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
          SailScaleButton(
            onPressed: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: SingleValueContainer(
              width: bundleViewWidth,
              icon: Tooltip(
                message: 'Pending',
                child: SailSVG.icon(
                  SailSVGAsset.iconPendingHalf,
                  width: 13,
                ),
              ),
              copyable: false,
              value:
                  '${satoshiToBTC(widget.withdrawal.amountSatoshi).toStringAsFixed(8)} BTC to ${widget.withdrawal.address}',
            ),
          ),
          if (expanded)
            ExpandedUnbundledWithdrawalView(
              withdrawal: widget.withdrawal,
            ),
        ],
      ),
    );
  }
}

class BundleView extends StatefulWidget {
  final WithdrawalBundle bundle;
  bool get confirmed => votes >= votesRequired;

  final int votes;
  final int votesRequired = 131; // higher on mainnet. take into consideration, somehow

  const BundleView({
    super.key,
    required this.votes,
    required this.bundle,
  });

  @override
  State<BundleView> createState() => _BundleViewState();
}

class _BundleViewState extends State<BundleView> {
  bool expanded = false;

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
          SailScaleButton(
            onPressed: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: SingleValueContainer(
              width: bundleViewWidth,
              icon: Tooltip(
                message: widget.confirmed ? 'Final' : 'Pending',
                child: SailSVG.icon(
                  widget.confirmed ? SailSVGAsset.iconConfirmed : SailSVGAsset.iconPendingHalf,
                  width: 13,
                ),
              ),
              copyable: false,
              label: '${widget.votes}/${widget.votesRequired} ACKs',
              value:
                  'Peg-out of ${widget.bundle.totalBitcoin.toStringAsFixed(8)} BTC in ${widget.bundle.withdrawals.length} transactions',
            ),
          ),
          if (expanded) ExpandedBundleView(bundle: widget.bundle),
        ],
      ),
    );
  }

  String extractTitle(Withdrawal withdrawal) {
    final title = '${(withdrawal.amountSatoshi / 100000000).toStringAsFixed(8)} SBTC';

    return '$title to ${withdrawal.address}';
  }
}

const bundleViewWidth = 130.0;

class ExpandedBundleView extends StatelessWidget {
  final WithdrawalBundle bundle;

  const ExpandedBundleView({
    super.key,
    required this.bundle,
  });

  // https://github.com/LayerTwo-Labs/testchain/blob/ba78df157fcb9f85d898f65db43c2842ab9473ff/src/policy/corepolicy.h#L31-L32
  static const int maxStandardTxWeight = 400000;

  // https://github.com/LayerTwo-Labs/testchain/blob/ba78df157fcb9f85d898f65db43c2842ab9473ff/src/policy/corepolicy.h#L25
  static const int witnessScaleFactor = 4;

  // https://github.com/LayerTwo-Labs/testchain/blob/ba78df157fcb9f85d898f65db43c2842ab9473ff/src/policy/corepolicy.h#L25
  static const double maxWeight = (maxStandardTxWeight / witnessScaleFactor) / 2;

  Map<String, dynamic> get _values => {
        'block hash': bundle.hash,
        'total amount': '${bundle.totalBitcoin.toStringAsFixed(8)} BTC',
        'withdrawal count': bundle.withdrawals.length,
        'created at height': bundle.blockHeight,
        'total fees': '${bundle.totalFeesBitcoin.toStringAsFixed(8)} BTC',
        'total size': '${bundle.bundleSize}/${maxWeight.toInt()} weight units',
      };

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding08,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _values.keys.map((
        key,
      ) {
        return SingleValueContainer(
          label: key,
          value: _values[key],
          width: bundleViewWidth,
        );
      }).toList(),
    );
  }
}

class ExpandedUnbundledWithdrawalView extends StatelessWidget {
  final Withdrawal withdrawal;

  const ExpandedUnbundledWithdrawalView({
    super.key,
    required this.withdrawal,
  });

  Map<String, dynamic> get _values => {
        'txid': withdrawal.hashBlindTx,
        'amount': '${satoshiToBTC(withdrawal.amountSatoshi).toStringAsFixed(8)} BTC',
        'mainchain fee': '${satoshiToBTC(withdrawal.mainchainFeesSatoshi).toStringAsFixed(8)} BTC',
      };

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding08,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _values.keys.map((
        key,
      ) {
        return SingleValueContainer(
          label: key,
          value: _values[key],
          width: bundleViewWidth,
        );
      }).toList(),
    );
  }
}
