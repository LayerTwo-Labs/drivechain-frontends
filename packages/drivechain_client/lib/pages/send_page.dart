import 'package:auto_route/auto_route.dart';
import 'package:drivechain_client/service.dart';
import 'package:drivechain_client/util/currencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money2/money2.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:super_clipboard/super_clipboard.dart';

@RoutePage()
class SendPage extends StatelessWidget {
  const SendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: 12.0,
              right: 12.0,
              top: 12.0,
              bottom: 4.0,
            ),
            child: QtContainer(
              child: SendDetailsForm(),
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
              child: Container(),
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
                future: DrivechainService.of(context).getBalance(),
                builder: (context, snapshot) {
                  return RichText(
                    text: TextSpan(
                      style: SailStyleValues.twelve.copyWith(
                        color: SailTheme.of(context).colors.text,
                      ),
                      text: 'Balance: ',
                      children: [
                        /*TextSpan(
                          text: Money.fromNumWithCurrency(1000, satoshi).toString(),
                        ),*/
                        if (snapshot.hasData)
                          TextSpan(
                            text: Money.fromNumWithCurrency(
                              snapshot.data!.confirmedSatoshi.toDouble() +
                                  snapshot.data!.pendingSatoshi.toDouble(),
                              satoshi,
                            ).toString(),
                          ),
                        if (snapshot.hasError)
                          TextSpan(
                            text: 'Error: ${snapshot.error}',
                          ),
                        if (!snapshot.hasData && !snapshot.hasError)
                          const TextSpan(
                            text: 'Loading...',
                          ),
                      ],
                    ),
                  );
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
                        horizontal: 4.0, vertical: 2.0,),
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
  }
}

const _kLabelWidth = 50.0;

class SendDetailsForm extends StatefulWidget {
  const SendDetailsForm({super.key});

  @override
  State<SendDetailsForm> createState() => _SendDetailsFormState();
}

class _SendDetailsFormState extends State<SendDetailsForm> {
  late String _unit;
  late TextEditingController _addressController;
  late TextEditingController _labelController;
  late TextEditingController _amountController;
  late bool _subtractFee;
  late bool _useBalance;

  @override
  void initState() {
    super.initState();

    _unit = 'BTC';
    _addressController = TextEditingController(text: '');
    _labelController = TextEditingController(text: '');
    _amountController = TextEditingController(text: '0.00');
    _subtractFee = false;
    _useBalance = false;
  }

  void _onUnitChanged(String value) {
    setState(() {
      _unit = value;
    });
  }

  void _onSubtractFeeChanged(bool value) {
    setState(() {
      _subtractFee = value;
    });
  }

  Future<void> _onUseAvailableBalance() async {
    // Get the balance from the node
    await DrivechainService.of(context).getBalance().then((balance) {
      setState(() {
        _amountController.text = balance.confirmedSatoshi.toDouble().toString();
      });
    }).catchError((error) {
      if (mounted) {
        showSnackBar(context, 'Error: $error');
      }
    });
  }

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
                // TODO: Validate address
                controller: _addressController,
                hintText:
                    'Enter a Drivechain address (e.g. 1NS17iag9jJgTHD1VXjvLCEnZuQ3rJDE9L)',
                size: TextFieldSize.small,
                dense: true,
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
                      _addressController.text = text ?? _addressController.text;
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
              onPressed: () {
                _addressController.clear();
              },
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
                controller: _labelController,
                hintText:
                    'Enter a label for this address to add it to your address book',
                size: TextFieldSize.small,
                dense: true,
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
                controller: _amountController,
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
                        value: _unit,
                        onChanged: _onUnitChanged,
                      ),
                      const SizedBox(width: 24.0),
                      SailCheckbox(
                        value: _subtractFee,
                        onChanged: _onSubtractFeeChanged,
                        label: 'Subtract fee from amount',
                      ),
                    ],
                  ),
                  QtButton(
                    onPressed: _onUseAvailableBalance,
                    child: const Text('Use available balance'),
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

class UnitDropdown extends StatelessWidget {
  final String value;
  final Function(String) onChanged;

  const UnitDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 128.0,
      ),
      child: SailDropdownButton(
        width: 128.0,
        items: [
          SailDropdownItem(
            value: 'BTC',
            child: SailText.primary12('BTC'),
          ),
          SailDropdownItem(
            value: 'mBTC',
            child: SailText.primary12('mBTC'),
          ),
          SailDropdownItem(
            value: 'µBTC',
            child: SailText.primary12('µBTC (bits)'),
          ),
          SailDropdownItem(
            value: 'sats',
            child: SailText.primary12('sats'),
          ),
        ],
        onChanged: onChanged,
        value: value,
      ),
    );
  }
}

class NumericField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final Function(String)? onEditingComplete;
  final Function(String)? onSubmitted;
  final String? hintText;
  final bool? enabled;
  final bool? readOnly;
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
    this.readOnly = false,
    this.error = '',
  });

  @override
  State<NumericField> createState() => _NumericFieldState();
}

class _NumericFieldState extends State<NumericField> {
  late TextEditingController _controller = TextEditingController(text: '0.00');
  late FocusNode _focusNode;
  late ValueNotifier<String> _value;
  late ValueNotifier<bool> _isEditing;
  late ValueNotifier<String> _error;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? TextEditingController(text: '0.00');
    _focusNode = widget.focusNode ?? FocusNode();
    _value = ValueNotifier(widget.controller?.text ?? '0.00');
    _isEditing = ValueNotifier(false);
    _error = ValueNotifier(widget.error ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return SailTextField(
      controller: _controller,
      hintText: 'Amount',
      focusNode: _focusNode,
      textFieldType: TextFieldType.bitcoin,
      size: TextFieldSize.small,
      dense: true,
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
      horizontal: 12.0,
      vertical: 0.0,
    ),
    this.large = false,
    this.important = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWindows = theme.platform == TargetPlatform.windows;

    Color textColor;
    if (enabled && onPressed != null) {
      textColor = SailTheme.of(context).colors.text;
    } else {
      textColor = SailTheme.of(context).colors.textTertiary;
    }

    return SizedBox(
      height: large ? 32 : 24,
      child: MaterialButton(
        visualDensity: VisualDensity.compact,
        // textTheme: textTheme,
        color: SailTheme.of(context).colors.background,
        hoverColor: SailTheme.of(context).colors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(isWindows ? 3 : 6)),
          side: const BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        onPressed: enabled ? onPressed : null,
        elevation: 0,
        hoverElevation: 0,
        focusElevation: 0,

        minWidth: 32,
        padding: EdgeInsets.zero,
        child: Container(
          alignment: Alignment.center,
          height: large ? 32 : 24,
          padding: padding,
          child: DefaultTextStyle(
            style: SailStyleValues.twelve.copyWith(color: textColor),
            child: child,
          ),
        ),
      ),
    );
  }
}
