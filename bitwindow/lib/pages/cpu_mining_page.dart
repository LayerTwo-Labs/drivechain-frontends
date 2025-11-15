import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/providers/mining_provider.dart';
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
  WalletReaderProvider get _walletReader => GetIt.I.get<WalletReaderProvider>();
  BitwindowRPC get _bitwindowRPC => GetIt.I.get<BitwindowRPC>();
  MiningProvider get _miningProvider => GetIt.I.get<MiningProvider>();

  final _threadCountController = TextEditingController(text: '1');
  String _coinbaseAddress = '';
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _loadCoinbaseAddress();
    _miningProvider.addListener(_onMiningStateChanged);
  }

  @override
  void dispose() {
    _miningProvider.removeListener(_onMiningStateChanged);
    _threadCountController.dispose();
    super.dispose();
  }

  void _onMiningStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadCoinbaseAddress() async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId != null) {
        final address = await _bitwindowRPC.wallet.getNewAddress(walletId);
        setState(() {
          _coinbaseAddress = address;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _startMiner() async {
    await _miningProvider.startMining();
    if (mounted && _miningProvider.error != null) {
      showSnackBar(context, 'Failed to start mining: ${_miningProvider.error}');
    }
  }

  Future<void> _stopMiner() async {
    await _miningProvider.stopMining();
    if (mounted && _miningProvider.error != null) {
      showSnackBar(context, 'Failed to stop mining: ${_miningProvider.error}');
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
        child: _buildConfigScreen(theme, _miningProvider.isMining),
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
        if (isRunning) ...[
          const SizedBox(height: SailStyleValues.padding16),
          SailText.secondary13(
            'Hash Rate: ${_miningProvider.hashRate.toStringAsFixed(2)} H/s',
          ),
        ],
        if (_miningProvider.blocksFound > 0) ...[
          const SizedBox(height: SailStyleValues.padding08),
          SailText.secondary13(
            'Blocks Found: ${_miningProvider.blocksFound}',
          ),
        ],
        if (_miningProvider.foundBlockHashes.isNotEmpty) ...[
          const SizedBox(height: SailStyleValues.padding16),
          SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
            ),
          ),
        ],
        if (_miningProvider.error != null) ...[
          const SizedBox(height: SailStyleValues.padding16),
          SizedBox(
            width: 500,
            child: SailText.primary12(
              'Error: ${_miningProvider.error}',
              color: theme.colors.error,
            ),
          ),
        ],
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
          const SizedBox(height: SailStyleValues.padding16),
          SailTextField(
            loading: LoadingDetails(
              enabled: _isLoadingAddress,
              description: 'Generating address...',
            ),
            label: 'Coinbase Address',
            controller: TextEditingController(text: _coinbaseAddress),
            hintText: 'Block rewards will be sent to this address',
            readOnly: true,
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
