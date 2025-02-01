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
  final delayController = TextEditingController(text: '3600');

  @override
  void dispose() {
    hopsController.dispose();
    delayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return Dialog(
      backgroundColor: theme.colors.backgroundSecondary,
      child: IntrinsicHeight(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SailRawCard(
            padding: true,
            title: 'Create Denial',
            subtitle: 'Create Denials for your full wallet balance',
            widgetHeaderEnd: SailTextButton(
              label: '×',
              onPressed: () => Navigator.of(context).pop(),
            ),
            child: Padding(
              padding: const EdgeInsets.all(SailStyleValues.padding16),
              child: SailColumn(
                spacing: SailStyleValues.padding12,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SailTextField(
                    label: 'Number of hops',
                    hintText: 'Enter number of hops (default: 3)',
                    controller: hopsController,
                    textFieldType: TextFieldType.number,
                    size: TextFieldSize.small,
                  ),
                  SailTextField(
                    label: 'Delay between hops (seconds)',
                    hintText: 'Enter delay in seconds (default: 3600)',
                    controller: delayController,
                    textFieldType: TextFieldType.number,
                    size: TextFieldSize.small,
                  ),

                  // Action buttons
                  SailRow(
                    spacing: SailStyleValues.padding08,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      QtButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        size: ButtonSize.small,
                      ),
                      QtButton(
                        label: 'Create',
                        onPressed: () {
                          final hops = int.tryParse(hopsController.text) ?? 3;
                          final delay = int.tryParse(delayController.text) ?? 3600;
                          widget.onSubmit(hops, delay);
                          Navigator.pop(context);
                        },
                        size: ButtonSize.small,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
