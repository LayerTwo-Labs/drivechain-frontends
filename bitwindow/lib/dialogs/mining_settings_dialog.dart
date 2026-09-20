import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class MiningSettingsDialog extends StatefulWidget {
  const MiningSettingsDialog({super.key});

  @override
  State<MiningSettingsDialog> createState() => _MiningSettingsDialogState();
}

class _MiningSettingsDialogState extends State<MiningSettingsDialog> {
  late final StratumProvider _stratum = GetIt.I.get<StratumProvider>();

  late final TextEditingController _port;
  late final TextEditingController _threads;
  late bool _cpuMining;
  late bool _keepMining;
  String? _error;

  @override
  void initState() {
    super.initState();
    final settings = _stratum.status.settings;
    _port = TextEditingController(text: '${settings.port}');
    _threads = TextEditingController(text: '${settings.cpuThreads}');
    _cpuMining = settings.cpuMining;
    _keepMining = settings.keepMiningOnClose;
  }

  @override
  void dispose() {
    _port.dispose();
    _threads.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final port = int.tryParse(_port.text.trim());
    if (port == null || port < 1 || port > 65535) {
      setState(() => _error = 'The port must be a number from 1 to 65535');
      return;
    }
    final threads = int.tryParse(_threads.text.trim());
    if (threads == null || threads < 1) {
      setState(() => _error = 'The thread count must be 1 or more');
      return;
    }
    try {
      await _stratum.setMiningSettings(
        port: port,
        cpuMining: _cpuMining,
        cpuThreads: threads,
        keepMiningOnClose: _keepMining,
      );
    } catch (e) {
      setState(() => _error = extractConnectException(e));
      return;
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SailDialog(
      title: 'Mining settings',
      error: _error,
      maxWidth: 520,
      withCloseButton: true,
      actions: [
        SailButton(
          label: 'Cancel',
          variant: ButtonVariant.secondary,
          onPressed: () async => Navigator.of(context).pop(),
        ),
        SailButton(label: 'Save', onPressed: _save),
      ],
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _row(
            'Port',
            SizedBox(
              width: 120,
              child: SailTextField(controller: _port, hintText: '3333', textFieldType: TextFieldType.number),
            ),
          ),
          _row(
            'Mine with this computer',
            SailSwitch(value: _cpuMining, onChanged: (next) => setState(() => _cpuMining = next)),
          ),
          _row(
            'CPU threads',
            SizedBox(
              width: 120,
              child: SailTextField(controller: _threads, hintText: '4', textFieldType: TextFieldType.number),
            ),
          ),
          _row(
            'Keep mining when bitwindow closes',
            SailSwitch(value: _keepMining, onChanged: (next) => setState(() => _keepMining = next)),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, Widget control) {
    return SailRow(
      spacing: SailStyleValues.padding12,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: SailText.primary13(label)),
        control,
      ],
    );
  }
}
