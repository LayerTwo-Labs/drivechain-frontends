import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/gen/bitcoind/v1/bitcoind.pbgrpc.dart';
import 'package:bitwindow/providers/balance_provider.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/servers/api.dart';
import 'package:bitwindow/widgets/qt_button.dart';
import 'package:bitwindow/widgets/qt_container.dart';
import 'package:bitwindow/widgets/qt_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/containers/qt_page.dart';
import 'package:stacked/stacked.dart';
import 'package:super_clipboard/super_clipboard.dart';

@RoutePage()
class SendPage extends StatelessWidget {
  API get api => GetIt.I.get<API>();

  const SendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder<SendPageViewModel>.reactive(
        viewModelBuilder: () => SendPageViewModel(),
        onViewModelReady: (model) => model.init(),
        builder: (context, model, child) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Expanded(
                child: QtContainer(
                  child: SendDetailsForm(),
                ),
              ),
              const SizedBox(height: SailStyleValues.padding08),
              const Expanded(
                child: QtContainer(
                  child: TransactionFeeForm(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: SailStyleValues.padding08,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        QtButton(
                          onPressed: () => model.sendTransaction(context),
                          child: SailText.primary12('Send'),
                        ),
                        const SizedBox(width: SailStyleValues.padding08),
                        QtButton(
                          onPressed: model.clearAll,
                          child: SailText.primary12('Clear All'),
                        ),
                      ],
                    ),
                    // Balance
                    FutureBuilder(
                      future: api.wallet.getBalance(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final balance = formatBitcoin(
                            satoshiToBTC(
                              snapshot.data!.confirmedSatoshi.toInt() + snapshot.data!.pendingSatoshi.toInt(),
                            ),
                          );
                          return SailText.primary12('Balance: $balance');
                        } else if (snapshot.hasError) {
                          return SailText.primary12(
                            'Error: could not fetch balance',
                            color: context.sailTheme.colors.error,
                          );
                        } else {
                          return SailText.primary12('Balance: Loading...');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

const _kLabelWidth = 50.0;

class SendDetailsForm extends ViewModelWidget<SendPageViewModel> {
  const SendDetailsForm({super.key});

  @override
  Widget build(BuildContext context, SendPageViewModel viewModel) {
    return Column(
      children: [
        Row(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: _kLabelWidth,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: SailText.primary12('Pay To:'),
              ),
            ),
            const SizedBox(width: SailStyleValues.padding16),
            Expanded(
              child: SailTextField(
                controller: viewModel.addressController,
                hintText: 'Enter a Drivechain address (e.g. 1NS17iag9jJgTHD1VXjvLCEnZuQ3rJDE9L)',
                size: TextFieldSize.small,
              ),
            ),
            const SizedBox(width: 4.0),
            QtIconButton(
              tooltip: 'Paste from clipboard',
              onPressed: () async {
                if (SystemClipboard.instance != null) {
                  await SystemClipboard.instance?.read().then((reader) async {
                    if (reader.canProvide(Formats.plainText)) {
                      final text = await reader.readValue(Formats.plainText);
                      viewModel.addressController.text = text ?? viewModel.addressController.text;
                    }
                  });
                } else {
                  showSnackBar(context, 'Clipboard not available');
                }
              },
              icon: Icon(
                Icons.content_paste_rounded,
                size: 20.0,
                color: context.sailTheme.colors.text,
              ),
            ),
            const SizedBox(width: 4.0),
            QtIconButton(
              tooltip: 'Clear',
              onPressed: () => viewModel.clearAddress(),
              icon: Icon(
                Icons.cancel_outlined,
                size: 20.0,
                color: context.sailTheme.colors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: SailStyleValues.padding16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: _kLabelWidth,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: SailText.primary12('Amount:'),
              ),
            ),
            const SizedBox(width: SailStyleValues.padding16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: NumericField(
                          controller: viewModel.amountController,
                        ),
                      ),
                      const SizedBox(width: SailStyleValues.padding16),
                      UnitDropdown(
                        value: viewModel.unit,
                        onChanged: viewModel.onUnitChanged,
                        enabled: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: SailStyleValues.padding16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: SailStyleValues.padding16,
                        runSpacing: SailStyleValues.padding08,
                        children: [
                          SailCheckbox(
                            value: viewModel.subtractFee,
                            onChanged: viewModel.onSubtractFeeChanged,
                            label: 'Subtract fee from amount',
                          ),
                          QtButton(
                            onPressed: viewModel.onUseAvailableBalance,
                            child: SailText.primary12('Use available balance'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
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
                          width: 200.0,
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
        SailCheckbox(
          value: viewModel.replaceByFee,
          onChanged: viewModel.setReplaceByFee,
          label: 'Request Replace-By-Fee',
        ),
      ],
    );
  }
}

enum Unit {
  BTC,
  mBTC,
  uBTC,
  sats,
}

class UnitDropdown extends StatelessWidget {
  final Unit value;
  final Function(Unit) onChanged;
  final bool enabled;

  const UnitDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SailDropdownButton(
      width: 128.0,
      items: [
        SailDropdownItem(
          value: Unit.BTC,
          child: SailText.primary12('BTC'),
        ),
      ],
      onChanged: onChanged,
      value: value,
      enabled: enabled,
    );
  }
}

class NumericField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final Function(String)? onEditingComplete;
  final Function(String)? onSubmitted;
  final String hintText;
  final bool enabled;
  final String? error;

  const NumericField({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.hintText = '0.00',
    this.enabled = true,
    this.error = '',
  });

  @override
  State<NumericField> createState() => _NumericFieldState();
}

class _NumericFieldState extends State<NumericField> {
  late TextEditingController _controller = TextEditingController(text: '0.00');
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? TextEditingController(text: '0.00');
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return SailTextField(
      controller: _controller,
      hintText: widget.hintText,
      focusNode: _focusNode,
      textFieldType: TextFieldType.bitcoin,
      size: TextFieldSize.small,
      dense: true,
      enabled: widget.enabled,
      onSubmitted: widget.onSubmitted != null ? (value) => widget.onSubmitted!(value) : null,
    );
  }
}

class SendPageViewModel extends BaseViewModel {
  BalanceProvider get balanceProvider => GetIt.I<BalanceProvider>();
  BlockchainProvider get blockchainProvider => GetIt.I<BlockchainProvider>();
  TransactionProvider get transactionsProvider => GetIt.I<TransactionProvider>();
  API get api => GetIt.I<API>();
  Logger get log => GetIt.I<Logger>();
  late TextEditingController addressController;
  late TextEditingController amountController;
  late TextEditingController customFeeController;
  Unit unit = Unit.BTC;
  bool subtractFee = false;
  String feeType = 'recommended';
  int confirmationTarget = 2;
  bool useMinimumFee = false;
  bool replaceByFee = false;
  Unit feeUnit = Unit.BTC;
  EstimateSmartFeeResponse feeEstimate = EstimateSmartFeeResponse();

  SendPageViewModel();

  // Amount of blocks to confirm the transaction in
  List<int> get confirmationTargets => [1, 2, 4, 6, 12, 24, 48, 144, 432, 1008];
  double get feeRate => feeEstimate.feeRate == 0 ? 0.0002 : feeEstimate.feeRate;

  void init() {
    addressController = TextEditingController(text: '');
    amountController = TextEditingController(text: '0.00');
    customFeeController = TextEditingController(text: '');
    fetchEstimate();
  }

  @override
  void dispose() {
    addressController.dispose();
    amountController.dispose();
    customFeeController.dispose();
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
      final balance = satoshiToBTC(balanceProvider.balance) - feeRate;
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

  void setConfirmationTarget(int value) {
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
        feeType == 'recommended' ? feeRate : double.parse(customFeeController.text),
        replaceByFee,
      );
      Logger().d('Sent transaction: txid=$txid ');
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
    }
  }

  void setUseMinimumFee(bool? value) {
    useMinimumFee = value ?? false;
    if (useMinimumFee) {
      customFeeController.text = '10.00'; // Set to minimum fee
    }
    notifyListeners();
  }

  void setReplaceByFee(bool? value) {
    replaceByFee = value ?? false;
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

  void clearAll() {
    addressController.clear();
    amountController.text = '0.00';
    customFeeController.clear();
    unit = Unit.BTC;
    subtractFee = false;
    feeType = 'recommended';
    confirmationTarget = 2;
    useMinimumFee = false;
    replaceByFee = false;
    notifyListeners();
  }
}
