import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class CpuMiningDialog extends StatefulWidget {
  const CpuMiningDialog({super.key});

  @override
  State<CpuMiningDialog> createState() => _CpuMiningDialogState();
}

class _CpuMiningDialogState extends State<CpuMiningDialog> {
  MiningProvider get _miningProvider => GetIt.I.get<MiningProvider>();

  @override
  void initState() {
    super.initState();
    _miningProvider.refreshStatus();
    _miningProvider.addListener(_onMiningStateChanged);
  }

  @override
  void dispose() {
    _miningProvider.removeListener(_onMiningStateChanged);
    super.dispose();
  }

  void _onMiningStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _startMiner() async {
    await _miningProvider.startMining();
    if (mounted && _miningProvider.error != null) {
      showSailToast(context, 'Failed to start mining: ${_miningProvider.error}');
    }
  }

  Future<void> _stopMiner() async {
    await _miningProvider.stopMining();
    if (mounted && _miningProvider.error != null) {
      showSailToast(context, 'Failed to stop mining: ${_miningProvider.error}');
    }
  }

  Future<void> _restartMiner() async {
    await _stopMiner();
    await Future.delayed(const Duration(milliseconds: 500));
    await _startMiner();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final isRunning = _miningProvider.isMining;

    return SailDialog(
      title: 'CPU Miner',
      subtitle: 'Mine blocks on eCash with your own CPU',
      error: _miningProvider.error,
      maxWidth: 600,
      withCloseButton: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRunning ? theme.colors.success : theme.colors.text.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(width: SailStyleValues.padding08),
              SailText.primary20(isRunning ? 'Running' : 'Stopped', bold: true),
            ],
          ),
          if (isRunning) ...[
            const SizedBox(height: SailStyleValues.padding16),
            SailText.secondary13('Hash Rate: ${_miningProvider.formattedHashRate}'),
          ],
          if (_miningProvider.blocksFound > 0) ...[
            const SizedBox(height: SailStyleValues.padding08),
            SailText.secondary13('Blocks Found: ${_miningProvider.blocksFound}'),
          ],
          if (_miningProvider.foundBlockHashes.isNotEmpty) ...[
            const SizedBox(height: SailStyleValues.padding16),
            SailText.primary13('Recent Blocks:', bold: true),
            const SizedBox(height: SailStyleValues.padding08),
            ..._miningProvider.foundBlockHashes
                .take(5)
                .map(
                  (hash) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SailText.secondary12(hash),
                  ),
                ),
          ],
          const SizedBox(height: SailStyleValues.padding20),
          Row(
            children: [
              Expanded(
                child: SailButton(
                  label: 'Start',
                  onPressed: () async => await _startMiner(),
                  disabled: isRunning,
                ),
              ),
              const SizedBox(width: SailStyleValues.padding12),
              Expanded(
                child: SailButton(
                  label: 'Stop',
                  onPressed: () async => await _stopMiner(),
                  variant: ButtonVariant.secondary,
                  disabled: !isRunning,
                ),
              ),
              const SizedBox(width: SailStyleValues.padding12),
              Expanded(
                child: SailButton(
                  label: 'Restart',
                  onPressed: () async => await _restartMiner(),
                  variant: ButtonVariant.secondary,
                  disabled: !isRunning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
