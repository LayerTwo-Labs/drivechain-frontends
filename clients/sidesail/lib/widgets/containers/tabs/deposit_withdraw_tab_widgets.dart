import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/rpc/rpc_testchain.dart';
import 'package:sidesail/rpc/rpc_withdrawal_bundle.dart';
import 'package:stacked/stacked.dart';

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
          "Only after you have deposited coins to the sidechain, can you start using it's special features! If you're a developer and know your way around a command line, there's a special rpc called createsidechaindeposit that lets you deposit from your parent chain wallet.",
        ),
      ],
    );
  }
}

class ZCashWidgetTitleViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();

  double get balance => _balanceProvider.balance + _balanceProvider.pendingBalance;

  bool showAll = false;

  ZCashWidgetTitleViewModel() {
    _balanceProvider.addListener(notifyListeners);
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
      builder: ((context, model, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              SailRow(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: SailStyleValues.padding10,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SailStyleValues.padding32,
                      vertical: SailStyleValues.padding16,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: SailTextField(
                        controller: model.searchController,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding04),
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
                widgetTrailing: SailText.secondary13('${model.unbundledTransactions.length}'),
                children: [
                  SailColumn(
                    spacing: 0,
                    withDivider: true,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (model.unbundledTransactions).map((e) => UnbundledWithdrawalView(withdrawal: e)).toList(),
                  ),
                ],
              ),
              const SailSpacing(SailStyleValues.padding32),
              DashboardGroup(
                title: 'Bundle history',
                widgetTrailing: SailText.secondary13('${model.bundles.length} bundle(s)'),
                children: [
                  SailColumn(
                    spacing: 0,
                    withDivider: true,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...[
                        if (!model.hasDoneInitialFetch) LoadingIndicator.overlay(),
                        if (model.bundleCount == 0)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(SailStyleValues.padding32),
                              child: SailText.primary20('No withdrawal bundle'),
                            ),
                          ),
                      ],
                      ...model.bundles.map(
                        (bundle) => BundleView(
                          bundle: bundle,
                          timesOutIn: model.timesOutIn(bundle.hash),
                          votes: model.votes(bundle.hash),
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
  final searchController = TextEditingController();

  WithdrawalBundleViewViewModel() {
    _startWithdrawalBundleFetch();
  }

  Timer? _withdrawalBundleTimer;

  bool hasDoneInitialFetch = false;

  WithdrawalBundle? currentBundle;
  int? votesCurrentBundle;

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

  final List<Withdrawal> _unbundledTransactions = [];
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

    throw 'received hash for unknown bundle: $hash';
  }

  /// Block count until a bundle times out
  int timesOutIn(String hash) {
    return 0;
  }

  void _fetchWithdrawalBundle() async {
    try {
      return;
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

class DepositWithdrawTabViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();
  SidechainContainer get _sidechain => GetIt.I.get<SidechainContainer>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();

  final bitcoinAddressController = TextEditingController();
  final bitcoinAmountController = TextEditingController();
  final labelController = TextEditingController();

  String? depositAddress;
  double? sidechainFee;
  double? mainchainFee;

  double? get pegAmount => double.tryParse(bitcoinAmountController.text);
  double? get maxAmount => max(_balanceProvider.balance - (sidechainFee ?? 0) - (mainchainFee ?? 0), 0);

  String get totalBitcoinAmount => formatBitcoin(
        ((double.tryParse(bitcoinAmountController.text) ?? 0) + (mainchainFee ?? 0) + (sidechainFee ?? 0)),
      );

  DepositWithdrawTabViewModel() {
    _initControllers();
    _initFees();
    _transactionsProvider.addListener(notifyListeners);
    _balanceProvider.addListener(notifyListeners);
    generateDepositAddress();
  }

  void _initControllers() {
    bitcoinAddressController.addListener(notifyListeners);
    bitcoinAmountController.addListener(_capAmount);
  }

  Future<void> _initFees() async {
    await Future.wait([estimateSidechainFee(), estimateMainchainFee()]);
  }

  void _capAmount() {
    String currentInput = bitcoinAmountController.text;
    if (maxAmount != null && (double.tryParse(currentInput) != null && double.parse(currentInput) > maxAmount!)) {
      bitcoinAmountController.text = maxAmount.toString();
      bitcoinAmountController.selection = TextSelection.fromPosition(
        TextPosition(offset: bitcoinAmountController.text.length),
      );
    }
    notifyListeners();
  }

  Future<void> estimateSidechainFee() async {
    sidechainFee = await _sidechain.rpc.sideEstimateFee();
    notifyListeners();
  }

  Future<void> estimateMainchainFee() async {
    mainchainFee = 0.0001;
    notifyListeners();
  }

  Future<void> generateDepositAddress() async {
    setBusy(true);
    try {
      depositAddress = await _sidechain.rpc.getDepositAddress();
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> executePegOut(BuildContext context) async {
    if (pegAmount == null || sidechainFee == null) {
      log.e('Invalid peg out parameters');
      return;
    }

    setBusy(true);
    try {
      final withdrawalTxid = await _sidechain.rpc.mainSend(
        bitcoinAddressController.text,
        pegAmount!,
        sidechainFee!,
        mainchainFee!,
      );

      if (!context.mounted) return;

      unawaited(_balanceProvider.fetch());
      unawaited(_transactionsProvider.fetch());

      await successDialog(
        context: context,
        action: 'Withdraw to parent chain',
        title: 'Submitted withdraw successfully',
        subtitle: 'TXID: $withdrawalTxid',
      );
    } catch (error) {
      log.e('Could not execute withdraw', error: error);
      if (!context.mounted) return;

      await errorDialog(
        context: context,
        action: 'Withdraw to parent chain',
        title: 'Could not execute withdraw',
        subtitle: error.toString(),
      );
    } finally {
      setBusy(false);
    }
  }

  void castHelp(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const DepositWithdrawHelp();
      },
    );
  }

  @override
  void dispose() {
    bitcoinAddressController.dispose();
    bitcoinAmountController.dispose();
    labelController.dispose();
    _transactionsProvider.removeListener(notifyListeners);
    _balanceProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

class DepositTab extends StatelessWidget {
  const DepositTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => DepositWithdrawTabViewModel(),
      builder: (context, model, child) {
        return Column(
          children: [
            SailRow(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: SailStyleValues.padding08,
              children: [
                Expanded(
                  child: SailRawCard(
                    title: 'Deposit from Parent Chain',
                    subtitle: 'Deposit coins to the sidechain',
                    widgetHeaderEnd: HelpButton(onPressed: () async => model.castHelp(context)),
                    child: SailColumn(
                      spacing: SailStyleValues.padding16,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (model.isBusy)
                          const Center(child: LoadingIndicator())
                        else ...[
                          SailRow(
                            spacing: SailStyleValues.padding08,
                            children: [
                              Expanded(
                                child: SailTextField(
                                  controller: TextEditingController(text: model.depositAddress),
                                  hintText: 'Generating deposit address...',
                                  readOnly: true,
                                ),
                              ),
                              if (model.depositAddress != null)
                                CopyButton(
                                  text: model.depositAddress!,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (model.depositAddress != null && width > 500)
                  SizedBox(
                    width: 180,
                    child: SailRawCard(
                      padding: true,
                      child: QrImageView(
                        padding: EdgeInsets.zero,
                        eyeStyle: QrEyeStyle(
                          color: theme.colors.textSecondary,
                          eyeShape: QrEyeShape.square,
                        ),
                        dataModuleStyle: QrDataModuleStyle(color: theme.colors.textSecondary),
                        data: model.depositAddress!,
                        version: QrVersions.auto,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class WithdrawTab extends ViewModelWidget<DepositWithdrawTabViewModel> {
  const WithdrawTab({super.key});

  @override
  Widget build(BuildContext context, DepositWithdrawTabViewModel viewModel) {
    return SailRawCard(
      title: 'Withdraw to Parent Chain',
      subtitle: 'Withdraw bitcoin from the sidechain to the parent chain',
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: SailStyleValues.padding08,
            children: [
              Expanded(
                child: SailTextField(
                  label: 'Pay To',
                  controller: viewModel.bitcoinAddressController,
                  hintText: 'Enter a L1 bitcoin-address (e.g. 1NS17iag9jJgTHD1VXjvLCEnZuQ3rJDE9L)',
                  size: TextFieldSize.small,
                ),
              ),
              QtIconButton(
                tooltip: 'Paste from clipboard',
                onPressed: () async {
                  try {
                    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                    if (clipboardData?.text != null) {
                      viewModel.bitcoinAddressController.text = clipboardData!.text!;
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    showSnackBar(context, 'Error accessing clipboard');
                  }
                },
                icon: Icon(
                  Icons.content_paste_rounded,
                  size: 20.0,
                  color: context.sailTheme.colors.text,
                ),
              ),
              const SizedBox(width: 4.0),
            ],
          ),
          const SizedBox(height: SailStyleValues.padding16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SailRow(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: SailStyleValues.padding08,
                      children: [
                        Expanded(
                          child: NumericField(
                            label: 'Amount',
                            controller: viewModel.bitcoinAmountController,
                            suffixWidget: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  if (viewModel.maxAmount != null) {
                                    viewModel.bitcoinAmountController.text = viewModel.maxAmount.toString();
                                  }
                                },
                                child: SailText.primary15(
                                  'MAX',
                                  color: context.sailTheme.colors.orange,
                                  underline: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SailStyleValues.padding16),
                    SailTextField(
                      label: 'Label (optional)',
                      controller: viewModel.labelController,
                      hintText: 'Enter a label',
                      size: TextFieldSize.small,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SailStyleValues.padding16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QtButton(
                    label: 'Send',
                    onPressed: () => viewModel.executePegOut(context),
                    size: ButtonSize.small,
                  ),
                  const SizedBox(width: SailStyleValues.padding08),
                  QtButton(
                    style: SailButtonStyle.secondary,
                    label: 'Clear All',
                    onPressed: () async {
                      viewModel.bitcoinAddressController.clear();
                      viewModel.bitcoinAmountController.clear();
                      viewModel.labelController.clear();
                    },
                    size: ButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
