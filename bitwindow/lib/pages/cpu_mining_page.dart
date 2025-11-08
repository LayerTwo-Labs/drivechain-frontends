import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class CpuMiningPage extends StatefulWidget {
  const CpuMiningPage({super.key});

  @override
  State<CpuMiningPage> createState() => _CpuMiningPageState();
}

class _CpuMiningPageState extends State<CpuMiningPage> {
  BinaryProvider get _binaryProvider => GetIt.I.get<BinaryProvider>();
  CPUMiner get _cpuMinerBinary => _binaryProvider.binaries.firstWhere((b) => b.type == BinaryType.cpuMiner) as CPUMiner;

  final _threadCountController = TextEditingController(text: '1');
  final _coinbaseAddressController = TextEditingController();

  @override
  void dispose() {
    _threadCountController.dispose();
    _coinbaseAddressController.dispose();
    super.dispose();
  }

  Future<void> _startMiner() async {
    try {
      final threads = int.tryParse(_threadCountController.text) ?? 1;
      if (threads < 1 || threads > 99) {
        if (mounted) {
          showSnackBar(context, 'Thread count must be between 1 and 99');
        }
        return;
      }

      final coinbaseAddress = _coinbaseAddressController.text.trim();

      final args = <String>[
        '-t',
        threads.toString(),
      ];

      if (coinbaseAddress.isNotEmpty) {
        args.addAll(['--coinbase-addr', coinbaseAddress]);
      }

      _cpuMinerBinary.extraBootArgs = args;
      await _binaryProvider.start(_cpuMinerBinary);

      if (mounted) {
        showSnackBar(context, 'CPU miner started');
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Failed to start: $e');
      }
    }
  }

  Future<void> _stopMiner() async {
    try {
      await _binaryProvider.stop(_cpuMinerBinary);
      if (mounted) {
        showSnackBar(context, 'CPU miner stopped');
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Failed to stop: $e');
      }
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

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        foregroundColor: theme.colors.text,
        title: SailText.primary20('CPU Miner', bold: true),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _binaryProvider,
          builder: (context, child) {
            if (!_cpuMinerBinary.isDownloaded) {
              return _buildDownloadScreen(theme);
            }

            final isRunning = _binaryProvider.isRunning(_cpuMinerBinary);
            return _buildConfigScreen(theme, isRunning);
          },
        ),
      ),
    );
  }

  Widget _buildDownloadScreen(SailThemeData theme) {
    final downloadInfo = _binaryProvider.downloadProgress(BinaryType.cpuMiner);
    final isDownloading = downloadInfo.isDownloading;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SailText.primary24(
              'CPU Miner',
              bold: true,
            ),
            const SizedBox(height: 8),
            SailText.secondary13(
              'Download the CPU miner to start mining',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            if (isDownloading) ...[
              SizedBox(
                width: 400,
                child: ChainLoader(
                  name: 'CPU Miner',
                  syncInfo: SyncInfo(
                    progressCurrent: downloadInfo.progress,
                    progressGoal: downloadInfo.total,
                    lastBlockAt: null,
                    downloadInfo: downloadInfo,
                  ),
                  justPercent: true,
                  expanded: false,
                ),
              ),
            ] else ...[
              SizedBox(
                width: 300,
                child: SailButton(
                  label: 'Download CPU Miner',
                  onPressed: () async {
                    try {
                      await _binaryProvider.download(_cpuMinerBinary);
                    } catch (e) {
                      if (mounted) {
                        showSnackBar(context, 'Failed to download: $e');
                      }
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfigScreen(SailThemeData theme, bool isRunning) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SailCard(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildStatusSection(theme, isRunning),
                const SizedBox(height: 30),
                _buildConfigSection(theme, isRunning),
                const SizedBox(height: 30),
                _buildControlSection(theme, isRunning),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection(SailThemeData theme, bool isRunning) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
            SailText.primary20(
              isRunning ? 'Running' : 'Stopped',
              bold: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfigSection(SailThemeData theme, bool isRunning) {
    return SizedBox(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SailTextField(
            controller: _threadCountController,
            label: 'Thread Count',
            hintText: '1',
            enabled: !isRunning,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            textFieldType: TextFieldType.number,
          ),
          const SizedBox(height: SailStyleValues.padding12),
          SailTextField(
            controller: _coinbaseAddressController,
            label: 'Coinbase Address (optional)',
            hintText: 'Bitcoin address for block rewards',
            enabled: !isRunning,
          ),
        ],
      ),
    );
  }

  Widget _buildControlSection(SailThemeData theme, bool isRunning) {
    return SizedBox(
      width: 400,
      child: Row(
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
    );
  }
}
