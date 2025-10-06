import 'package:bitwindow/providers/mining_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';

class CpuMiningModal extends StatefulWidget {
  const CpuMiningModal({super.key});

  @override
  State<CpuMiningModal> createState() => _CpuMiningModalState();
}

class _CpuMiningModalState extends State<CpuMiningModal> {
  late MiningProvider _miningProvider;
  final _threadCountController = TextEditingController(text: '1');
  String _lastCurrentHash = '';
  bool _hashFlash = false;

  @override
  void initState() {
    super.initState();
    _miningProvider = MiningProvider();
    _threadCountController.text = _miningProvider.threadCount.toString();
    _miningProvider.addListener(_onMiningUpdate);
  }

  void _onMiningUpdate() {
    if (_miningProvider.currentHash != _lastCurrentHash && _miningProvider.currentHash.isNotEmpty) {
      _lastCurrentHash = _miningProvider.currentHash;
      setState(() => _hashFlash = true);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() => _hashFlash = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _miningProvider.removeListener(_onMiningUpdate);
    _threadCountController.dispose();
    _miningProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return ListenableBuilder(
      listenable: _miningProvider,
      builder: (context, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650, maxHeight: 600),
            child: SailCard(
              title: 'Mining',
              child: SingleChildScrollView(
                child: SailColumn(
                  spacing: SailStyleValues.padding16,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Show signet warning if on signet network
                    if (_miningProvider.isSignet) ...[
                      _buildSignetWarning(theme),
                      const Divider(),
                    ],
                    _buildNetworkInfo(theme, _miningProvider),
                    const Divider(),
                    _buildSettings(theme, _miningProvider),
                    _buildControls(theme, _miningProvider),
                    if (_miningProvider.isMining) ...[
                      const Divider(),
                      _buildMinerOutput(theme, _miningProvider),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkInfo(SailThemeData theme, MiningProvider provider) {
    return SailColumn(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary13('Network info'),
        for (final item in [
          {'label': 'Current block height:', 'value': '${provider.currentHeight}'},
          {'label': 'Current block weight:', 'value': '${provider.blockWeight}'},
          {'label': 'Current block txns:', 'value': '${provider.blockTxns}'},
          {'label': 'Difficulty:', 'value': provider.difficulty.toStringAsFixed(6)},
          {'label': 'Network hash/s:', 'value': _formatHashRate(provider.networkHashPs)},
          {'label': 'Pooled txns:', 'value': '${provider.pooledTxns}'},
        ])
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 160,
                child: SailText.primary13(item['label'] as String, bold: true),
              ),
              Expanded(
                child: SailText.primary13(
                  item['value'] as String,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSettings(SailThemeData theme, MiningProvider provider) {
    return SailColumn(
      spacing: SailStyleValues.padding12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailCheckbox(
          value: provider.abandonFailedBMM,
          onChanged: (value) => provider.setAbandonFailedBMM(value),
          label: 'Abandon failed BMM requests',
        ),
        SailColumn(
          spacing: SailStyleValues.padding04,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SailText.primary13('Hashing speed', bold: true),
                SailText.primary13('${provider.hashingSpeed}%'),
              ],
            ),
            Slider(
              value: provider.hashingSpeed.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              label: '${provider.hashingSpeed}%',
              onChanged: (value) {
                provider.setHashingSpeed(value.toInt());
              },
              activeColor: theme.colors.primary,
              inactiveColor: theme.colors.text.withValues(alpha: 0.3),
            ),
            SailText.secondary12(
              'Lower speed reduces CPU usage but mines slower. Can be adjusted anytime.',
              italic: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls(SailThemeData theme, MiningProvider provider) {
    return SailColumn(
      spacing: SailStyleValues.padding16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mining controls row
        Row(
          children: [
            SizedBox(
              width: 120,
              child: SailTextField(
                controller: _threadCountController,
                enabled: !provider.isMining && !provider.isSignet,
                hintText: '1',
                suffix: 'Thread(s)',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                textFieldType: TextFieldType.number,
                size: TextFieldSize.small,
              ),
            ),
            const SizedBox(width: SailStyleValues.padding08),
            SailButton(
              label: provider.blockFound ? 'Block Found!' : 'Start Mining',
              loadingLabel: 'Mining...',
              onPressed: (provider.isMining || provider.blockFound || provider.isSignet)
                  ? null
                  : () async {
                      final threads = int.tryParse(_threadCountController.text) ?? 1;
                      if (threads < 1 || threads > 99) {
                        if (mounted) {
                          showSnackBar(context, 'Thread count must be between 1 and 99');
                        }
                        return;
                      }
                      try {
                        await provider.startMining(threads);
                      } catch (e) {
                        if (mounted) {
                          showSnackBar(context, 'Failed to start mining: $e');
                        }
                      }
                    },
              variant: provider.blockFound ? ButtonVariant.secondary : ButtonVariant.primary,
              small: true,
              loading: provider.isMining && !provider.blockFound,
              disabled: provider.isMining || provider.blockFound || provider.isSignet,
            ),
            const SizedBox(width: SailStyleValues.padding08),
            SailButton(
              label: provider.blockFound ? 'Reset' : 'Stop Mining',
              onPressed: (!provider.isMining && !provider.blockFound)
                  ? null
                  : () async {
                      try {
                        await provider.stopMining();
                      } catch (e) {
                        if (mounted) {
                          showSnackBar(context, 'Failed to stop mining: $e');
                        }
                      }
                    },
              variant: ButtonVariant.secondary,
              small: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMinerOutput(SailThemeData theme, MiningProvider provider) {
    final items = [
      {'label': 'Hash rate:', 'value': _formatHashRate(provider.hashRate), 'mono': false},
      if (provider.targetHash.isNotEmpty) {'label': 'Target hash:', 'value': provider.targetHash, 'mono': true},
      {'label': 'Current nonce:', 'value': '0x${provider.nonce.toRadixString(16).padLeft(8, '0')}', 'mono': true},
      if (provider.currentHash.isNotEmpty)
        {'label': 'Current hash:', 'value': provider.currentHash, 'mono': true, 'flash': true},
      if (provider.bestHash.isNotEmpty) {'label': 'Best hash:', 'value': provider.bestHash, 'mono': true},
      {'label': 'Best nonce:', 'value': '0x${provider.bestNonce.toRadixString(16).padLeft(8, '0')}', 'mono': true},
    ];

    return SailColumn(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary13('Miner output'),
        for (final item in items)
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            decoration: BoxDecoration(
              color: (item['flash'] == true && _hashFlash)
                  ? theme.colors.primary.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  child: SailText.primary13(item['label'] as String, bold: true),
                ),
                Expanded(
                  child: SailText.primary13(
                    item['value'] as String,
                    monospace: item['mono'] == true,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSignetWarning(SailThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding16),
      decoration: BoxDecoration(
        color: theme.colors.orange.withValues(alpha: 0.1),
        border: Border.all(color: theme.colors.orange),
        borderRadius: BorderRadius.circular(SailStyleValues.padding08),
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              Icon(
                Icons.warning,
                color: theme.colors.orange,
                size: 20,
              ),
              SailText.primary15(
                'CPU Mining Not Available',
                bold: true,
                color: theme.colors.orange,
              ),
            ],
          ),
          SailText.secondary13(
            'CPU mining is not supported on signet networks. To use the CPU mining tool, please connect to a testnet or mainnet network instead.',
          ),
        ],
      ),
    );
  }

  String _formatHashRate(double hashPs) {
    if (hashPs == 0) return '0';

    const units = ['', 'K', 'M', 'G', 'T', 'P', 'E'];
    int unitIndex = 0;
    double value = hashPs;

    while (value >= 1000 && unitIndex < units.length - 1) {
      value /= 1000;
      unitIndex++;
    }

    return '${value.toStringAsFixed(2)}${units[unitIndex]}';
  }
}
