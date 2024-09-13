import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_testchain.dart';
import 'package:sidesail/rpc/rpc_withdrawal_bundle.dart';
import 'package:sidesail/widgets/containers/tabs/deposit_withdraw_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class WithdrawalExplorerTabPage extends StatelessWidget {
  const WithdrawalExplorerTabPage({super.key});

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
                  widgetTrailing: SailText.secondary13('${viewModel.unbundledTransactions.length}'),
                  children: [
                    SailColumn(
                      spacing: 0,
                      withDivider: true,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          (viewModel.unbundledTransactions).map((e) => UnbundledWithdrawalView(withdrawal: e)).toList(),
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
          .where((element) => searchController.text == '' || element.hash.contains(searchController.text))
          .sortedByCompare(
            (
              b1,
            ) =>
                b1.blockHeight,
            (a, b) => a.compareTo(b),
          )
          .reversed; // we want the newest first!

  List<Withdrawal> _unbundledTransactions = [];
  Iterable<Withdrawal> get unbundledTransactions => _unbundledTransactions
      .where((element) => searchController.text == '' || element.hashBlindTx.contains(searchController.text));

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

      _unbundledTransactions = (await nextFut).withdrawals;
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
