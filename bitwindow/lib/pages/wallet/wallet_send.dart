import 'dart:io';
import 'dart:math';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/main.dart';
import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/providers/coin_selection_provider.dart';
import 'package:bitwindow/pages/wallet/widgets/fee_rate_chart.dart';
import 'package:bitwindow/utils/bitcoin_uri.dart';
import 'package:bitwindow/signing/psbt_signer.dart';
import 'package:bitwindow/signing/sign_and_broadcast.dart';
import 'package:bitwindow/widgets/multisig_sign_modal.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:bitwindow/utils/coin_selection.dart';
import 'package:bitwindow/utils/explorer_url.dart';
import 'package:bitwindow/utils/fee_estimation.dart';
import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart' show EstimateSmartFeeRequest;
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart' as pb;
import 'package:sail_ui/gen/wallet/v1/wallet.pbserver.dart' hide CoinSelectionStrategy;
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class SendTab extends ViewModelWidget<SendPageViewModel> {
  const SendTab({super.key});

  @override
  Widget build(BuildContext context, SendPageViewModel viewModel) {
    return SingleChildScrollView(
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        children: [
          PayFromAndFeeCard(),
          PayToCard(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SailButton(
                label: 'Send',
                onPressed: () => viewModel.sendTransaction(context),
              ),
              const SizedBox(width: SailStyleValues.padding08),
              SailButton(
                variant: ButtonVariant.secondary,
                label: 'External signer (airgap)',
                onPressed: () => _externalSign(context, viewModel, AirgapPsbtSigner()),
              ),
              const SizedBox(width: SailStyleValues.padding08),
              if (viewModel.isHardwareWallet) ...[
                SailButton(
                  variant: ButtonVariant.secondary,
                  label: 'Sign with ${viewModel.hardwareDeviceType}',
                  onPressed: () => _externalSign(
                    context,
                    viewModel,
                    HwiPsbtSigner(
                      wmpb.HardwareDeviceSelector(
                        type: viewModel.hardwareDeviceType,
                        fingerprint: viewModel.hardwareFingerprint,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SailStyleValues.padding08),
              ],
              SailButton(
                variant: ButtonVariant.outline,
                label: 'Clear All',
                onPressed: viewModel.clearAll,
              ),
            ],
          ),
          SailSpacing(SailStyleValues.padding64),
        ],
      ),
    );
  }

  /// Builds the unsigned PSBT, signs it with [signer], then broadcasts.
  Future<void> _externalSign(BuildContext context, SendPageViewModel viewModel, PsbtSigner signer) async {
    final walletId = GetIt.I<WalletReaderProvider>().activeWalletId;
    if (walletId == null) return;
    final psbt = await viewModel.buildUnsignedPsbtForAirgap(context);
    if (psbt == null || !context.mounted) return;
    try {
      final txid = await signAndBroadcast(
        context,
        walletId: walletId,
        unsignedPsbtBase64: psbt,
        signer: signer,
      );
      if (txid == null || !context.mounted) return;
      showSailToast(context, 'Transaction broadcast', variant: SailToastVariant.success);
      await viewModel.onAirgapBroadcast();
    } catch (e) {
      if (context.mounted) {
        showSailToast(context, 'Failed to broadcast: $e', variant: SailToastVariant.destructive);
      }
    }
  }
}

String calculateLabel(RecipientModel recipient, int index, BitcoinUnit currentUnit) {
  if (recipient.amountController.text.isEmpty &&
      recipient.addressController.text.isEmpty &&
      recipient.matchingAddressLabel.isEmpty) {
    return 'Recipient ${index + 1}';
  }

  final recipientLabel = recipient.matchingAddressLabel.isNotEmpty
      ? recipient.matchingAddressLabel
      : recipient.addressController.text.isEmpty
      ? '<Unknown>'
      : recipient.addressController.text.substring(0, min(recipient.addressController.text.length, 10));

  if (recipient.amountController.text.isEmpty) {
    return recipientLabel;
  }

  final amountBTC = parseAmountInUnit(recipient.amountController.text, currentUnit);
  final formattedAmount = formatBitcoinWithUnit(amountBTC, currentUnit);

  return '$recipientLabel ($formattedAmount)';
}

class PayToCard extends ViewModelWidget<SendPageViewModel> {
  const PayToCard({super.key});

  @override
  Widget build(BuildContext context, SendPageViewModel viewModel) {
    // Build a tab for each recipient
    final List<TabItem> tabs = [
      for (int i = 0; i < viewModel.recipients.length; i++)
        SingleTabItem(
          label: calculateLabel(viewModel.recipients[i], i, viewModel.currentUnit),
          child: _RecipientFields(
            key: ValueKey('recipient_fields_${viewModel.recipients[i].id}'),
            index: i,
            recipient: viewModel.recipients[i],
            addressBookEntries: viewModel.addressBookEntries,
            selectedEntry: viewModel.selectedEntry,
            onAddressSelected: viewModel.onAddressSelected,
            onUseAvailableBalance: viewModel.onUseAvailableBalance,
            subtractFee: viewModel.recipients[i].subtractFee,
            onSubtractFeeChanged: (val) {
              viewModel.recipients[i].subtractFee = val;
              viewModel.notifyListeners();
            },
            currentUnit: viewModel.currentUnit,
            onSaveToAddressBook: viewModel.saveToAddressBook,
          ),
          icon: SailSVGAsset.iconClose,
          onIconTap: () => viewModel.removeRecipient(i),
          onTap: () => viewModel.selectRecipient(i),
        ),
      // "+" tab at the end
      TabItem(
        label: '',
        child: const SizedBox.shrink(),
        onTap: viewModel.addRecipient,
        icon: SailSVGAsset.plus, // Use your plus icon asset here
      ),
    ];

    return SailCard(
      title: 'Pay To',
      child: SizedBox(
        height: 200,
        child: InlineTabBar(
          tabs: tabs,
          selectedIndex: viewModel.selectedRecipientIndex,
          onTabChanged: (index) {
            if (index < viewModel.recipients.length) {
              viewModel.selectRecipient(index);
            }
          },
        ),
      ),
    );
  }
}

// Extracted widget for recipient fields
class _RecipientFields extends StatelessWidget {
  final RecipientModel recipient;
  final List<AddressBookEntry> addressBookEntries;
  final AddressBookEntry? selectedEntry;
  final ValueChanged<AddressBookEntry?> onAddressSelected;
  final Future<void> Function(int index) onUseAvailableBalance;
  final bool subtractFee;
  final ValueChanged<bool> onSubtractFeeChanged;
  final int index;
  final BitcoinUnit currentUnit;
  final Future<void> Function(BuildContext context, String address) onSaveToAddressBook;

  const _RecipientFields({
    super.key,
    required this.index,
    required this.recipient,
    required this.addressBookEntries,
    required this.selectedEntry,
    required this.onAddressSelected,
    required this.onUseAvailableBalance,
    required this.subtractFee,
    required this.onSubtractFeeChanged,
    required this.currentUnit,
    required this.onSaveToAddressBook,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        SailTextField(
          key: Key('recipient_address_$key'),
          label: 'Address',
          controller: recipient.addressController,
          hintText: 'Enter a single L1 bitcoin-address (e.g. 1NS17iag...)',
          size: TextFieldSize.small,
          suffixWidget: SailRow(
            children: [
              PasteButton(
                onPaste: (text) {
                  recipient.addressController.text = text;
                },
              ),
              if (recipient.addressController.text.isNotEmpty &&
                  !addressBookEntries.any((e) => e.address == recipient.addressController.text))
                SailButton(
                  label: 'Save',
                  variant: ButtonVariant.ghost,
                  onPressed: () async => onSaveToAddressBook(context, recipient.addressController.text),
                ),
              Flexible(
                child: SailDropdownButton<AddressBookEntry>(
                  value: null,
                  hint: addressBookEntries.isEmpty ? 'No Addresses Saved' : (selectedEntry?.label ?? 'Address Book'),
                  items: addressBookEntries.isEmpty
                      ? []
                      : addressBookEntries.map((entry) {
                          return SailDropdownItem<AddressBookEntry>(
                            value: entry,
                            label: entry.label,
                          );
                        }).toList(),
                  icon: SailSVG.fromAsset(
                    SailSVGAsset.bookUser,
                    width: 13,
                    color: theme.colors.inactiveNavText,
                  ),
                  onChanged: onAddressSelected,
                ),
              ),
            ],
          ),
        ),
        NumericField(
          key: Key('recipient_amount_$key'),
          label: 'Amount (${currentUnit.symbol})',
          controller: recipient.amountController,
          textFieldType: currentUnit == BitcoinUnit.btc ? TextFieldType.bitcoin : TextFieldType.number,
          suffixWidget: SailButton(
            label: 'MAX',
            variant: ButtonVariant.link,
            onPressed: () async => onUseAvailableBalance(index),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class RecipientModel extends ChangeNotifier {
  final String id = UniqueKey().toString();
  AddressBookProvider get addressBookProvider => GetIt.I<AddressBookProvider>();
  List<AddressBookEntry> get addressBookEntries => addressBookProvider.sendEntries;

  final TextEditingController addressController;
  final TextEditingController amountController;
  bool subtractFee;
  String get matchingAddressLabel =>
      addressBookEntries.firstWhereOrNull((e) => e.address == addressController.text)?.label ?? '';

  RecipientModel({
    String address = '',
    String amount = '',
    String label = '',
    this.subtractFee = false,
  }) : addressController = TextEditingController(text: address),
       amountController = TextEditingController(text: amount) {
    addressController.addListener(notifyListeners);
    amountController.addListener(notifyListeners);
  }
}

class PayFromCard extends ViewModelWidget<SendPageViewModel> {
  const PayFromCard({super.key});

  @override
  Widget build(BuildContext context, SendPageViewModel viewModel) {
    return SailCard(
      title: 'Pay From',
      child: UTXOSelector(
        allUtxos: viewModel.allUtxos,
        selectedUtxos: viewModel.selectedUtxos,
        onSelectionChanged: viewModel.onSelectionChanged,
      ),
    );
  }
}

class FeeCard extends ViewModelWidget<SendPageViewModel> {
  const FeeCard({super.key});

  @override
  Widget build(BuildContext context, SendPageViewModel viewModel) {
    return SailCard(
      title: 'Fee',
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SailTextField(
            controller: viewModel.feeController,
            hintText: 'Fee (in ${viewModel.currentUnit.symbol})',
            textFieldType: viewModel.currentUnit == BitcoinUnit.btc ? TextFieldType.bitcoin : TextFieldType.number,
            suffixWidget: SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SailText.primary13(viewModel.currentUnit.symbol),
                SailDropdownButton<int>(
                  value: null,
                  hint: 'Estimate',
                  items: [
                    SailDropdownItem(value: 1, label: 'Low (1 block)'),
                    SailDropdownItem(value: 3, label: 'Medium (3 blocks)'),
                    SailDropdownItem(value: 6, label: 'High (6 blocks)'),
                  ],
                  onChanged: (value) async {
                    if (value != null) {
                      await viewModel.estimateFee(value);
                    }
                  },
                ),
              ],
            ),
          ),
          if (viewModel.feeRatePoints.isNotEmpty)
            FeeRateChart(
              points: viewModel.feeRatePoints,
              selectedConfTarget: viewModel.selectedConfTarget,
              onSelected: viewModel.selectFeeRatePoint,
            )
          else if (viewModel.loadingFeeRates)
            SizedBox(
              height: 180,
              child: Center(
                child: SailCircularProgressIndicator(color: context.sailTheme.colors.text),
              ),
            ),
          SailColumn(
            spacing: SailStyleValues.padding04,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SailText.secondary13('Coin selection'),
              SailDropdownButton<CoinSelectionStrategy>(
                value: viewModel.coinSelectionStrategy,
                items: CoinSelectionStrategy.values
                    .map((s) => SailDropdownItem<CoinSelectionStrategy>(value: s, label: s.displayName))
                    .toList(),
                onChanged: (value) async {
                  if (value != null) {
                    await viewModel.setCoinSelectionStrategy(value);
                  }
                },
              ),
              SailText.secondary12(viewModel.coinSelectionStrategy.description),
            ],
          ),
        ],
      ),
    );
  }
}

class PayFromAndFeeCard extends ViewModelWidget<SendPageViewModel> {
  const PayFromAndFeeCard({super.key});

  @override
  Widget build(BuildContext context, SendPageViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return SailRow(
            spacing: SailStyleValues.padding16,
            children: [
              Expanded(child: PayFromCard()),
              Expanded(child: FeeCard()),
            ],
          );
        } else {
          return SailColumn(
            spacing: SailStyleValues.padding16,
            children: [
              PayFromCard(),
              FeeCard(),
            ],
          );
        }
      },
    );
  }
}

/// Orchestrator migration status:
/// - Balance/UTXOs/transactions: routed via providers (already on orchestrator)
/// - sendTransaction: routed via orchestrator shared wallet RPC
/// - setCoinSelectionStrategy: STAYS on bitwindowd — BW-only coin selection prefs
/// - estimateSmartFee: STAYS on bitwindowd — bitcoind API, not wallet primitive
class SendPageViewModel extends BaseViewModel {
  Logger get log => GetIt.I<Logger>();

  BalanceProvider get balanceProvider => GetIt.I<BalanceProvider>();
  BlockchainProvider get blockchainProvider => GetIt.I<BlockchainProvider>();
  TransactionProvider get transactionsProvider => GetIt.I<TransactionProvider>();
  AddressBookProvider get addressBookProvider => GetIt.I<AddressBookProvider>();
  CoinSelectionProvider get coinSelectionProvider => GetIt.I<CoinSelectionProvider>();
  BitwindowRPC get bitwindowd => GetIt.I<BitwindowRPC>();
  OrchestratorRPC get _orchestrator => GetIt.I<OrchestratorRPC>();
  OrchestratorWalletRPC get _orchestratorWallet => _orchestrator.wallet;
  SettingsProvider get settingsProvider => GetIt.I<SettingsProvider>();
  WalletReaderProvider get _walletReader => GetIt.I<WalletReaderProvider>();

  bool get isHardwareWallet => _walletReader.activeWallet?.isHardware ?? false;
  String get hardwareDeviceType => _walletReader.activeWallet?.hardwareDeviceType ?? '';
  String get hardwareFingerprint => _walletReader.activeWallet?.hardwareFingerprint ?? '';

  BitcoinUnit get currentUnit => settingsProvider.bitcoinUnit;

  List<AddressBookEntry> get addressBookEntries => addressBookProvider.sendEntries;
  AddressBookEntry? selectedEntry;
  TextEditingController selectedUTXOs = TextEditingController();
  late TextEditingController feeController;

  /// All UTXOs from wallet (including frozen)
  List<UnspentOutput> get allUtxos => transactionsProvider.utxos.sorted(
    (a, b) {
      final dateCompare = b.receivedAt.toDateTime().compareTo(a.receivedAt.toDateTime());
      if (dateCompare != 0) return dateCompare;
      return a.output.compareTo(b.output);
    },
  );

  /// Available UTXOs (excluding frozen) for automatic selection
  List<UnspentOutput> get availableUtxos => allUtxos.where((u) => !coinSelectionProvider.isFrozen(u.output)).toList();

  /// Frozen outpoints
  Set<String> get frozenOutpoints => coinSelectionProvider.frozenOutpoints;

  List<UnspentOutput> selectedUtxos = [];

  /// Coin selection strategy (from provider)
  CoinSelectionStrategy get coinSelectionStrategy => coinSelectionProvider.strategy;

  List<RecipientModel> recipients = [];
  int selectedRecipientIndex = 0;
  BitcoinUnit? _previousUnit;

  List<FeeRatePoint> feeRatePoints = [];
  int? selectedConfTarget;
  bool loadingFeeRates = false;

  void _onRecipientChanged() {
    notifyListeners();
  }

  void _onUnitChanged() {
    final newUnit = currentUnit;
    if (_previousUnit != null && _previousUnit != newUnit) {
      _convertAllAmountsToNewUnit(_previousUnit!, newUnit);
    }
    _previousUnit = newUnit;
    notifyListeners();
  }

  void _convertAllAmountsToNewUnit(BitcoinUnit fromUnit, BitcoinUnit toUnit) {
    // Convert fee
    if (feeController.text.isNotEmpty) {
      final feeSats = parseAmountToSatoshis(feeController.text, fromUnit);
      if (toUnit == BitcoinUnit.btc) {
        feeController.text = satoshiToBTC(feeSats).toStringAsFixed(8);
      } else {
        feeController.text = feeSats.toString();
      }
    }

    // Convert all recipient amounts
    for (final recipient in recipients) {
      if (recipient.amountController.text.isNotEmpty) {
        final amountSats = parseAmountToSatoshis(recipient.amountController.text, fromUnit);
        if (toUnit == BitcoinUnit.btc) {
          recipient.amountController.text = satoshiToBTC(amountSats).toStringAsFixed(8);
        } else {
          recipient.amountController.text = amountSats.toString();
        }
      }
    }
  }

  SendPageViewModel() {
    _previousUnit = currentUnit;
    if (currentUnit == BitcoinUnit.btc) {
      feeController = TextEditingController(text: '0.00010000');
    } else {
      feeController = TextEditingController(text: '10000');
    }
    addressBookProvider.addListener(notifyListeners);
    transactionsProvider.addListener(_clearStaleSelectedUTXOs);
    coinSelectionProvider.addListener(notifyListeners);
    coinSelectionProvider.addListener(notifyListeners);
    settingsProvider.addListener(_onUnitChanged);
    init();
    final initialRecipient = RecipientModel();
    initialRecipient.addListener(_onRecipientChanged);
    recipients = [initialRecipient];
  }

  Future<void> setCoinSelectionStrategy(CoinSelectionStrategy strategy) async {
    await bitwindowd.wallet.setCoinSelectionStrategy(_toProto(strategy));
    await coinSelectionProvider.fetch();
    notifyListeners();
  }

  pb.CoinSelectionStrategy _toProto(CoinSelectionStrategy strategy) {
    switch (strategy) {
      case CoinSelectionStrategy.largestFirst:
        return pb.CoinSelectionStrategy.COIN_SELECTION_STRATEGY_LARGEST_FIRST;
      case CoinSelectionStrategy.smallestFirst:
        return pb.CoinSelectionStrategy.COIN_SELECTION_STRATEGY_SMALLEST_FIRST;
      case CoinSelectionStrategy.random:
        return pb.CoinSelectionStrategy.COIN_SELECTION_STRATEGY_RANDOM;
      case CoinSelectionStrategy.branchAndBound:
        return pb.CoinSelectionStrategy.COIN_SELECTION_STRATEGY_BRANCH_AND_BOUND;
    }
  }

  Future<void> _clearStaleSelectedUTXOs() async {
    final justFromWallet = allUtxos.where((u) => selectedUtxos.contains(u)).toList();
    if (justFromWallet.length != selectedUtxos.length) {
      selectedUtxos = justFromWallet;
    }

    notifyListeners();
  }

  Future<void> init() async {
    // Refresh on open — the provider's startup fetch can race bitwindowd's
    // connection, leaving the dropdown empty until some later refetch.
    await addressBookProvider.fetch();
    applicationDir = await Environment.datadir();
    logFile = await getLogFile();
    await loadFeeRateCurve();
    await estimateFee(1); // default to the next-block fee
  }

  Directory? applicationDir;
  File? logFile;

  @override
  void dispose() {
    for (final recipient in recipients) {
      recipient.removeListener(_onRecipientChanged);
    }
    addressBookProvider.removeListener(notifyListeners);
    coinSelectionProvider.removeListener(notifyListeners);
    coinSelectionProvider.removeListener(notifyListeners);
    settingsProvider.removeListener(_onUnitChanged);
    super.dispose();
  }

  Future<void> onUseAvailableBalance(int index) async {
    try {
      // never send more than their max selected amount
      double availableAmount = satoshiToBTC(selectedUtxos.fold(0, (sum, utxo) => sum + utxo.valueSats.toInt()));
      if (availableAmount == 0) {
        // if sum of all selected utxos, none are selected! defer to their balance
        availableAmount = balanceProvider.balance;
      }

      // 1. Sum up the amounts of all recipients except the one at 'index'
      double sumOtherRecipients = 0.0;
      for (int i = 0; i < recipients.length; i++) {
        if (i == index) continue;
        final amountBTC = parseAmountInUnit(recipients[i].amountController.text, currentUnit);
        sumOtherRecipients += amountBTC;
      }

      // 2. Calculate available balance minus fee
      final feeSats = parseAmountToSatoshis(feeController.text.isEmpty ? '0' : feeController.text, currentUnit);
      final available = availableAmount - satoshiToBTC(feeSats);

      // 3. Set the remaining amount for the recipient at 'index'
      final remaining = available - sumOtherRecipients;
      if (remaining < 0) {
        if (currentUnit == BitcoinUnit.btc) {
          recipients[index].amountController.text = '0.00';
        } else {
          recipients[index].amountController.text = '0';
        }
      } else {
        if (currentUnit == BitcoinUnit.btc) {
          recipients[index].amountController.text = remaining.toStringAsFixed(8);
        } else {
          final sats = btcToSatoshi(remaining);
          recipients[index].amountController.text = sats.toString();
        }
      }

      notifyListeners();
    } catch (error) {
      log.e('Error calculating available balance: $error');
      setError(error.toString());
    }
  }

  void clearAddress() {
    notifyListeners();
  }

  Future<void> sendTransaction(BuildContext context) async {
    // Multisig never auto-signs: build the PSBT and open the signing panel,
    // where each on-disk keystore signs explicitly and broadcast happens once
    // the threshold is met.
    final activeWallet = _walletReader.activeWallet;
    if (activeWallet != null && activeWallet.isMultisig) {
      await _startMultisigSign(context, activeWallet);
      return;
    }

    setBusy(true);

    // Check if all recipients have an address
    final missingAddress = recipients.indexWhere((r) => r.addressController.text.trim().isEmpty);
    if (missingAddress != -1) {
      showSailToast(context, 'Please enter an address for all recipients.');
      setBusy(false);
      return;
    }

    // Check if all recipients have an amount
    final missingAmount = recipients.indexWhere((r) => r.amountController.text.trim().isEmpty);
    if (missingAmount != -1) {
      showSailToast(context, 'Please enter an amount for all recipients.');
      setBusy(false);
      return;
    }

    final feeSats = parseAmountToSatoshis(feeController.text, currentUnit);
    if (feeSats <= 0) {
      showSailToast(context, 'Please enter a valid fee.');
      setBusy(false);
      return;
    }

    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) throw Exception('No active wallet');

      // Build destinations map for all recipients, summing amounts for duplicate addresses
      final destinations = <String, int>{};
      for (int i = 0; i < recipients.length; i++) {
        final r = recipients[i];
        final address = r.addressController.text;
        final satoshis = parseAmountToSatoshis(r.amountController.text, currentUnit);

        // Sum amounts for duplicate addresses
        destinations[address] = (destinations[address] ?? 0) + satoshis;
      }

      final txid = (await _orchestratorWallet.sendTransaction(
        walletId: walletId,
        destinations: destinations,
        fixedFeeSats: feeSats,
        requiredInputs: selectedUtxos,
      )).txid;
      await clearAll();
      log.d('Sent transaction: txid=$txid');
      final network = GetIt.I.get<BitcoinConfProvider>().network;
      GetIt.I.get<NotificationProvider>().add(
        title: 'Transaction sent',
        content: txid,
        dialogType: DialogType.info,
        links: [NotificationLink(text: 'View transaction', url: mempoolTxUrl(txid, network))],
      );
    } catch (error) {
      log.e('Error sending transaction: $error');
      if (context.mounted) {
        showSailToast(context, 'Could not send transaction $error', duration: const Duration(seconds: 5));
      }
    } finally {
      setBusy(false);
      notifyListeners();
      await transactionsProvider.fetch();
      await addressBookProvider.fetch();
      await balanceProvider.fetch();
    }
  }

  /// Build the PSBT for a multisig send and open the per-keystore signing
  /// panel. Reuses the airgap PSBT builder (validates recipients/fee and calls
  /// createPsbt) — the wallet's held keystores then sign in the panel.
  Future<void> _startMultisigSign(BuildContext context, WalletData wallet) async {
    final psbt = await buildUnsignedPsbtForAirgap(context);
    if (psbt == null || !context.mounted) return;
    await showThemedDialog(
      context: context,
      builder: (context) => MultisigSignModal(
        walletId: wallet.id,
        initialPsbt: psbt,
        multisig: wallet.multisig!,
      ),
    );
    await clearAll();
    await transactionsProvider.fetch();
    await balanceProvider.fetch();
  }

  /// Build an unsigned PSBT from the current recipients/fee/coin-selection for
  /// an external (airgap) signer. Returns base64, or null after surfacing an
  /// error toast.
  Future<String?> buildUnsignedPsbtForAirgap(BuildContext context) async {
    final missingAddress = recipients.indexWhere((r) => r.addressController.text.trim().isEmpty);
    if (missingAddress != -1) {
      showSailToast(context, 'Please enter an address for all recipients.');
      return null;
    }
    final missingAmount = recipients.indexWhere((r) => r.amountController.text.trim().isEmpty);
    if (missingAmount != -1) {
      showSailToast(context, 'Please enter an amount for all recipients.');
      return null;
    }
    final feeSats = parseAmountToSatoshis(feeController.text, currentUnit);
    if (feeSats <= 0) {
      showSailToast(context, 'Please enter a valid fee.');
      return null;
    }

    setBusy(true);
    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) throw Exception('No active wallet');

      final destinations = <String, int>{};
      for (final r in recipients) {
        final satoshis = parseAmountToSatoshis(r.amountController.text, currentUnit);
        destinations[r.addressController.text] = (destinations[r.addressController.text] ?? 0) + satoshis;
      }

      return await _orchestratorWallet.createPsbt(
        walletId: walletId,
        destinations: destinations,
        fixedFeeSats: feeSats,
        requiredInputs: selectedUtxos,
      );
    } catch (error) {
      log.e('Error building unsigned PSBT: $error');
      if (context.mounted) {
        showSailToast(context, 'Could not build PSBT $error', duration: const Duration(seconds: 5));
      }
      return null;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> onAirgapBroadcast() async {
    await transactionsProvider.fetch();
    await addressBookProvider.fetch();
    await balanceProvider.fetch();
  }

  Future<void> clearAll() async {
    // Remove listeners from all recipients
    for (final recipient in recipients) {
      recipient.removeListener(_onRecipientChanged);
    }
    recipients.clear();

    // Optionally, add a new empty recipient and attach listener
    final initialRecipient = RecipientModel();
    initialRecipient.addListener(_onRecipientChanged);
    recipients.add(initialRecipient);
    selectedRecipientIndex = 0;
    if (currentUnit == BitcoinUnit.btc) {
      feeController.text = '0.00010000';
    } else {
      feeController.text = '10000';
    }
    selectedUtxos = [];

    notifyListeners();
  }

  void onAddressSelected(AddressBookEntry? entry) {
    if (entry != null) {
      selectedEntry = entry;
      recipients[selectedRecipientIndex].addressController.text = entry.address;
      notifyListeners();
    }
  }

  Future<void> saveToAddressBook(BuildContext context, String address) async {
    if (address.isEmpty) return;
    if (!context.mounted) return;

    await showThemedDialog(
      context: context,
      builder: (context) => _SaveToAddressBookDialog(
        address: address,
        addressBookProvider: addressBookProvider,
        log: log,
      ),
    );
  }

  void handleBitcoinURI(BitcoinURI uri) async {
    await clearAll();
    if (recipients.isNotEmpty) {
      final recipient = recipients.first;
      recipient.addressController.text = uri.address;
      if (uri.amount != null) {
        recipient.amountController.text = uri.amount!.toString();
      }
    }
    notifyListeners();
  }

  void onSelectionChanged(List<UnspentOutput> selected) {
    final justFromWallet = allUtxos.where((u) => selected.contains(u)).toList();
    selectedUtxos = List.from(justFromWallet);
    notifyListeners();
  }

  void addRecipient() {
    final recipient = RecipientModel();
    recipient.addListener(_onRecipientChanged);
    recipients.add(recipient);
    selectedRecipientIndex = recipients.length - 1;
    notifyListeners();
  }

  void selectRecipient(int index) {
    selectedRecipientIndex = index;
    notifyListeners();
  }

  void removeRecipient(int index) {
    recipients[index].removeListener(_onRecipientChanged);
    recipients.removeAt(index);
    if (index != 0) {
      selectedRecipientIndex = index - 1;
    }
    notifyListeners();
  }

  int get _estimatedTxVBytes {
    final numInputs = selectedUtxos.isEmpty ? 2 : selectedUtxos.length;
    final numOutputs = recipients.length + 1; // recipients + change
    return estimateTxVBytes(numInputs: numInputs, numOutputs: numOutputs);
  }

  void _setFeeFromSats(int feeSats) {
    if (currentUnit == BitcoinUnit.btc) {
      feeController.text = satoshiToBTC(feeSats).toStringAsFixed(8);
    } else {
      feeController.text = feeSats.toString();
    }
  }

  Future<double?> _feeRateForTarget(int confTarget) async {
    // Electrum wallets have no Bitcoin Core; fee comes from esplora via the backend.
    try {
      final rate = await _orchestrator.wallet.estimateFee(confTarget);
      if (rate != null && rate > 0) return rate;
    } catch (_) {
      // fall through to Bitcoin Core for core-backed wallets
    }
    final response = await _orchestrator.bitcoind.estimateSmartFee(
      EstimateSmartFeeRequest()..confTarget = Int64(confTarget),
    );
    if (!response.hasFeeRate() || response.feeRate <= 0) return null;
    return btcPerKvbToSatPerVByte(response.feeRate);
  }

  Future<void> estimateFee(int confTarget) async {
    try {
      final satPerVByte = await _feeRateForTarget(confTarget);
      if (satPerVByte == null) return;
      _setFeeFromSats(feeSatsForRate(satPerVByte: satPerVByte, txVBytes: _estimatedTxVBytes));
      selectedConfTarget = confTarget;
      notifyListeners();
    } catch (error) {
      log.e('Error estimating fee: $error');
    }
  }

  Future<void> loadFeeRateCurve() async {
    loadingFeeRates = true;
    notifyListeners();
    try {
      final results = await Future.wait(
        feeRateConfTargets.map((t) async {
          final rate = await _feeRateForTarget(t);
          return rate == null ? null : FeeRatePoint(confTarget: t, satPerVByte: rate);
        }),
      );
      feeRatePoints = results.whereType<FeeRatePoint>().toList();
    } catch (error) {
      log.e('Error loading fee rate curve: $error');
      feeRatePoints = [];
    } finally {
      loadingFeeRates = false;
      notifyListeners();
    }
  }

  void selectFeeRatePoint(FeeRatePoint point) {
    selectedConfTarget = point.confTarget;
    _setFeeFromSats(feeSatsForRate(satPerVByte: point.satPerVByte, txVBytes: _estimatedTxVBytes));
    notifyListeners();
  }
}

class UTXOSelector extends StatefulWidget {
  final List<UnspentOutput> allUtxos;
  final List<UnspentOutput> selectedUtxos;
  final ValueChanged<List<UnspentOutput>> onSelectionChanged;

  const UTXOSelector({
    super.key,
    required this.allUtxos,
    required this.selectedUtxos,
    required this.onSelectionChanged,
  });

  @override
  State<UTXOSelector> createState() => _UTXOSelectorState();
}

class _UTXOSelectorState extends State<UTXOSelector> {
  @override
  void initState() {
    super.initState();
  }

  String formatUnspentOutput(UnspentOutput u, {bool long = true}) {
    final amount = formatBitcoin(satoshiToBTC(u.valueSats.toInt()));
    final receivedSuffix = long && u.hasReceivedAt()
        ? ' received ${formatDate(u.receivedAt.toDateTime(), long: false)}'
        : '';
    return '${u.output.substring(0, 6)}..:${u.output.split(':').last} ($amount)$receivedSuffix';
  }

  @override
  Widget build(BuildContext context) {
    final utxoItems = widget.allUtxos
        .map(
          (u) => SailDropdownItem(
            value: u.output,
            label: formatUnspentOutput(u, long: true),
            monospace: true,
          ),
        )
        .toList();

    final selectedValues = widget.selectedUtxos.map((u) => u.output).toList();

    return SailColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailRow(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SailTextField(
                controller: TextEditingController(
                  text: widget.selectedUtxos.map((u) => formatUnspentOutput(u, long: false)).join('\n'),
                ),
                readOnly: true,
                maxLines: null,
                hintText: 'Any UTXO',
                suffixWidget: SailMultiSelectDropdown(
                  items: utxoItems,
                  selectedValues: selectedValues,
                  onSelected: (String output) {
                    setState(() {
                      if (selectedValues.contains(output)) {
                        widget.selectedUtxos.removeWhere((u) => u.output == output);
                      } else {
                        final utxo = widget.allUtxos.firstWhere((u) => u.output == output);
                        widget.selectedUtxos.add(utxo);
                      }
                    });
                    widget.onSelectionChanged(widget.selectedUtxos);
                  },
                  buttonVariant: ButtonVariant.ghost,
                  searchPlaceholder: 'Search UTXOs',
                  selectedCountText: 'Select UTXO(s)',
                  showDropdownArrow: false,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SaveToAddressBookDialog extends StatefulWidget {
  final String address;
  final AddressBookProvider addressBookProvider;
  final Logger log;

  const _SaveToAddressBookDialog({
    required this.address,
    required this.addressBookProvider,
    required this.log,
  });

  @override
  State<_SaveToAddressBookDialog> createState() => _SaveToAddressBookDialogState();
}

class _SaveToAddressBookDialogState extends State<_SaveToAddressBookDialog> {
  final TextEditingController labelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    labelController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    labelController.removeListener(_onTextChanged);
    labelController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SailModal(
      backgroundColor: const Color(0x00000000),
      constraints: const BoxConstraints(maxWidth: 400),
      child: SailCard(
        title: 'Save to Address Book',
        subtitle: '',
        withCloseButton: true,
        child: SailColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: SailStyleValues.padding16,
          mainAxisSize: MainAxisSize.min,
          children: [
            SailTextField(
              label: 'Address',
              controller: TextEditingController(text: widget.address),
              hintText: widget.address,
              readOnly: true,
              size: TextFieldSize.small,
              suffixWidget: CopyButton(
                text: widget.address,
              ),
            ),
            SailTextField(
              label: 'Label',
              controller: labelController,
              hintText: 'Enter a label for this address',
              size: TextFieldSize.small,
            ),
            SailButton(
              label: 'Save',
              onPressed: () async {
                if (labelController.text.isEmpty) return;
                try {
                  await widget.addressBookProvider.createEntry(
                    labelController.text,
                    widget.address,
                    Direction.DIRECTION_SEND,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    showSailToast(context, 'Address saved to address book');
                  }
                } catch (e) {
                  widget.log.e('Error saving to address book: $e');
                  if (context.mounted) {
                    showSailToast(context, 'Failed to save address: $e');
                  }
                }
              },
              disabled: labelController.text.isEmpty,
            ),
          ],
        ),
      ),
    );
  }
}
