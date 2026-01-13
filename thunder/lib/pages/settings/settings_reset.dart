import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:thunder/main.dart';

class SettingsReset extends StatefulWidget {
  const SettingsReset({super.key});

  @override
  State<SettingsReset> createState() => _SettingsResetState();
}

class _SettingsResetState extends State<SettingsReset> {
  Future<void> _onResetAllChains() async {
    await showDialog(
      context: context,
      builder: (context) => SailAlertCard(
        title: 'Reset All Blockchain Data?',
        subtitle:
            'Are you sure you want to reset all blockchain data for thunder? Wallets are not touched. This action cannot be undone.',
        confirmButtonVariant: ButtonVariant.destructive,
        onConfirm: () async {
          final binaryProvider = GetIt.I.get<BinaryProvider>();

          final binary = Thunder();

          await binaryProvider.stop(binary);

          await Future.delayed(const Duration(seconds: 3));

          await binary.wipeAppDir();

          bootBinaries(GetIt.I.get<Logger>());

          final thunderRPC = GetIt.I.get<ThunderRPC>();
          while (!thunderRPC.connected) {
            await Future.delayed(const Duration(seconds: 1));
          }

          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary20('Reset'),
            SailText.secondary13('Reset blockchain data'),
          ],
        ),
        SailButton(
          label: 'Reset Thunder Data',
          variant: ButtonVariant.destructive,
          onPressed: _onResetAllChains,
        ),
      ],
    );
  }
}
