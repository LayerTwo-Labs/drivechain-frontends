import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
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
                  widgetTrailing: SailText.secondary13('${viewModel.bundles.length} bundle(s)'),
                  children: [
                    SailColumn(
                      spacing: 0,
                      withDivider: true,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...[
                          if (!viewModel.hasDoneInitialFetch) LoadingIndicator.overlay(),
                          // TODO: proper no bundle view
                          if (viewModel.bundleCount == 0)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(SailStyleValues.padding30),
                                child: SailText.primary20('No withdrawal bundle'),
                              ),
                            ),
                        ],
                        ...viewModel.bundles.map(
                          (bundle) => BundleView(
                            bundle: bundle,
                            timesOutIn: viewModel.timesOutIn(bundle.hash),
                            votes: viewModel.votes(bundle.hash),
                          ),
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
  int? votesCurrentBundle;

  List<MainchainWithdrawalStatus> statuses = [];
  List<WithdrawalBundle> successfulBundles = [];
  List<WithdrawalBundle> failedBundles = [];

  int get bundleCount => successfulBundles.length + failedBundles.length + (currentBundle != null ? 1 : 0);
  Iterable<WithdrawalBundle> get bundles => [
        if (currentBundle != null) currentBundle!,
        ...successfulBundles,
        ...failedBundles,
      ]
          .sortedByCompare(
            (
              b1,
            ) =>
                b1.blockHeight,
            (a, b) => a.compareTo(b),
          )
          .reversed; // we want the newest first!

  FutureWithdrawalBundle? nextBundle;

  int votes(String hash) {
    bool byHash(WithdrawalBundle bundle) => bundle.hash == hash;

    if (successfulBundles.firstWhereOrNull(byHash) != null) {
      return bundleVotesRequired;
    }

    if (failedBundles.firstWhereOrNull(byHash) != null) {
      return 0;
    }

    if (hash == currentBundle?.hash) {
      return votesCurrentBundle ?? 0;
    }

    // TODO; return 0 zero here?
    throw 'received hash for unknown bundle: $hash';
  }

  /// Block count until a bundle times out
  int timesOutIn(String hash) {
    final stat = statuses.firstWhereOrNull((element) => element.hash == hash);
    return stat?.blocksLeft ?? 0;
  }

  void _fetchWithdrawalBundle() async {
    try {
      final statusesFut = _mainchain.listWithdrawalStatus(_sidechain.chain.slot);
      final currentFut = _sidechain.mainCurrentWithdrawalBundle();
      final rawSuccessfulBundlesFut = _mainchain.listSpentWithdrawals();
      final rawFailedBundlesFut = _mainchain.listFailedWithdrawals();
      final nextFut = _sidechain.mainNextWithdrawalBundle();

      statuses = await statusesFut;
      final rawSuccessfulBundles = await rawSuccessfulBundlesFut;
      final rawFailedBundles = await rawFailedBundlesFut;

      bool removeOtherChains(MainchainWithdrawal w) => w.sidechain == _sidechain.chain.slot;
      Future<WithdrawalBundle> Function(MainchainWithdrawal w) getBundle(BundleStatus status) =>
          (MainchainWithdrawal w) => _sidechain.lookupWithdrawalBundle(w.hash, status);

      // Cooky town: passing in a status parameter to this...
      final successfulBundlesFut = Future.wait(
        rawSuccessfulBundles.where(removeOtherChains).map(getBundle(BundleStatus.success)),
      );

      final failedBundlesFut = Future.wait(
        rawFailedBundles.where(removeOtherChains).map(getBundle(BundleStatus.failed)),
      );

      successfulBundles = await successfulBundlesFut;
      failedBundles = await failedBundlesFut;

      currentBundle = await currentFut.then((bundle) {
        // `testchain-cli getwithdrawalbundle` continues to return the most recent bundle, also
        // after it shows up in `drivechain-cli listspentwithdrawals/listfailedwithdrawals`.
        // Filter that out, so it doesn't show up twice.
        final allBundles = [...successfulBundles, ...failedBundles];
        if (allBundles.firstWhereOrNull((success) => success.hash == (bundle?.hash ?? '')) != null) {
          return null;
        }
        return bundle;
      });

      if (currentBundle != null) {
        votesCurrentBundle = await _mainchain.getWithdrawalBundleWorkScore(_sidechain.chain.slot, currentBundle!.hash);
      }

      nextBundle = await nextFut;
    } on RPCException catch (err) {
      if (err.errorCode != TestchainRPCError.errNoWithdrawalBundle) {
        rethrow;
      }
    } finally {
      hasDoneInitialFetch = true;
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
              label: '',
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

const int bundleVotesRequired = 131; // higher on mainnet. take into consideration, somehow

class BundleView extends StatefulWidget {
  final WithdrawalBundle bundle;

  (String, SailSVGAsset) statusAndIcon() {
    switch (bundle.status) {
      case BundleStatus.pending:
        return ('Pending', SailSVGAsset.iconPendingHalf);

      case BundleStatus.failed:
        return ('Failed', SailSVGAsset.iconFailed);

      case BundleStatus.success:
        return ('Final', SailSVGAsset.iconSuccess);
    }
  }

  final int votes;

  /// Blocks left until the bundle times out.
  final int timesOutIn;

  const BundleView({
    super.key,
    required this.timesOutIn,
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
    final (tooltipMessage, icon) = widget.statusAndIcon();
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
                message: tooltipMessage,
                child: SailSVG.icon(icon, width: 13),
              ),
              copyable: false,
              label:
                  widget.bundle.status == BundleStatus.failed ? 'Failed' : '${widget.votes}/$bundleVotesRequired ACKs',
              value:
                  'Peg-out of ${widget.bundle.totalBitcoin.toStringAsFixed(8)} BTC in ${widget.bundle.withdrawals.length} transactions',
            ),
          ),
          if (expanded) ExpandedBundleView(timesOutIn: widget.timesOutIn, bundle: widget.bundle),
        ],
      ),
    );
  }

  String extractTitle(Withdrawal withdrawal) {
    final title = '${(withdrawal.amountSatoshi / 100000000).toStringAsFixed(8)} SBTC';

    return '$title to ${withdrawal.address}';
  }
}

const bundleViewWidth = 160.0;

class ExpandedBundleView extends StatelessWidget {
  final WithdrawalBundle bundle;
  final int timesOutIn;

  const ExpandedBundleView({
    super.key,
    required this.timesOutIn,
    required this.bundle,
  });

  // https://github.com/LayerTwo-Labs/testchain/blob/ba78df157fcb9f85d898f65db43c2842ab9473ff/src/policy/corepolicy.h#L31-L32
  static const int maxStandardTxWeight = 400000;

  // https://github.com/LayerTwo-Labs/testchain/blob/ba78df157fcb9f85d898f65db43c2842ab9473ff/src/policy/corepolicy.h#L25
  static const int witnessScaleFactor = 4;

  // https://github.com/LayerTwo-Labs/testchain/blob/ba78df157fcb9f85d898f65db43c2842ab9473ff/src/policy/corepolicy.h#L25
  static const double maxWeight = (maxStandardTxWeight / witnessScaleFactor) / 2;

  Map<String, dynamic> get _values => {
        if (bundle.status == BundleStatus.pending) 'blocks until timeout': timesOutIn,
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
