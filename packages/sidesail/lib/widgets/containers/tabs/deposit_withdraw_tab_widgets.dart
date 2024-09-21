import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_ethereum.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/rpc/rpc_testchain.dart';
import 'package:sidesail/rpc/rpc_withdrawal_bundle.dart';
import 'package:sidesail/widgets/containers/dashboard_action_modal.dart';
import 'package:stacked/stacked.dart';

class PegOutAction extends StatelessWidget {
  final String? staticAddress;

  const PegOutAction({
    super.key,
    this.staticAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: SailStyleValues.padding05),
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => PegOutViewModel(staticAddress: staticAddress),
        builder: ((context, viewModel, child) {
          return SailColumn(
            spacing: 0,
            children: [
              LargeEmbeddedInput(
                controller: viewModel.bitcoinAddressController,
                hintText: 'Enter a parent chain bitcoin-address',
                autofocus: true,
                disabled: staticAddress != null,
              ),
              LargeEmbeddedInput(
                controller: viewModel.bitcoinAmountController,
                hintText: 'Enter a BTC-amount',
                suffixText: 'BTC',
                bitcoinInput: true,
              ),
              StaticActionField(
                label: 'Parent chain fee',
                value: formatBitcoin((viewModel.mainchainFee ?? 0)),
              ),
              StaticActionField(
                label: '${viewModel.sidechain.rpc.chain.name} fee',
                value: formatBitcoin((viewModel.sidechainFee ?? 0), symbol: viewModel.sidechain.rpc.chain.ticker),
              ),
              StaticActionField(
                label: 'Total amount',
                value: viewModel.totalBitcoinAmount,
              ),
              SailButton.primary(
                'Execute withdraw',
                disabled:
                    viewModel.bitcoinAddressController.text.isEmpty || viewModel.bitcoinAmountController.text.isEmpty,
                loading: viewModel.isBusy,
                size: ButtonSize.regular,
                onPressed: () async {
                  viewModel.executePegOut(context);
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}

class PegOutViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();
  SidechainContainer get sidechain => GetIt.I.get<SidechainContainer>();
  MainchainRPC get _mainchain => GetIt.I.get<MainchainRPC>();

  final bitcoinAddressController = TextEditingController();
  final bitcoinAmountController = TextEditingController();
  String get totalBitcoinAmount => formatBitcoin(
        ((double.tryParse(bitcoinAmountController.text) ?? 0) + (mainchainFee ?? 0) + (sidechainFee ?? 0)),
      );

  double? sidechainFee;
  double? mainchainFee;
  double? get pegOutAmount => double.tryParse(bitcoinAmountController.text);
  double? get maxAmount => max(_balanceProvider.balance - (sidechainFee ?? 0) - (mainchainFee ?? 0), 0);

  final String? staticAddress;
  PegOutViewModel({this.staticAddress}) {
    bitcoinAddressController.addListener(notifyListeners);
    bitcoinAmountController.addListener(_capAmount);
    _balanceProvider.addListener(notifyListeners);

    if (staticAddress != null) {
      bitcoinAddressController.text = staticAddress!;
    }

    init();
  }

  void init() async {
    await Future.wait([estimateSidechainFee(), estimateMainchainFee()]);
  }

  void _capAmount() {
    String currentInput = bitcoinAmountController.text;

    if (maxAmount != null && (double.tryParse(currentInput) != null && double.parse(currentInput) > maxAmount!)) {
      bitcoinAmountController.text = maxAmount.toString();
      bitcoinAmountController.selection =
          TextSelection.fromPosition(TextPosition(offset: bitcoinAmountController.text.length));
    } else {
      notifyListeners();
    }
  }

  void executePegOut(BuildContext context) async {
    setBusy(true);
    onPegOut(context);
    setBusy(false);
  }

  Future<void> estimateSidechainFee() async {
    sidechainFee = await sidechain.rpc.sideEstimateFee();
    notifyListeners();
  }

  Future<void> estimateMainchainFee() async {
    mainchainFee = await _mainchain.estimateFee();
    notifyListeners();
  }

  void onPegOut(BuildContext context) async {
    if (pegOutAmount == null) {
      log.e('withdrawal amount was empty');
      return;
    }
    if (sidechainFee == null) {
      log.e('sidechain fee was empty');
      return;
    }

    final address = bitcoinAddressController.text;

    // Because the function is async, the view might disappear/unmount
    // by the time it's used. The linter doesn't like that, and wants
    // you to check whether the view is mounted before using it
    if (!context.mounted) {
      return;
    }

    _doPegOut(
      context,
      address,
      pegOutAmount!,
      sidechainFee!,
      mainchainFee!,
    );
  }

  void _doPegOut(
    BuildContext context,
    String address,
    double amount,
    double sidechainFee,
    double mainchainFee,
  ) async {
    log.i(
      'doing withdraw: $amount BTC to $address for $sidechainFee SC fee and $mainchainFee MC fee',
    );

    try {
      final withdrawalTxid = await sidechain.rpc.mainSend(
        address,
        amount,
        sidechainFee,
        mainchainFee,
      );

      log.i(
        'pegged out successfully',
      );

      if (!context.mounted) {
        return;
      }

      // refresh balance, but don't await, so dialog is showed instantly
      unawaited(_balanceProvider.fetch());
      // refresh transactions, but don't await, so dialog is showed instantly
      unawaited(_transactionsProvider.fetch());

      await successDialog(
        context: context,
        action: 'Withdraw to parent chain',
        title: 'Submitted withdraw successfully',
        subtitle: 'TXID: $withdrawalTxid',
      );
    } catch (error) {
      log.e('could not execute withdraw: $error', error: error);

      if (!context.mounted) {
        return;
      }

      await errorDialog(
        context: context,
        action: 'Withdraw to parent chain',
        title: 'Could not execute withdraw',
        subtitle: error.toString(),
      );
    }
  }
}

class PegInAction extends StatelessWidget {
  const PegInAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: SailStyleValues.padding05),
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => PegInViewModel(),
        builder: ((context, viewModel, child) {
          return SailColumn(
            spacing: SailStyleValues.padding10,
            children: [
              StaticActionField(
                label: 'Address',
                value: viewModel.pegInAddress ?? '',
                copyable: true,
              ),
              SailButton.primary(
                'Generate new address',
                loading: viewModel.isBusy,
                size: ButtonSize.regular,
                onPressed: () async {
                  await viewModel.generatePegInAddress();
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}

class PegInViewModel extends BaseViewModel {
  SidechainContainer get _sidechain => GetIt.I.get<SidechainContainer>();
  final log = Logger(level: Level.debug);

  String? pegInAddress;

  PegInViewModel() {
    generatePegInAddress();
  }

  Future<void> generatePegInAddress() async {
    setBusy(true);
    try {
      pegInAddress = await _sidechain.rpc.getDepositAddress();
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }
}

class PegInEthAction extends StatelessWidget {
  const PegInEthAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => PegInEthViewModel(),
      builder: ((context, viewModel, child) {
        return DashboardActionModal(
          'Deposit from parent chain',
          endActionButton: SailButton.primary(
            'Deposit funds',
            loading: viewModel.isBusy,
            size: ButtonSize.regular,
            onPressed: () async {
              await viewModel.deposit(context);
            },
          ),
          children: [
            LargeEmbeddedInput(
              controller: viewModel.bitcoinAmountController,
              hintText: 'How much do you want to deposit?',
              suffixText: 'BTC',
              bitcoinInput: true,
            ),
            StaticActionField(
              label: 'Deposit to',
              value: viewModel.pegInAddress ?? '',
              copyable: true,
            ),
            StaticActionField(
              label: '${viewModel.sidechain.rpc.chain.name} fee',
              value: formatBitcoin((viewModel.sidechainFee ?? 0)),
            ),
            StaticActionField(
              label: 'Total amount',
              value: viewModel.totalBitcoinAmount,
            ),
          ],
        );
      }),
    );
  }
}

class PegInEthViewModel extends BaseViewModel {
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  EthereumRPC get _ethRPC => GetIt.I.get<EthereumRPC>();
  SidechainContainer get sidechain => GetIt.I.get<SidechainContainer>();
  final log = Logger(level: Level.debug);

  final bitcoinAmountController = TextEditingController();
  String get totalBitcoinAmount =>
      formatBitcoin(((double.tryParse(bitcoinAmountController.text) ?? 0) + (sidechainFee ?? 0)));

  String? pegInAddress;
  double? sidechainFee;

  PegInEthViewModel() {
    generatePegInAddress();
    bitcoinAmountController.addListener(notifyListeners);
  }

  Future<void> generatePegInAddress() async {
    pegInAddress = await _ethRPC.getDepositAddress();
    sidechainFee = await _ethRPC.sideEstimateFee();
    notifyListeners();
  }

  Future<void> deposit(BuildContext context) async {
    if (sidechainFee == null) {
      log.e('sidechainfee was empty');
      return;
    }

    final amount = (double.tryParse(bitcoinAmountController.text) ?? 0);

    await _ethRPC.deposit(amount, sidechainFee!);

    log.i(
      'doing deposit: $amount BTC to $pegInAddress',
    );

    try {
      final success = await _ethRPC.deposit(
        amount,
        sidechainFee!,
      );

      if (!context.mounted) {
        return;
      }

      // refresh balance, but don't await, so dialog is showed instantly
      unawaited(_balanceProvider.fetch());

      if (!success) {
        throw Exception('got false response');
      }

      await successDialog(
        context: context,
        action: 'Deposit from parent chain',
        title: 'Deposited from parent-chain successfully',
        subtitle: '',
      );
    } catch (error) {
      log.e('could not execute withdraw: $error', error: error);

      if (!context.mounted) {
        return;
      }

      await errorDialog(
        context: context,
        action: 'Deposit from parent chain',
        title: 'Could not deposit from parent-chain',
        subtitle: '$error. Check you have enough balance in your parent-chain wallet.',
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    bitcoinAmountController.removeListener(notifyListeners);
  }
}

class DepositWithdrawHelp extends StatelessWidget {
  SidechainContainer get _sidechain => GetIt.I.get<SidechainContainer>();

  const DepositWithdrawHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return QuestionContainer(
      category: 'Deposit & Withdraw help',
      children: [
        const QuestionTitle('What are deposits and withdrawals?'),
        QuestionText(
          'You are currently connected to two blockchains. Bitcoin Core with BIP 300+301, and a sidechain called ${_sidechain.rpc.chain.name}.',
        ),
        const QuestionText(
          'Deposits and withdrawals move bitcoin from one chain to the other. A deposit adds bitcoin to the sidechain, and a withdrawal removes bitcoin from the sidechain.',
        ),
        const QuestionText(
          'When we use the word deposit or withdraw in this application, we always refer to moving coins across chains.',
        ),
        const QuestionText(
          "Only after you have deposited coins to the sidechain, can you start using it's special features! There's a special rpc called createsidechaindeposit that lets you deposit from your parent chain wallet.",
        ),
      ],
    );
  }
}

class EasyRegtestDeposit extends StatelessWidget {
  final VoidCallback depositNudgeAction;

  AppRouter get router => GetIt.I.get<AppRouter>();

  const EasyRegtestDeposit({
    super.key,
    required this.depositNudgeAction,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ZCashWidgetTitleViewModel(),
      builder: ((context, viewModel, child) {
        if (viewModel.balance != 0) {
          return Container();
        }

        return SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            SailButton.primary(
              'Easy Deposit',
              onPressed: () async {
                try {
                  await viewModel.easyDeposit();
                } catch (err) {
                  if (!context.mounted) {
                    return;
                  }

                  await errorDialog(
                    context: context,
                    action: 'Deposit coins',
                    title: "Could not easy-deposit coins. Try pegging in manually with 'createsidechaindeposit'",
                    subtitle: err.toString(),
                  );
                }
              },
              loading: viewModel.isBusy,
              size: ButtonSize.small,
            ),
            SailText.secondary12(
              'Click the button to deposit coins to your sidechain',
            ),
            Expanded(child: Container()),
          ],
        );
      }),
    );
  }
}

class ZCashWidgetTitleViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  MainchainRPC get _mainchain => GetIt.I.get<MainchainRPC>();
  SidechainContainer get _sidechainContainer => GetIt.I.get<SidechainContainer>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();

  double get balance => _balanceProvider.balance + _balanceProvider.pendingBalance;

  bool showAll = false;

  ZCashWidgetTitleViewModel() {
    _balanceProvider.addListener(notifyListeners);
  }

  Future<void> easyDeposit() async {
    setBusy(true);
    // step 1, get mainchain balance
    final balance = await _mainchain.getBalance();
    final confirmedBalance = balance.$1;

    // step 2, get sidechain deposit address
    final depositAddress = await _sidechainContainer.rpc.getDepositAddress();

    // step 3, query createsidechaindeposit with the current chain params
    final _ = await _mainchain.createSidechainDeposit(
      _sidechainContainer.rpc.chain.slot,
      depositAddress,
      confirmedBalance / 3 * 2,
    );

    // step 4 confirm the deposit
    await _mainchain.generate(22);

    setBusy(false);
  }

  @override
  void dispose() {
    super.dispose();
    _balanceProvider.removeListener(notifyListeners);
  }
}

class WithdrawalExplorer extends StatelessWidget {
  const WithdrawalExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => WithdrawalBundleViewViewModel(),
      builder: ((context, viewModel, child) {
        return SingleChildScrollView(
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
        );
      }),
    );
  }
}

class WithdrawalBundleViewViewModel extends BaseViewModel {
  TestchainRPC get _sidechain => GetIt.I.get<TestchainRPC>();
  MainchainRPC get _mainchain => GetIt.I.get<MainchainRPC>();

  final searchController = TextEditingController();

  WithdrawalBundleViewViewModel() {
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

class UnbundledWithdrawalView extends StatelessWidget {
  const UnbundledWithdrawalView({
    super.key,
    required this.withdrawal,
  });

  final Withdrawal withdrawal;

  @override
  Widget build(BuildContext context) {
    return ExpandableListEntry(
      entry: SingleValueContainer(
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
        value: '${formatBitcoin(satoshiToBTC(withdrawal.amountSatoshi))} BTC to ${withdrawal.address}',
      ),
      expandedEntry: ExpandedUnbundledWithdrawalView(
        withdrawal: withdrawal,
      ),
    );
  }
}

const int bundleVotesRequired = 13150; // higher on mainnet. take into consideration, somehow

class BundleView extends StatelessWidget {
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

  String get ticker => GetIt.I.get<SidechainContainer>().rpc.chain.ticker;

  @override
  Widget build(BuildContext context) {
    final (tooltipMessage, icon) = statusAndIcon();

    return ExpandableListEntry(
      entry: SingleValueContainer(
        width: bundleViewWidth,
        icon: Tooltip(
          message: tooltipMessage,
          child: SailSVG.icon(icon, width: 13),
        ),
        copyable: false,
        label: bundle.status == BundleStatus.failed ? 'Failed' : '$votes/$bundleVotesRequired ACKs',
        value: 'Withdraw ${formatBitcoin(bundle.totalBitcoin)} BTC in ${bundle.withdrawals.length} transactions',
      ),
      expandedEntry: ExpandedBundleView(timesOutIn: timesOutIn, bundle: bundle),
    );
  }

  String extractTitle(Withdrawal withdrawal) {
    final title = '${formatBitcoin((withdrawal.amountSatoshi / 100000000))} $ticker';

    return '$title to ${withdrawal.address}';
  }
}

const bundleViewWidth = 135.0;

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
        'total amount': formatBitcoin(bundle.totalBitcoin),
        'withdrawal count': bundle.withdrawals.length,
        'created at height': bundle.blockHeight,
        'total fees': formatBitcoin(bundle.totalFeesBitcoin),
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
        'hashblindtx': withdrawal.hashBlindTx,
        'amount': formatBitcoin(satoshiToBTC(withdrawal.amountSatoshi)),
        'amountmainchainfee': formatBitcoin(satoshiToBTC(withdrawal.mainchainFeesSatoshi)),
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
