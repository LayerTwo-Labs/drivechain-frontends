import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class DenialDialog extends StatefulWidget {
  final Function(int hops, int delaySeconds) onSubmit;

  const DenialDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<DenialDialog> createState() => _DenialDialogState();
}

class _DenialDialogState extends State<DenialDialog> {
  final hopsController = TextEditingController(text: '3');
  final minutesController = TextEditingController(text: '0');
  final hoursController = TextEditingController(text: '1');
  final daysController = TextEditingController(text: '0');

  Future<void> setNormalDefaults() async {
    setState(() {
      hopsController.text = '3';
      minutesController.text = '0';
      hoursController.text = '2';
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
    final theme = context.sailTheme;

    return Dialog(
      backgroundColor: theme.colors.backgroundSecondary,
      child: IntrinsicHeight(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SailRawCard(
            padding: true,
            title: 'Start Automatic Denial',
            subtitle: '',
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
                    SizedBox(
                      width: 90,
                      child: SailTextField(
                        controller: minutesController,
                        size: TextFieldSize.small,
                        textFieldType: TextFieldType.number,
                        hintText: '0',
                      ),
                    ),
                    SailText.primary15('min'),
                    SizedBox(
                      width: 90,
                      child: SailTextField(
                        controller: hoursController,
                        size: TextFieldSize.small,
                        textFieldType: TextFieldType.number,
                        hintText: '0',
                      ),
                    ),
                    SailText.primary15('hr'),
                    SizedBox(
                      width: 90,
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

                const SizedBox(height: 16),

                // Default buttons
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    SailText.primary15('Defaults:'),
                    QtButton(
                      label: 'Normal',
                      onPressed: setNormalDefaults,
                      size: ButtonSize.small,
                      style: SailButtonStyle.secondary,
                    ),
                    QtButton(
                      label: 'Paranoid',
                      onPressed: setParanoidDefaults,
                      size: ButtonSize.small,
                      style: SailButtonStyle.secondary,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action buttons
                SailRow(
                  spacing: SailStyleValues.padding08,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    QtButton(
                      label: 'Start',
                      onPressed: () async {
                        final hops = int.tryParse(hopsController.text) ?? 3;
                        await widget.onSubmit(hops, getTotalSeconds());
                        if (context.mounted) Navigator.pop(context);
                      },
                      size: ButtonSize.small,
                    ),
                    SailTextButton(
                      label: 'Cancel',
                      onPressed: () async => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
