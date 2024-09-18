import 'package:auto_route/auto_route.dart';
import 'package:drivechain_client/api.dart';
import 'package:drivechain_client/util/currencies.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:money2/money2.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:stacked/stacked.dart';

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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 12.0,
                    right: 12.0,
                    top: 12.0,
                    bottom: 4.0,
                  ),
                  child: QtContainer(
                    child: SendDetailsForm(model: model),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 12.0,
                    right: 12.0,
                    top: 12.0,
                    bottom: 4.0,
                  ),
                  child: QtContainer(
                    child: TransactionFeeForm(model: model),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Row(),
                    // Balance
                    FutureBuilder(
                      future: api.getBalance(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final balance = Money.fromNumWithCurrency(
                            snapshot.data!.confirmedSatoshi.toDouble() +
                                snapshot.data!.pendingSatoshi.toDouble(),
                            satoshi,
                          ).toString();
                          return SailText.primary12('Balance: $balance');
                        } else if (snapshot.hasError) {
                          return SailText.primary12('Error: ${snapshot.error}');
                        } else {
                          return SailText.primary12('Balance: Loading...');
                        }
                      },
                    ),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  // Add a left border to every child
                  children: [
                    // TODO: Get actual info from the node
                    SailText.primary12('195755 blocks'),
                    SailText.primary12('1 peer'),
                    SailText.primary12('Last block: 6 days ago'),
                  ]
                      .map(
                        (child) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 2.0,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.grey),
                            ),
                          ),
                          child: child,
                        ),
                      )
                      .toList(),
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

class SendDetailsForm extends StatelessWidget {
  final SendPageViewModel model;

  const SendDetailsForm({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(width: 16.0),
            Expanded(
              child: SailTextField(
                controller: model.addressController,
                hintText:
                    'Enter a Drivechain address (e.g. 1NS17iag9jJgTHD1VXjvLCEnZuQ3rJDE9L)',
                size: TextFieldSize.small,
              ),
            ),
            const SizedBox(width: 4.0),
            QtIconButton(
              onPressed: () {
                showSnackBar(context, 'Not implemented');
              },
              icon: const Icon(
                Icons.contacts_outlined,
                size: 20.0,
              ),
            ),
            const SizedBox(width: 4.0),
            QtIconButton(
              onPressed: () async {
                if (SystemClipboard.instance != null) {
                  await SystemClipboard.instance?.read().then((reader) async {
                    if (reader.canProvide(Formats.plainText)) {
                      final text = await reader.readValue(Formats.plainText);
                      model.addressController.text =
                          text ?? model.addressController.text;
                    }
                  });
                } else {
                  showSnackBar(context, 'Clipboard not available');
                }
              },
              icon: const Icon(
                Icons.content_paste_rounded,
                size: 20.0,
              ),
            ),
            const SizedBox(width: 4.0),
            QtIconButton(
              onPressed: () => model.clearAddress(),
              icon: const Icon(
                Icons.cancel_outlined,
                size: 20.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: _kLabelWidth,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: SailText.primary12('Label:'),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: SailTextField(
                controller: model.labelController,
                hintText:
                    'Enter a label for this address to add it to your address book',
                size: TextFieldSize.small,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
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
            const SizedBox(width: 16.0),
            Flexible(
              flex: 1,
              child: NumericField(
                controller: model.amountController,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      UnitDropdown(
                        value: model.unit,
                        onChanged: model.onUnitChanged,
                      ),
                      const SizedBox(width: 24.0),
                      SailCheckbox(
                        value: model.subtractFee,
                        onChanged: model.onSubtractFeeChanged,
                        label: 'Subtract fee from amount',
                      ),
                    ],
                  ),
                  QtButton(
                    onPressed: model.onUseAvailableBalance,
                    child: const Text('Use available balance'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            QtButton(
              onPressed: model.clearAll,
              child: const Text('Clear All'),
            ),
            QtButton(
              onPressed: model.sendTransaction,
              child: const Text('Send'),
            ),
          ],
        ),
      ],
    );
  }
}

class TransactionFeeForm extends StatelessWidget {
  final SendPageViewModel model;

  const TransactionFeeForm({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary12(
          'Transaction Fee:',
          bold: true,
        ),
        const SizedBox(height: 16.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailRadioButton<String>(
              label: 'Recommended:',
              value: 'recommended',
              groupValue: model.feeType,
              onChanged: (value) => model.setFeeType(value),
            ),
            Opacity(
              opacity: model.feeType == 'recommended' ? 1.0 : 0.5,
              child: Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SailText.primary12('200.00 bits/kB'),
                        const SizedBox(width: 8.0),
                        SailText.primary12(
                          '(Smart fee not initialized yet. This usually takes a few blocks...)',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        SailText.primary12('Confirmation time target:'),
                        const SizedBox(width: 8.0),
                        SailDropdownButton(
                          width: 200.0,
                          enabled: model.feeType == 'recommended',
                          items: model.confirmationTargets.map((target) {
                            return SailDropdownItem(
                              value: target,
                              child: SailText.primary12(
                                  model.getConfirmationTargetLabel(target)),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              model.setConfirmationTarget(value),
                          value: model.confirmationTarget,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SailRadioButton<String>(
              label: 'Custom:',
              value: 'custom',
              groupValue: model.feeType,
              onChanged: (value) => model.setFeeType(value),
            ),
            Expanded(
              child: Opacity(
                opacity: model.feeType == 'custom' ? 1.0 : 0.5,
                child: Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SailText.primary12('Per kB:'),
                          const SizedBox(width: 8.0),
                          Expanded(
                            flex: 2,
                            child: NumericField(
                              controller: model.customFeeController,
                              hintText: 'Custom fee',
                              enabled: model.feeType == 'custom' &&
                                  !model.useMinimumFee,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            flex: 1,
                            child: UnitDropdown(
                              value: model.feeUnit,
                              onChanged: model.onFeeUnitChanged,
                              enabled: model.feeType == 'custom' &&
                                  !model.useMinimumFee,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Tooltip(
                            message: '''
Paying only the minimum fee is just
fine as long as there is less
transaction volume than space in the
blocks. But be aware that this can end
up in a never confirming transaction
once there is more demand for
Drivechain transactions than the
network can process.''',
                            child: SailCheckbox(
                              value: model.useMinimumFee,
                              onChanged: model.feeType == 'custom'
                                  ? model.setUseMinimumFee
                                  : null,
                              label:
                                  'Pay only the require fee of 10.00 bits/kB (read the tooltip)',
                              enabled: model.feeType == 'custom' &&
                                  !model.useMinimumFee,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Tooltip(
          message: '''
With Replace-By-Fee (BIP-125)
you can increase a transaction's
fee after it is sent. Without this,
a higher fee may be
recommended to compensate
for increased transaction delay
risk.
''',
          child: SailCheckbox(
            value: model.replaceByFee,
            onChanged: model.setReplaceByFee,
            label: 'Request Replace-By-Fee',
          ),
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
        SailDropdownItem(
          value: Unit.mBTC,
          child: SailText.primary12('mBTC'),
        ),
        SailDropdownItem(
          value: Unit.uBTC,
          child: SailText.primary12('µBTC (bits)'),
        ),
        SailDropdownItem(
          value: Unit.sats,
          child: SailText.primary12('sats'),
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
      onSubmitted: widget.onSubmitted != null
          ? (value) => widget.onSubmitted!(value)
          : null,
    );
  }
}

class QtPage extends StatelessWidget {
  final Widget child;

  const QtPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: SailStyleValues.padding12,
        right: SailStyleValues.padding12,
        top: SailStyleValues.padding12,
        bottom: SailStyleValues.padding05,
      ),
      child: child,
    );
  }
}

class QtContainer extends StatelessWidget {
  final Widget child;

  const QtContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: child,
    );
  }
}

class QtIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;

  const QtIconButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SailScaleButton(
      onPressed: onPressed,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 4.0,
          vertical: 4.0,
        ),
        child: icon,
      ),
    );
  }
}

class QtButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsets padding;
  final bool large;
  final bool important;
  final bool enabled;

  const QtButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: SailStyleValues.padding15,
      vertical: 0.0,
    ),
    this.large = false,
    this.important = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: large ? 32 : 24,
      child: SailRawButton(
        disabled: !enabled,
        loading: false,
        onPressed: enabled ? onPressed : null,
        padding: padding,
        child: child,
      ),
    );
  }
}

class SendPageViewModel extends BaseViewModel {
  late TextEditingController addressController;
  late TextEditingController labelController;
  late TextEditingController amountController;
  late TextEditingController customFeeController;
  late API api;
  Unit unit = Unit.BTC;
  bool subtractFee = false;
  String feeType = 'recommended';
  int confirmationTarget = 2;
  bool useMinimumFee = false;
  bool replaceByFee = false;
  Unit feeUnit = Unit.BTC;

  SendPageViewModel();

  // Amount of blocks to confirm the transaction in
  List<int> get confirmationTargets => [2, 4, 6, 12, 24, 48, 144, 432, 1008];

  void init() {
    addressController = TextEditingController(text: '');
    labelController = TextEditingController(text: '');
    amountController = TextEditingController(text: '0.00');
    customFeeController = TextEditingController(text: '');
    api = GetIt.I<API>();
  }

  @override
  void dispose() {
    addressController.dispose();
    labelController.dispose();
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
      final balance = await runBusyFuture(api.getBalance());
      amountController.text = balance.confirmedSatoshi.toDouble().toString();
      notifyListeners();
    } catch (error) {
      // TODO: Use sail_ui logger?
      Logger().e('Error fetching balance: $error');
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
    labelController.clear();
    amountController.text = '0.00';
    customFeeController.clear();
    unit = Unit.BTC;
    subtractFee = false;
    feeType = 'recommended';
    confirmationTarget = 20;
    useMinimumFee = false;
    replaceByFee = false;
    notifyListeners();
  }

  void sendTransaction() {
    // Implement the logic to send the transaction
    // This should use the values from all form fields, including the new fee-related fields
    // You'll need to integrate this with your DrivechainService
  }
}
