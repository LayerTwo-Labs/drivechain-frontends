import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/env.dart';
import 'package:bitwindow/main.dart';
import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/wallet/denial_dialog.dart';
import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/bitdrive_provider.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/denial_provider.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/utils/bitcoin_uri.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pb.dart';
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pb.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class WalletPage extends StatelessWidget {
  DenialProvider get denialProvider => GetIt.I.get<DenialProvider>();
  BitwindowRPC get api => GetIt.I<BitwindowRPC>();
  static final GlobalKey<InlineTabBarState> tabKey = GlobalKey<InlineTabBarState>();
  static SendPageViewModel? _sendViewModel; // Static reference to view model

  const WalletPage({
    super.key,
  });

  static void handleBitcoinURI(BitcoinURI uri) {
    _sendViewModel?.handleBitcoinURI(uri);
  }

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder<SendPageViewModel>.reactive(
        viewModelBuilder: () {
          _sendViewModel = SendPageViewModel();
          // Store reference to be able to set it's values from outside this particular file
          return _sendViewModel!;
        },
        onViewModelReady: (model) => model.init(),
        onDispose: (model) => _sendViewModel = null,
        builder: (context, model, child) {
          // Create the list of regular tabs
          final List<TabItem> allTabs = [
            const TabItem(
              label: 'Send',
              icon: SailSVGAsset.iconWallet,
              child: SendTab(),
            ),
            const TabItem(
              label: 'Receive',
              icon: SailSVGAsset.iconCoinnews,
              child: ReceiveTab(),
            ),
            const TabItem(
              label: 'Wallet Transactions',
              icon: SailSVGAsset.iconTransactions,
              child: TransactionsTab(),
            ),
            TabItem(
              label: 'Deniability',
              icon: SailSVGAsset.iconTransactions,
              child: DeniabilityTab(
                newWindowIdentifier: model.applicationDir == null
                    ? null
                    : NewWindowIdentifier(
                        windowType: 'deniability',
                        applicationDir: model.applicationDir!,
                        logFile: model.logFile!,
                      ),
              ),
              onTap: () {
                denialProvider.fetch();
              },
            ),
            TabItem(
              label: 'HD Wallet Explorer',
              icon: SailSVGAsset.iconHDWallet,
              child: HDWalletExplorerTab(),
            ),
            TabItem(
              label: 'BitDrive',
              icon: SailSVGAsset.iconBitdrive,
              child: BitDriveTab(),
            ),
            TabItem(
              label: 'Multisig Lounge',
              icon: SailSVGAsset.iconMultisig,
              child: MultisigLoungeTab(),
            ),
          ];

          // The tabs that will be in the dropdown
          final List<TabItem> dropdownTabs = allTabs.sublist(3);

          // Create a map of menu item labels to their content widgets
          final Map<String, Widget> dropdownContentMap = {
            for (var tab in dropdownTabs) tab.label: tab.child,
          };

          // Create the visible tabs (first 3 + dropdown)
          final List<TabItem> visibleTabs = [
            ...allTabs.sublist(0, 3), // First 3 tabs remain directly visible
            // Dropdown tab that switches between the remaining tabs
            DropdownTabItem(
              label: 'Tools',
              icon: SailSVGAsset.iconTools,
              child: dropdownTabs.first.child, // Default to first dropdown tab's content
              menuItems: dropdownTabs.map((tab) => tab.label).toList(),
              contentMap: dropdownContentMap, // Map menu items to their content widgets
              selectedItem: dropdownTabs.first.label, // Pre-select the first dropdown item
              useFixedLabel: false, // Show "Tools" when not selected, show tool name when selected
              onItemSelected: (selectedLabel) {
                // Find the tab with the selected label
                final selectedTab = dropdownTabs.firstWhere(
                  (tab) => tab.label == selectedLabel,
                  orElse: () => dropdownTabs.first,
                );

                // Execute the tab's onTap callback if it exists
                if (selectedTab.onTap != null) {
                  selectedTab.onTap!();
                }
              },
            ),
          ];

          return InlineTabBar(
            key: tabKey,
            tabs: visibleTabs,
            initialIndex: 0,
          );
        },
      ),
    );
  }
}

class SendTab extends ViewModelWidget<SendPageViewModel> {
  const SendTab({super.key});

  @override
  Widget build(BuildContext context, SendPageViewModel viewModel) {
    return SailRawCard(
      title: 'Send Bitcoin',
      subtitle: 'Send bitcoin to bitcoin-addresses. No sidechains involved.',
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: SailStyleValues.padding08,
            children: [
              Expanded(
                child: SailTextField(
                  label: 'Pay To',
                  controller: viewModel.addressController,
                  hintText: 'Enter a L1 bitcoin-address (e.g. 1NS17iag9jJgTHD1VXjvLCEnZuQ3rJDE9L)',
                  size: TextFieldSize.small,
                ),
              ),
              SailDropdownButton<AddressBookEntry>(
                value: null,
                hint: SailText.primary13(viewModel.selectedEntry?.label ?? 'Address Book'),
                items: viewModel.addressBookEntries.map((entry) {
                  return SailDropdownItem<AddressBookEntry>(
                    value: entry,
                    child: SailText.primary13(entry.label),
                  );
                }).toList(),
                onChanged: viewModel.onAddressSelected,
              ),
              QtIconButton(
                tooltip: 'Paste from clipboard',
                onPressed: () async {
                  try {
                    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                    if (clipboardData?.text != null) {
                      viewModel.addressController.text = clipboardData!.text!;
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
                            controller: viewModel.amountController,
                            suffixWidget: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: viewModel.onUseAvailableBalance,
                                child: SailText.primary15(
                                  'MAX',
                                  color: context.sailTheme.colors.orange,
                                  underline: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SailRow(
                          spacing: SailStyleValues.padding08,
                          children: [
                            UnitDropdown(
                              value: viewModel.unit,
                              onChanged: viewModel.onUnitChanged,
                              enabled: false,
                            ),
                            SailCheckbox(
                              value: viewModel.subtractFee,
                              onChanged: viewModel.onSubtractFeeChanged,
                              label: 'Subtract fee from amount',
                            ),
                          ],
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
              Expanded(child: Container()),
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
                    onPressed: () => viewModel.sendTransaction(context),
                    size: ButtonSize.small,
                  ),
                  const SizedBox(width: SailStyleValues.padding08),
                  QtButton(
                    style: SailButtonStyle.secondary,
                    label: 'Clear All',
                    onPressed: viewModel.clearAll,
                    size: ButtonSize.small,
                  ),
                ],
              ),
              // Balance
            ],
          ),
        ],
      ),
    );
  }
}

class TransactionFeeForm extends ViewModelWidget<SendPageViewModel> {
  const TransactionFeeForm({super.key});

  @override
  Widget build(BuildContext context, SendPageViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SailText.primary12(
              'Transaction Fee:',
              bold: true,
            ),
            const SizedBox(width: SailStyleValues.padding08),
            SailText.primary12(
              viewModel.feeEstimate.errors.map((e) => e).join('\n'),
              bold: true,
              color: context.sailTheme.colors.primary,
            ),
          ],
        ),
        const SizedBox(height: SailStyleValues.padding16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailRadioButton<String>(
              label: 'Recommended:',
              value: 'recommended',
              groupValue: viewModel.feeType,
              onChanged: (value) => viewModel.setFeeType(value),
            ),
            Opacity(
              opacity: viewModel.feeType == 'recommended' ? 1.0 : 0.5,
              child: Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SailText.primary12(
                          '${formatBitcoin(viewModel.feeRate)}/kvB',
                        ),
                        const SizedBox(width: 8.0),
                      ],
                    ),
                    const SizedBox(height: SailStyleValues.padding08),
                    Row(
                      children: [
                        SailText.primary12('Confirmation time target:'),
                        const SizedBox(width: 8.0),
                        SailDropdownButton(
                          enabled: viewModel.feeType == 'recommended',
                          items: viewModel.confirmationTargets.map((target) {
                            return SailDropdownItem(
                              value: target,
                              child: SailText.primary12(
                                viewModel.getConfirmationTargetLabel(target),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) => viewModel.setConfirmationTarget(value),
                          value: viewModel.confirmationTarget,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: SailStyleValues.padding16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SailRadioButton<String>(
              label: 'Custom:',
              value: 'custom',
              groupValue: viewModel.feeType,
              onChanged: (value) => viewModel.setFeeType(value),
            ),
            const SizedBox(width: 40.0),
            Expanded(
              child: Opacity(
                opacity: viewModel.feeType == 'custom' ? 1.0 : 0.5,
                child: Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SailText.primary12('Per kvB:'),
                          const SizedBox(width: SailStyleValues.padding08),
                          Expanded(
                            flex: 2,
                            child: NumericField(
                              label: 'Fee',
                              controller: viewModel.customFeeController,
                              hintText: 'Custom fee',
                              enabled: viewModel.feeType == 'custom' && !viewModel.useMinimumFee,
                            ),
                          ),
                          const SizedBox(width: SailStyleValues.padding08),
                          Expanded(
                            flex: 1,
                            child: UnitDropdown(
                              value: viewModel.feeUnit,
                              onChanged: viewModel.onFeeUnitChanged,
                              enabled: false,
                            ),
                          ),
                          const SizedBox(width: SailStyleValues.padding16),
                        ],
                      ),
                      const SizedBox(height: SailStyleValues.padding08),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: SailStyleValues.padding16),
      ],
    );
  }
}

class SendPageViewModel extends BaseViewModel {
  BalanceProvider get balanceProvider => GetIt.I<BalanceProvider>();
  BlockchainProvider get blockchainProvider => GetIt.I<BlockchainProvider>();
  TransactionProvider get transactionsProvider => GetIt.I<TransactionProvider>();
  AddressBookProvider get addressBookProvider => GetIt.I<AddressBookProvider>();
  BitwindowRPC get api => GetIt.I<BitwindowRPC>();
  Logger get log => GetIt.I<Logger>();
  late TextEditingController addressController;
  late TextEditingController amountController;
  late TextEditingController customFeeController;
  late TextEditingController labelController;
  Unit unit = Unit.BTC;
  bool subtractFee = false;
  String feeType = 'recommended';
  int confirmationTarget = 2;
  bool useMinimumFee = false;
  Unit feeUnit = Unit.BTC;
  EstimateSmartFeeResponse feeEstimate = EstimateSmartFeeResponse();
  List<AddressBookEntry> get addressBookEntries => addressBookProvider.sendEntries;
  AddressBookEntry? selectedEntry;
  SendPageViewModel() {
    addressController = TextEditingController(text: '');
    addressController.addListener(decodeURI);
    amountController = TextEditingController(text: '0.00');
    customFeeController = TextEditingController(text: '');
    labelController = TextEditingController(text: '');
    fetchEstimate();
    addressBookProvider.addListener(notifyListeners);
    init();
  }

  Future<void> init() async {
    applicationDir = await Environment.datadir();
    logFile = await getLogFile();
    await fetchEstimate();

    // Add listener for address changes
    addressController.addListener(_onAddressChanged);
    addressBookProvider.addListener(_onAddressBookChanged);
  }

  Directory? applicationDir;
  File? logFile;

  void decodeURI() {
    try {
      if (addressController.text.isNotEmpty) {
        final uri = Uri.parse(addressController.text);
        if (uri.scheme == 'bitcoin') {
          handleBitcoinURI(BitcoinURI.parse(uri.toString()));
        }
      }
    } catch (e) {
      // do nothing, it's okay!
    }
  }

  // Amount of blocks to confirm the transaction in
  List<int> get confirmationTargets => [1, 2, 4, 6, 12, 24, 48, 144, 432, 1008];
  double get feeRate => feeEstimate.feeRate == 0 ? 0.0002 : feeEstimate.feeRate;

  @override
  void dispose() {
    addressController.dispose();
    amountController.dispose();
    customFeeController.dispose();
    labelController.dispose();
    addressBookProvider.removeListener(notifyListeners);
    super.dispose();
  }

  void onUnitChanged(Unit value) {
    unit = value;
    notifyListeners();
  }

  void onSubtractFeeChanged(bool value) {
    subtractFee = value;
    notifyListeners();
  }

  Future<void> onUseAvailableBalance() async {
    // Get the balance from the node
    try {
      subtractFee = true;
      final balance = balanceProvider.balance - feeRate;
      amountController.text = balance.toStringAsFixed(8);
      notifyListeners();
    } catch (error) {
      log.e('Error converting satoshi to BTC: $error');
      setError(error.toString());
    }
  }

  void clearAddress() {
    addressController.clear();
    notifyListeners();
  }

  void setFeeType(String value) {
    feeType = value;
    if (feeType == 'recommended') {
      useMinimumFee = false;
    }
    notifyListeners();
  }

  void setConfirmationTarget(int? value) {
    if (value == null) {
      return;
    }

    confirmationTarget = value;
    notifyListeners();
    fetchEstimate();
  }

  Future<void> fetchEstimate() async {
    setBusy(true);
    try {
      final estimate = await api.bitcoind.estimateSmartFee(confirmationTarget);
      Logger().d(
        'Estimate: estimate=${estimate.feeRate} errors=${estimate.errors}',
      );
      feeEstimate = estimate;
    } catch (error) {
      setError(error.toString());
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> sendTransaction(BuildContext context) async {
    setBusy(true);
    if (addressController.text.isEmpty) {
      showSnackBar(context, 'Please enter an address');
      return;
    }
    if (amountController.text.isEmpty) {
      showSnackBar(context, 'Please enter an amount');
      return;
    }
    if (feeType == 'custom' && customFeeController.text.isEmpty) {
      showSnackBar(context, 'Please enter a custom fee');
      return;
    }

    try {
      final txid = await api.wallet.sendTransaction(
        addressController.text,
        btcToSatoshi(
          double.parse(amountController.text) - (subtractFee ? feeRate : 0),
        ),
        btcPerKvB: feeType == 'recommended' ? feeRate : double.parse(customFeeController.text),
        label: labelController.text,
      );
      Logger().d('Sent transaction: txid=$txid');
      if (context.mounted) {
        showSnackBar(context, 'Sent in txid=$txid');
      }
    } catch (error) {
      Logger().e('Error sending transaction: $error');
      if (context.mounted) {
        showSnackBar(context, 'Could not send transaction $error', duration: 5);
      }
    } finally {
      setBusy(false);
      notifyListeners();
      await transactionsProvider.fetch();
      await addressBookProvider.fetch();
      await balanceProvider.fetch();
    }
  }

  void setUseMinimumFee(bool? value) {
    useMinimumFee = value ?? false;
    if (useMinimumFee) {
      customFeeController.text = '10.00'; // Set to minimum fee
    }
    notifyListeners();
  }

  void onFeeUnitChanged(Unit value) {
    feeUnit = value;
    notifyListeners();
  }

  String getConfirmationTargetLabel(int target) {
    switch (target) {
      case 1:
        return '10 minutes (next block)';
      case 2:
        return '20 minutes (2 blocks)';
      case 4:
        return '40 minutes (4 blocks)';
      case 6:
        return '60 minutes (6 blocks)';
      case 12:
        return '2 hours (12 blocks)';
      case 24:
        return '4 hours (24 blocks)';
      case 48:
        return '8 hours (48 blocks)';
      case 144:
        return '24 hours (144 blocks)';
      case 432:
        return '3 days (504 blocks)';
      case 1008:
        return '7 days (1008 blocks)';
      default:
        return '$target minutes';
    }
  }

  Future<void> clearAll() async {
    addressController.clear();
    amountController.text = '0.00';
    customFeeController.clear();
    unit = Unit.BTC;
    subtractFee = false;
    feeType = 'recommended';
    confirmationTarget = 2;
    useMinimumFee = false;
    notifyListeners();
  }

  void onAddressSelected(AddressBookEntry? entry) {
    if (entry != null) {
      addressController.text = entry.address;
      labelController.text = entry.label;
      selectedEntry = entry;
      notifyListeners();
    }
  }

  void handleBitcoinURI(BitcoinURI uri) {
    addressController.text = uri.address;
    if (uri.amount != null) {
      amountController.text = uri.amount!.toString();
    }
    if (uri.label != null) {
      labelController.text = uri.label!;
    }
    notifyListeners();
  }

  AddressBookEntry get matchingEntry => addressBookProvider.sendEntries.firstWhere(
        (e) => e.address == addressController.text,
        orElse: () => AddressBookEntry(id: Int64(0), label: '', address: '', direction: Direction.DIRECTION_SEND),
      );

  void _onAddressChanged() {
    decodeURI(); // Keep existing URI decoder

    final entry = matchingEntry;
    if (entry.id != Int64(0)) {
      // If we found a matching entry
      labelController.text = entry.label;
      selectedEntry = entry;
    } else {
      // Clear label if address doesn't match any entry
      labelController.text = '';
      selectedEntry = null;
    }
    notifyListeners();
  }

  void _onAddressBookChanged() {
    // When address book changes, update label if this address exists
    _onAddressChanged();
  }
}

class ReceiveTab extends StatelessWidget {
  const ReceiveTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return QtPage(
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => ReceivePageViewModel(),
        onViewModelReady: (model) => model.init(),
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
                      title: 'Receive Bitcoin',
                      subtitle: 'Receive bitcoin to your bitcoin-wallet. No sidechains involved.',
                      error: model.modelError,
                      child: SailColumn(
                        spacing: SailStyleValues.padding16,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SailRow(
                            spacing: SailStyleValues.padding08,
                            children: [
                              Expanded(
                                child: SailTextField(
                                  controller: TextEditingController(text: model.address),
                                  hintText: 'A Drivechain address',
                                  readOnly: true,
                                ),
                              ),
                              CopyButton(
                                text: model.address,
                              ),
                            ],
                          ),
                          SailRow(
                            spacing: SailStyleValues.padding08,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: SailTextField(
                                  label: 'Store label for address',
                                  controller: model.labelController,
                                  hintText: '(no label)',
                                  size: TextFieldSize.small,
                                ),
                              ),
                              QtButton(
                                label: model.hasExistingLabel ? 'Update Label' : 'Save Label',
                                onPressed: () async {
                                  try {
                                    if (model.hasExistingLabel) {
                                      await model.updateLabel(model.matchingEntry.id);
                                    } else {
                                      await model.saveLabel(context);
                                    }
                                  } catch (e) {
                                    // Error handled by model
                                  }
                                },
                                disabled: model.isBusy || !model.hasLabelChanged,
                                loading: model.isBusy,
                                size: ButtonSize.small,
                              ),
                            ],
                          ),
                          if (model.address.isEmpty)
                            QtButton(
                              label: 'Generate new address',
                              onPressed: model.generateNewAddress,
                              loading: model.isBusy,
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: SailRawCard(
                      padding: true,
                      child: QrImageView(
                        padding: EdgeInsets.zero,
                        eyeStyle: QrEyeStyle(
                          color: theme.colors.text,
                          eyeShape: QrEyeShape.square,
                        ),
                        dataModuleStyle: QrDataModuleStyle(color: theme.colors.text),
                        data: model.address,
                        version: QrVersions.auto,
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class ReceivePageViewModel extends BaseViewModel {
  final AddressBookProvider _addressBookProvider = GetIt.I<AddressBookProvider>();
  TransactionProvider get transactionsProvider => GetIt.I<TransactionProvider>();
  final TextEditingController labelController = TextEditingController();

  String get address => transactionsProvider.address;

  AddressBookEntry get matchingEntry => _addressBookProvider.receiveEntries.firstWhere(
        (e) => e.address == address,
        orElse: () => AddressBookEntry(id: Int64(0), label: '', address: '', direction: Direction.DIRECTION_RECEIVE),
      );
  bool get hasExistingLabel => matchingEntry.label.isNotEmpty;
  bool get hasLabelChanged => labelController.text != matchingEntry.label;

  void init() {
    transactionsProvider.addListener(_onAddressChanged);
    _addressBookProvider.addListener(_onAddressBookChanged);
    generateNewAddress();
    labelController.addListener(notifyListeners);
  }

  void _onAddressChanged() {
    if (labelController.text.isEmpty) {
      labelController.text = matchingEntry.label;
    }
    notifyListeners();
  }

  void _onAddressBookChanged() {
    // When address book changes, update label if this address exists
    _onAddressChanged();
  }

  @override
  void dispose() {
    transactionsProvider.removeListener(_onAddressChanged);
    _addressBookProvider.removeListener(_onAddressBookChanged);
    labelController.removeListener(notifyListeners);
    labelController.dispose();
    super.dispose();
  }

  Future<void> generateNewAddress() async {
    await transactionsProvider.fetch();
  }

  Future<void> saveLabel(BuildContext context) async {
    try {
      setBusy(true);
      setErrorForObject('create', null);
      notifyListeners();

      await _addressBookProvider.createEntry(
        labelController.text,
        address,
        Direction.DIRECTION_RECEIVE,
      );

      labelController.clear();
      await _addressBookProvider.fetch();
      if (context.mounted) {
        showSnackBar(context, 'Saved New Label');
      }
    } catch (error) {
      setErrorForObject('create', error.toString());
      notifyListeners();
      rethrow;
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateLabel(Int64 id) async {
    try {
      setBusy(true);
      setErrorForObject('edit', null);
      notifyListeners();

      await _addressBookProvider.updateLabel(id, labelController.text);
      labelController.clear();
    } catch (error) {
      setErrorForObject('edit', error.toString());
      notifyListeners();
      rethrow;
    } finally {
      setBusy(false);
    }
  }

  Future<void> deleteLabel(Int64 id) async {
    try {
      setBusy(true);
      setErrorForObject('delete', null);
      notifyListeners();

      await _addressBookProvider.deleteEntry(id);
    } catch (error) {
      setErrorForObject('delete', error.toString());
      notifyListeners();
      rethrow;
    } finally {
      setBusy(false);
    }
  }
}

class TransactionsTab extends StatelessWidget {
  const TransactionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ViewModelBuilder<AddressMenuViewModel>.reactive(
          viewModelBuilder: () => AddressMenuViewModel(),
          builder: (context, model, child) {
            return TransactionTable(
              entries: model.entries,
              searchWidget: SailTextField(
                controller: model.searchController,
                hintText: 'Enter address or transaction id to search',
              ),
            );
          },
        );
      },
    );
  }
}

class TransactionTable extends StatefulWidget {
  final List<WalletTransaction> entries;
  final Widget searchWidget;

  const TransactionTable({
    super.key,
    required this.entries,
    required this.searchWidget,
  });

  @override
  State<TransactionTable> createState() => _TransactionTableState();
}

class _TransactionTableState extends State<TransactionTable> {
  String sortColumn = 'date';
  bool sortAscending = true;
  List<WalletTransaction> entries = [];

  @override
  void initState() {
    super.initState();
    entries = widget.entries;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!listEquals(entries, widget.entries)) {
      entries = List.from(widget.entries);
      sortEntries();
    }
  }

  void onSort(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }
      sortEntries();
    });
  }

  void sortEntries() {
    entries.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (sortColumn) {
        case 'height':
          aValue = a.confirmationTime.height;
          bValue = b.confirmationTime.height;
          break;
        case 'date':
          aValue = a.confirmationTime.timestamp.seconds;
          bValue = b.confirmationTime.timestamp.seconds;
          break;
        case 'txid':
          aValue = a.txid;
          bValue = b.txid;
          break;
        case 'amount':
          aValue = a.receivedSatoshi;
          bValue = b.receivedSatoshi;
          break;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SailRawCard(
          title: 'Wallet Transaction History',
          subtitle:
              'List of transactions for your bitcoin-wallet. Contains send, receive and sidechain-interaction transactions.',
          bottomPadding: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: SailStyleValues.padding16,
                ),
                child: widget.searchWidget,
              ),
              Expanded(
                child: SailTable(
                  getRowId: (index) => widget.entries[index].txid,
                  headerBuilder: (context) => [
                    SailTableHeaderCell(
                      name: 'Conf Height',
                      onSort: () => onSort('height'),
                    ),
                    SailTableHeaderCell(
                      name: 'Date',
                      onSort: () => onSort('date'),
                    ),
                    SailTableHeaderCell(
                      name: 'TxID',
                      onSort: () => onSort('txid'),
                    ),
                    SailTableHeaderCell(
                      name: 'Amount',
                      onSort: () => onSort('amount'),
                    ),
                  ],
                  rowBuilder: (context, row, selected) {
                    final entry = widget.entries[row];
                    final amount = entry.receivedSatoshi != 0
                        ? formatBitcoin(satoshiToBTC(entry.receivedSatoshi.toInt()))
                        : formatBitcoin(satoshiToBTC(entry.sentSatoshi.toInt()));

                    return [
                      SailTableCell(
                        value: entry.confirmationTime.height == 0
                            ? 'Unconfirmed'
                            : entry.confirmationTime.height.toString(),
                        monospace: true,
                      ),
                      SailTableCell(
                        value: entry.confirmationTime.timestamp.toDateTime().toLocal().format(),
                        monospace: true,
                      ),
                      SailTableCell(
                        value: entry.txid,
                        monospace: true,
                      ),
                      SailTableCell(
                        value: amount,
                        monospace: true,
                      ),
                    ];
                  },
                  rowCount: widget.entries.length,
                  columnWidths: const [100, 150, 200, 150],
                  drawGrid: true,
                  sortColumnIndex: [
                    'height',
                    'date',
                    'txid',
                    'amount',
                  ].indexOf(sortColumn),
                  sortAscending: sortAscending,
                  onSort: (columnIndex, ascending) {
                    onSort(['height', 'date', 'txid', 'amount'][columnIndex]);
                  },
                  onDoubleTap: (rowId) {
                    final utxo = widget.entries.firstWhere(
                      (u) => u.txid == rowId,
                    );
                    _showUtxoDetails(context, utxo);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUtxoDetails(BuildContext context, WalletTransaction utxo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SailRawCard(
            title: 'Transaction Details',
            subtitle: 'Details of the selected transaction',
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailRow(label: 'TxID', value: utxo.txid),
                  DetailRow(label: 'Amount', value: formatBitcoin(satoshiToBTC(utxo.receivedSatoshi.toInt()))),
                  DetailRow(label: 'Date', value: utxo.confirmationTime.timestamp.toDateTime().toLocal().format()),
                  DetailRow(label: 'Confirmation Height', value: utxo.confirmationTime.height.toString()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddressMenuViewModel extends BaseViewModel {
  final TransactionProvider _txProvider = GetIt.I<TransactionProvider>();
  List<WalletTransaction> get entries => _txProvider.walletTransactions
      .where(
        (tx) => searchController.text.isEmpty || tx.txid.contains(searchController.text),
      )
      .toList();

  String sortColumn = 'date';
  bool sortAscending = true;

  final TextEditingController searchController = TextEditingController();

  AddressMenuViewModel() {
    searchController.addListener(notifyListeners);
    _txProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    searchController.removeListener(notifyListeners);
    _txProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

Future<CoreTransaction?> showAddressBookModal(BuildContext context) {
  return showDialog<CoreTransaction>(
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width * 0.1,
        ),
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: context.sailTheme.colors.formFieldBorder,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SailStyleValues.padding25,
              vertical: SailStyleValues.padding16,
            ),
            child: Container(),
          ),
        ),
      );
    },
  );
}

class DeniabilityTab extends StatelessWidget {
  final NewWindowIdentifier? newWindowIdentifier;

  const DeniabilityTab({
    super.key,
    required this.newWindowIdentifier,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ViewModelBuilder<DeniabilityViewModel>.reactive(
          viewModelBuilder: () => DeniabilityViewModel(),
          onViewModelReady: (model) => WidgetsBinding.instance.addPostFrameCallback((_) => model.postInit()),
          builder: (context, model, child) {
            final error = model.error('deniability');

            return DeniabilityTable(
              newWindowIdentifier: newWindowIdentifier,
              error: error,
              utxos: model.utxos,
              onDeny: (txid, vout) => model.showDenyDialog(context, txid, vout),
              onCancel: model.cancelDenial,
            );
          },
        );
      },
    );
  }
}

class DeniabilityTable extends StatefulWidget {
  final NewWindowIdentifier? newWindowIdentifier;
  final String? error;
  final List<UnspentOutput> utxos;
  final void Function(String txid, int vout) onDeny;
  final void Function(Int64) onCancel;

  const DeniabilityTable({
    super.key,
    required this.error,
    required this.utxos,
    required this.onDeny,
    required this.onCancel,
    required this.newWindowIdentifier,
  });

  @override
  State<DeniabilityTable> createState() => _DeniabilityTableState();
}

class _DeniabilityTableState extends State<DeniabilityTable> {
  String sortColumn = 'txid';
  bool sortAscending = true;

  void onSort(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }
      sortEntries();
    });
  }

  void sortEntries() {
    widget.utxos.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (sortColumn) {
        case 'txid':
          // Sort by combined txid:vout string
          final aKey = '${a.txid}:${a.vout}';
          final bKey = '${b.txid}:${b.vout}';
          return sortAscending ? aKey.compareTo(bKey) : bKey.compareTo(aKey);
        case 'amount':
          return sortAscending ? a.valueSats.compareTo(b.valueSats) : b.valueSats.compareTo(a.valueSats);
        case 'hops':
          if (!a.hasDeniability() && !b.hasDeniability()) return 0;
          if (!a.hasDeniability()) return sortAscending ? 1 : -1;
          if (!b.hasDeniability()) return sortAscending ? -1 : 1;
          aValue = a.deniability.executions.length;
          bValue = b.deniability.executions.length;
          return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        case 'next':
          if (!a.hasDeniability() && !b.hasDeniability()) return 0;
          if (!a.hasDeniability()) return sortAscending ? 1 : -1;
          if (!b.hasDeniability()) return sortAscending ? -1 : 1;
          if (!a.deniability.hasNextExecution() && !b.deniability.hasNextExecution()) return 0;
          if (!a.deniability.hasNextExecution()) return sortAscending ? 1 : -1;
          if (!b.deniability.hasNextExecution()) return sortAscending ? -1 : 1;
          return sortAscending
              ? a.deniability.nextExecution.toDateTime().compareTo(b.deniability.nextExecution.toDateTime())
              : b.deniability.nextExecution.toDateTime().compareTo(a.deniability.nextExecution.toDateTime());
        case 'status':
          if (!a.hasDeniability() && !b.hasDeniability()) return 0;
          if (!a.hasDeniability()) return sortAscending ? 1 : -1;
          if (!b.hasDeniability()) return sortAscending ? -1 : 1;
          aValue = a.deniability.hasCancelTime()
              ? 'Cancelled'
              : (a.deniability.numHops - a.deniability.executions.length == 0 ? 'Completed' : 'Ongoing');
          bValue = b.deniability.hasCancelTime()
              ? 'Cancelled'
              : (b.deniability.numHops - b.deniability.executions.length == 0 ? 'Completed' : 'Ongoing');
          return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        default:
          return 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailRawCard(
      title: 'UTXOs and Denials',
      subtitle: 'List of UTXOs with optional deniability info.',
      error: widget.error,
      bottomPadding: false,
      inSeparateWindow: widget.newWindowIdentifier != null,
      newWindowIdentifier: widget.newWindowIdentifier,
      child: Column(
        children: [
          SailSpacing(SailStyleValues.padding16),
          Expanded(
            child: SailTable(
              getRowId: (index) =>
                  widget.utxos.isEmpty ? '0' : '${widget.utxos[index].txid}:${widget.utxos[index].vout}',
              headerBuilder: (context) => [
                SailTableHeaderCell(
                  name: 'UTXO',
                  onSort: () => onSort('txid'),
                ),
                SailTableHeaderCell(
                  name: 'Amount',
                  onSort: () => onSort('amount'),
                ),
                SailTableHeaderCell(
                  name: 'Hops',
                  onSort: () => onSort('hops'),
                ),
                SailTableHeaderCell(
                  name: 'Next Execution',
                  onSort: () => onSort('next'),
                ),
                SailTableHeaderCell(
                  name: 'Status',
                  onSort: () => onSort('status'),
                ),
                const SailTableHeaderCell(name: 'Actions'),
              ],
              cellHeight: 36.0,
              rowBuilder: (context, row, selected) {
                // If there are no UTXOs, return a single row with an empty cell message
                if (widget.utxos.isEmpty) {
                  return [
                    const SailTableCell(value: 'No UTXOs available'),
                    const SailTableCell(value: ''),
                    const SailTableCell(value: ''),
                    const SailTableCell(value: ''),
                    const SailTableCell(value: ''),
                    const SailTableCell(value: ''),
                  ];
                }

                final utxo = widget.utxos[row];
                final hasDeniability = utxo.hasDeniability();

                String status = '-';
                String nextExecution = '-';
                String hops = '0';
                bool canCancel = false;

                if (hasDeniability) {
                  final completedHops = utxo.deniability.executions.length;
                  final totalHops = utxo.deniability.numHops;
                  hops = '$completedHops/$totalHops';
                  if (completedHops == totalHops) {
                    hops = '$completedHops';
                  }

                  status = utxo.deniability.hasCancelTime()
                      ? 'Cancelled'
                      : completedHops == totalHops
                          ? 'Completed'
                          : 'Ongoing';
                  nextExecution = utxo.deniability.hasNextExecution()
                      ? utxo.deniability.nextExecution.toDateTime().toLocal().toString()
                      : '-';
                  canCancel = status == 'Ongoing';

                  if (status == 'Cancelled') {
                    hops = '$completedHops';
                  }
                }

                return [
                  SailTableCell(
                    value: '${utxo.txid}:${utxo.vout}',
                    monospace: true,
                  ),
                  SailTableCell(
                    value: formatBitcoin(satoshiToBTC(utxo.valueSats.toInt())),
                    monospace: true,
                  ),
                  SailTableCell(
                    value: hops,
                    monospace: true,
                  ),
                  SailTableCell(
                    value: nextExecution,
                    monospace: true,
                  ),
                  Tooltip(
                    message: utxo.deniability.cancelReason,
                    child: SailTableCell(
                      value: status,
                      monospace: true,
                    ),
                  ),
                  SailTableCell(
                    value: canCancel ? 'Cancel' : '-',
                    monospace: true,
                    child: canCancel
                        ? QtButton(
                            label: 'Cancel',
                            onPressed: () async => widget.onCancel(utxo.deniability.id),
                            size: ButtonSize.small,
                          )
                        : QtButton(
                            label: 'Deny',
                            onPressed: () async => widget.onDeny(utxo.txid, utxo.vout),
                            size: ButtonSize.small,
                          ),
                  ),
                ];
              },
              rowCount: widget.utxos.isEmpty ? 1 : widget.utxos.length, // Show one row when empty
              columnWidths: const [-1, -1, -1, -1, -1, -1],
              drawGrid: true,
              sortColumnIndex: [
                'txid',
                'vout',
                'amount',
                'next',
                'status',
                'actions',
              ].indexOf(sortColumn),
              sortAscending: sortAscending,
              onSort: (columnIndex, ascending) {
                onSort(['txid', 'vout', 'amount', 'next', 'status', 'actions'][columnIndex]);
              },
              onDoubleTap: (rowId) {
                if (widget.utxos.isEmpty) return;
                final utxo = widget.utxos.firstWhere(
                  (u) => '${u.txid}:${u.vout}' == rowId,
                );
                _showUtxoDetails(context, utxo);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showUtxoDetails(BuildContext context, UnspentOutput utxo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SailRawCard(
            title: 'UTXO Details',
            subtitle: 'UTXO and Deniability Information',
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailRow(label: 'TxID', value: utxo.txid),
                  DetailRow(label: 'Output Index', value: utxo.vout.toString()),
                  DetailRow(label: 'Amount', value: formatBitcoin(satoshiToBTC(utxo.valueSats.toInt()))),
                  if (utxo.hasDeniability()) ...[
                    const SailSpacing(SailStyleValues.padding16),
                    BorderedSection(
                      title: 'Deniability Info',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailRow(label: 'Status', value: _getDeniabilityStatus(utxo)),
                          DetailRow(label: 'Completed Hops', value: '${utxo.deniability.executions.length}'),
                          DetailRow(label: 'Total Hops', value: '${utxo.deniability.numHops}'),
                          if (utxo.deniability.hasNextExecution())
                            DetailRow(
                              label: 'Next Execution',
                              value: utxo.deniability.nextExecution.toDateTime().toLocal().toString(),
                            ),
                          if (utxo.deniability.hasCancelTime())
                            DetailRow(
                              label: 'Cancel Reason',
                              value: utxo.deniability.cancelReason,
                            ),
                        ],
                      ),
                    ),
                    if (utxo.deniability.executions.isNotEmpty) ...[
                      const SailSpacing(SailStyleValues.padding16),
                      SailText.primary13('Deniability Transactions:'),
                      const SailSpacing(SailStyleValues.padding08),
                      SizedBox(
                        height: 300,
                        child: SelectionContainer.disabled(
                          child: TXIDTransactionTable(
                            transactions: utxo.deniability.executions
                                .map((e) => e.fromTxid)
                                .where((txid) => txid.isNotEmpty)
                                .toList(),
                            onTransactionSelected: (txid) => _showTransactionDetails(context, txid),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, String txid) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailsDialog(
        txid: txid,
      ),
    );
  }

  String _getDeniabilityStatus(UnspentOutput utxo) {
    if (!utxo.hasDeniability()) return 'No deniability';
    if (utxo.deniability.hasCancelTime()) return 'Cancelled';

    final completedHops = utxo.deniability.executions.length;
    final totalHops = utxo.deniability.numHops;

    if (completedHops == totalHops) return 'Completed';
    return 'Ongoing ($completedHops/$totalHops hops)';
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: SailText.primary13(
              label,
              monospace: true,
              color: context.sailTheme.colors.textTertiary,
            ),
          ),
          Expanded(
            child: SailText.secondary13(
              value,
              monospace: true,
            ),
          ),
        ],
      ),
    );
  }
}

class DeniabilityViewModel extends BaseViewModel {
  final BitwindowRPC api = GetIt.I.get<BitwindowRPC>();
  final DenialProvider denialProvider = GetIt.I.get<DenialProvider>();

  List<UnspentOutput> get utxos => denialProvider.utxos;

  DeniabilityViewModel() {
    denialProvider.addListener(notifyListeners);
    denialProvider.addListener(errorListener);
  }

  void init() {
    // Set busy state to show loading indicator
    setBusy(true);
    notifyListeners();
  }

  // Post-frame initialization for async operations
  Future<void> postInit() async {
    try {
      // Fetch data
      await denialProvider.fetch();
    } catch (e) {
      setErrorForObject('deniability', e.toString());
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void errorListener() {
    setErrorForObject('deniability', denialProvider.error);
  }

  void showDenyDialog(BuildContext context, String txid, int vout) {
    denialProvider.fetch();

    showDialog(
      context: context,
      builder: (context) => DenialDialog(
        onSubmit: (hops, delaySeconds) async {
          await api.bitwindowd.createDenial(
            txid: txid,
            vout: vout,
            numHops: hops,
            delaySeconds: delaySeconds,
          );
          await denialProvider.fetch();
        },
      ),
    );
  }

  void cancelDenial(Int64 id) async {
    try {
      await api.bitwindowd.cancelDenial(id);
      await denialProvider.fetch();
    } catch (e) {
      setError(e.toString());
    }
  }
}

class HDWalletExplorerTab extends StatefulWidget {
  const HDWalletExplorerTab({super.key});

  @override
  State<HDWalletExplorerTab> createState() => _HDWalletExplorerTabState();
}

class HDWalletEntry {
  final String path;
  final String address;
  final String publicKey;
  final String privateKey;

  HDWalletEntry({
    required this.path,
    required this.address,
    required this.publicKey,
    required this.privateKey,
  });
}

class _HDWalletExplorerTabState extends State<HDWalletExplorerTab> {
  final TextEditingController _derivationPathController = TextEditingController(text: "m/44'/0'/0'/0");
  late final HDWalletProvider _hdWalletProvider;
  List<HDWalletEntry> _derivedEntries = [];
  int _currentPage = 0;
  static const int _entriesPerPage = 20;
  bool _showPrivateKeys = true;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _hdWalletProvider = GetIt.I.get<HDWalletProvider>();
    _derivationPathController.addListener(_onDerivationPathChanged);
    _initWallet();
  }

  @override
  void dispose() {
    _derivationPathController.dispose();
    super.dispose();
  }

  Future<void> _initWallet() async {
    setState(() => _isBusy = true);
    try {
      await _hdWalletProvider.init();
      if (_hdWalletProvider.isInitialized) {
        await _deriveEntries();
      }
    } finally {
      setState(() => _isBusy = false);
    }
  }

  void _onDerivationPathChanged() {
    if (_hdWalletProvider.isInitialized) {
      _deriveEntries();
    }
  }

  Future<void> _deriveEntries() async {
    setState(() => _isBusy = true);
    try {
      final basePath = _derivationPathController.text.trim();
      final entries = <HDWalletEntry>[];
      final startIndex = _currentPage * _entriesPerPage;

      for (var i = 0; i < _entriesPerPage; i++) {
        final index = startIndex + i;
        final path = '$basePath/$index';

        final address = await _hdWalletProvider.deriveAddress(path);
        final publicKey = await _hdWalletProvider.derivePublicKey(path);
        final privateKey = await _hdWalletProvider.deriveWIF(path);

        entries.add(
          HDWalletEntry(
            path: path,
            address: address,
            publicKey: publicKey,
            privateKey: privateKey,
          ),
        );
      }

      setState(() => _derivedEntries = entries);
    } catch (e) {
      Logger().e('Error in key derivation: $e');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _nextPage() async {
    setState(() {
      _currentPage++;
      _onDerivationPathChanged();
    });
  }

  Future<void> _previousPage() async {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _onDerivationPathChanged();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SailRawCard(
      title: 'HD Wallet Explorer',
      subtitle: 'Explore BIP32/39/44 wallet derivation paths',
      error: _hdWalletProvider.error,
      child: _isBusy
          ? const Center(child: CircularProgressIndicator())
          : SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_hdWalletProvider.isInitialized) ...[
                  SailRow(
                    spacing: SailStyleValues.padding08,
                    children: [
                      Expanded(
                        child: SailTextField(
                          label: 'Derivation Path',
                          controller: _derivationPathController,
                          hintText: "m/44'/0'/0'/0",
                        ),
                      ),
                      QtButton(
                        label: 'Previous',
                        onPressed: _currentPage > 0 ? _previousPage : null,
                        size: ButtonSize.small,
                      ),
                      SailText.primary12('Page ${_currentPage + 1}'),
                      QtButton(
                        label: 'Next',
                        onPressed: _nextPage,
                        size: ButtonSize.small,
                      ),
                    ],
                  ),
                  Expanded(
                    child: SailColumn(
                      spacing: SailStyleValues.padding08,
                      children: [
                        Expanded(
                          child: SailTable(
                            getRowId: (index) => _derivedEntries[index].path,
                            headerBuilder: (context) => [
                              const SailTableHeaderCell(name: 'Path'),
                              const SailTableHeaderCell(name: 'Address'),
                              const SailTableHeaderCell(name: 'Public Key'),
                              SailRow(
                                spacing: SailStyleValues.padding08,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const SailTableHeaderCell(name: 'Private Keys'),
                                  SailRawButton(
                                    disabled: false,
                                    loading: false,
                                    onPressed: () async => setState(() => _showPrivateKeys = !_showPrivateKeys),
                                    child: SailText.primary13(
                                      !_showPrivateKeys ? 'Show' : 'Hide',
                                      bold: true,
                                      color: context.sailTheme.colors.text,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            rowBuilder: (context, row, selected) {
                              final entry = _derivedEntries[row];
                              return [
                                SailTableCell(
                                  value: entry.path,
                                  monospace: true,
                                ),
                                SailTableCell(
                                  value: entry.address,
                                  monospace: true,
                                ),
                                SailTableCell(
                                  value: entry.publicKey,
                                  monospace: true,
                                ),
                                SailTableCell(
                                  value: _showPrivateKeys ? entry.privateKey : '••••••••••••••••••••••••••••••••',
                                  monospace: true,
                                ),
                              ];
                            },
                            rowCount: _derivedEntries.length,
                            columnWidths: const [-1, -1, -1, -1],
                            drawGrid: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(),
                ],
              ],
            ),
    );
  }
}

class BitDriveTab extends StatelessWidget {
  const BitDriveTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ViewModelBuilder<BitDriveViewModel>.reactive(
          viewModelBuilder: () => BitDriveViewModel(),
          builder: (context, model, child) {
            final error = model.error('bitdrive');

            return SailRawCard(
              title: 'BitDrive',
              subtitle: 'Store and retrieve content in the Bitcoin blockchain',
              error: error,
              child: Column(
                children: [
                  Expanded(
                    child: SailColumn(
                      spacing: SailStyleValues.padding16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Input area
                        SailRow(
                          spacing: SailStyleValues.padding16,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: SailColumn(
                                spacing: SailStyleValues.padding08,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SailText.primary13('Content to Store'),
                                  SailText.secondary12(
                                    'Enter text or choose a file (max 1MB)',
                                    color: context.sailTheme.colors.textTertiary,
                                  ),
                                  const SailSpacing(SailStyleValues.padding08),
                                  SailTextField(
                                    controller: model.textController,
                                    maxLines: 3,
                                    hintText: 'Enter text to store...',
                                  ),
                                  SailRow(
                                    spacing: SailStyleValues.padding08,
                                    children: [
                                      QtButton(
                                        label: 'Choose File',
                                        onPressed: () => model.pickFile(context),
                                        size: ButtonSize.small,
                                      ),
                                      if (model.selectedFileName != null)
                                        Expanded(
                                          child: SailText.secondary13(
                                            model.selectedFileName!,
                                          ),
                                        ),
                                      if (model.selectedFileName != null)
                                        QtIconButton(
                                          tooltip: 'Clear selected file',
                                          onPressed: model.clearSelectedFile,
                                          icon: Icon(
                                            Icons.close,
                                            size: 16.0,
                                            color: context.sailTheme.colors.text,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Right side controls
                            Expanded(
                              flex: 1,
                              child: SailColumn(
                                spacing: SailStyleValues.padding16,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SailText.primary13('Settings'),
                                  SailRow(
                                    spacing: SailStyleValues.padding08,
                                    children: [
                                      Expanded(
                                        child: NumericField(
                                          label: 'Fee (BTC)',
                                          controller: model.feeController,
                                          hintText: '0.0001',
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          QtIconButton(
                                            tooltip: 'Increase fee',
                                            onPressed: () async {
                                              model.adjustFee(0.0001);
                                            },
                                            icon: Icon(
                                              Icons.arrow_upward,
                                              size: 12.0,
                                              color: context.sailTheme.colors.text,
                                            ),
                                          ),
                                          QtIconButton(
                                            tooltip: 'Decrease fee',
                                            onPressed: () async {
                                              model.adjustFee(-0.0001);
                                            },
                                            icon: Icon(
                                              Icons.arrow_downward,
                                              size: 12.0,
                                              color: context.sailTheme.colors.text,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SailCheckbox(
                                    value: model.shouldEncrypt,
                                    onChanged: model.onEncryptChanged,
                                    label: 'Encrypt',
                                  ),
                                  const SailSpacing(SailStyleValues.padding16),
                                  QtButton(
                                    label: 'Store',
                                    onPressed: model.canStore ? () => model.store(context) : null,
                                    loading: model.isBusy,
                                    style: model.canStore ? SailButtonStyle.primary : SailButtonStyle.secondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Bottom section with restore button
                  Container(
                    padding: const EdgeInsets.all(SailStyleValues.padding16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: context.sailTheme.colors.formFieldBorder,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        QtButton(
                          label: 'Open BitDrive',
                          onPressed: model._bitdriveDir != null ? () => model.openBitdriveDir() : null,
                          size: ButtonSize.small,
                          style: SailButtonStyle.secondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class BitDriveViewModel extends BaseViewModel {
  final BitDriveProvider provider = GetIt.I.get<BitDriveProvider>();
  final TextEditingController textController = TextEditingController();
  final TextEditingController feeController = TextEditingController(text: '0.0001');
  Logger get log => GetIt.I.get<Logger>();
  String? selectedFileName;
  Uint8List? selectedFileContent;
  bool get shouldEncrypt => provider.shouldEncrypt;
  bool get canStore => textController.text.isNotEmpty || selectedFileContent != null;
  String? _bitdriveDir;

  BitDriveViewModel() {
    provider.addListener(notifyListeners);
    textController.addListener(() => onTextChanged(textController.text));
    _initBitdriveDir();
  }

  Future<void> _initBitdriveDir() async {
    final appDir = await Environment.datadir();
    _bitdriveDir = '${appDir.path}/bitdrive';
    notifyListeners();
  }

  Future<void> openBitdriveDir() async {
    if (_bitdriveDir == null) return;
    try {
      final dir = Directory(_bitdriveDir!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      if (Platform.isMacOS) {
        await Process.run('open', [_bitdriveDir!]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [_bitdriveDir!]);
      } else if (Platform.isWindows) {
        await Process.run('explorer', [_bitdriveDir!]);
      }
    } catch (e) {
      log.e('Error opening BitDrive directory: $e');
    }
  }

  void adjustFee(double amount) {
    try {
      final currentFee = double.parse(feeController.text);
      final newFee = (currentFee + amount).clamp(0.0001, 1.0);
      final formattedFee = newFee.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      feeController.text = formattedFee;
      provider.setFee(newFee);
      notifyListeners();
    } catch (e) {
      feeController.text = '0.0001';
      provider.setFee(0.0001);
    }
  }

  void onTextChanged(String value) {
    provider.setTextContent(value);
    // Clear any selected file when text is entered
    if (value.isNotEmpty) {
      selectedFileName = null;
      selectedFileContent = null;
    }
    notifyListeners();
  }

  void onEncryptChanged(bool? value) {
    if (value != null) {
      provider.setEncryption(value);
      notifyListeners();
    }
  }

  Future<void> clearSelectedFile() async {
    selectedFileName = null;
    selectedFileContent = null;
    notifyListeners();
  }

  Future<void> pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 1024 * 1024) {
          if (context.mounted) {
            showSnackBar(context, 'File size must be less than 1MB');
          }
          return;
        }

        Uint8List? fileContents;
        if (file.bytes != null) {
          fileContents = file.bytes!;
        } else if (file.path != null) {
          try {
            fileContents = await File(file.path!).readAsBytes();
          } catch (e) {
            Logger().e('Error reading file: $e');
            if (context.mounted) {
              showSnackBar(context, 'Error reading file: $e');
            }
            return;
          }
        }

        if (fileContents != null) {
          selectedFileContent = fileContents;
          selectedFileName = file.name;
          textController.clear();
          await provider.setFileContent(
            fileContents,
            name: file.name,
            type: file.extension != null ? 'application/${file.extension}' : 'application/octet-stream',
          );
          notifyListeners();
        } else {
          if (context.mounted) {
            showSnackBar(context, 'Could not read file contents');
          }
        }
      }
    } catch (e) {
      Logger().e('Error picking file: $e');
      if (context.mounted) {
        showSnackBar(context, 'Error picking file: $e');
      }
    }
  }

  Future<void> store(BuildContext context) async {
    setBusy(true);
    try {
      await provider.store();
      if (context.mounted) {
        showSnackBar(context, 'Content stored successfully');
        textController.clear();
        selectedFileName = null;
        selectedFileContent = null;
      }
    } catch (e) {
      setError(e.toString());
      if (context.mounted) {
        showSnackBar(context, 'Failed to store content: $e');
      }
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    textController.dispose();
    feeController.dispose();
    provider.removeListener(notifyListeners);
    super.dispose();
  }
}

class MultisigLoungeTab extends StatelessWidget {
  const MultisigLoungeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SailRawCard(
      title: 'Multisig Lounge',
      subtitle: 'Create and manage multi-signature wallets',
      child: Center(
        child: SailText.primary15(
          'Multisig functionality coming soon...',
          color: context.sailTheme.colors.textTertiary,
        ),
      ),
    );
  }
}
