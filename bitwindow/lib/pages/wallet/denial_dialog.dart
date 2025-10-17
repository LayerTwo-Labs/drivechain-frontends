import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class DenialDialog extends StatefulWidget {
  final String output;

  const DenialDialog({
    super.key,
    required this.output,
  });

  @override
  State<DenialDialog> createState() => _DenialDialogState();
}

class _DenialDialogState extends State<DenialDialog> {
  final BitwindowRPC api = GetIt.I.get<BitwindowRPC>();
  final TransactionProvider transactionProvider = GetIt.I.get<TransactionProvider>();

  final hopsController = TextEditingController(text: '3');
  final minutesController = TextEditingController(text: '2');
  final hoursController = TextEditingController(text: '0');
  final daysController = TextEditingController(text: '0');

  Future<void> setNormalDefaults() async {
    setState(() {
      hopsController.text = '3';
      minutesController.text = '2';
      hoursController.text = '0';
      daysController.text = '0';
    });
  }

  Future<void> setParanoidDefaults() async {
    setState(() {
      hopsController.text = '6';
      minutesController.text = '0';
      hoursController.text = '0';
      daysController.text = '2';
    });
  }

  int getTotalSeconds() {
    final minutes = int.tryParse(minutesController.text) ?? 0;
    final hours = int.tryParse(hoursController.text) ?? 0;
    final days = int.tryParse(daysController.text) ?? 0;

    return minutes * 60 + hours * 3600 + days * 86400;
  }

  @override
  void dispose() {
    hopsController.dispose();
    minutesController.dispose();
    hoursController.dispose();
    daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SailDialog(
      title: 'Start Automatic Denial',
      maxWidth: 700,
      maxHeight: 600,
      actions: [
        SailButton(
          label: 'Cancel',
          onPressed: () async => Navigator.pop(context),
          variant: ButtonVariant.secondary,
        ),
        SailButton(
          label: 'Start',
          onPressed: () async {
            final hops = int.tryParse(hopsController.text) ?? 3;
            await api.bitwindowd.createDenial(
              txid: widget.output.split(':').first,
              vout: int.parse(widget.output.split(':').last),
              numHops: hops,
              delaySeconds: getTotalSeconds(),
            );
            await transactionProvider.fetch();
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ],
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delay input row
          SailText.primary15('Send coins to yourself...'),
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SailText.primary15('...with random delays of up to'),
              Expanded(
                child: SailTextField(
                  controller: minutesController,
                  size: TextFieldSize.small,
                  textFieldType: TextFieldType.number,
                  hintText: '0',
                ),
              ),
              SailText.primary15('min'),
              Expanded(
                child: SailTextField(
                  controller: hoursController,
                  size: TextFieldSize.small,
                  textFieldType: TextFieldType.number,
                  hintText: '0',
                ),
              ),
              SailText.primary15('hr'),
              Expanded(
                child: SailTextField(
                  controller: daysController,
                  size: TextFieldSize.small,
                  textFieldType: TextFieldType.number,
                  hintText: '0',
                ),
              ),
              SailText.primary15('day(s)...'),
            ],
          ),

          // Hops input row
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SailText.primary15('...and stop after'),
              SizedBox(
                width: 90,
                child: SailTextField(
                  controller: hopsController,
                  size: TextFieldSize.small,
                  textFieldType: TextFieldType.number,
                  hintText: '3 hops',
                ),
              ),
              SailText.primary15('hops.'),
            ],
          ),

          // Default buttons
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SailText.primary15('Defaults:'),
              SailButton(
                label: 'Normal',
                onPressed: setNormalDefaults,
                variant: ButtonVariant.secondary,
              ),
              SailButton(
                label: 'Paranoid',
                onPressed: setParanoidDefaults,
                variant: ButtonVariant.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
