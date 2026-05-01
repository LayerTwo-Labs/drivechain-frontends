import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Confirms a Bitcoin network change. Routes through bitwindowd's
/// `UpdateNetwork` RPC: orchestratord rewrites the conf and restarts
/// bitcoind on the new chain, then bitwindowd recycles its DB + engines
/// in-process. The bitwindowd HTTP server stays up across the swap on
/// the same port — no process restart, no launcher dance.
class NetworkSwapPage extends StatefulWidget {
  final BitcoinNetwork fromNetwork;
  final BitcoinNetwork toNetwork;

  const NetworkSwapPage({
    super.key,
    required this.fromNetwork,
    required this.toNetwork,
  });

  @override
  State<NetworkSwapPage> createState() => _NetworkSwapPageState();
}

class _NetworkSwapPageState extends State<NetworkSwapPage> {
  Logger get _log => GetIt.I.get<Logger>();
  BitwindowRPC get _bitwindow => GetIt.I.get<BitwindowRPC>();

  final _SwapStep _step = _SwapStep('Switching network');

  bool _isSwapping = false;
  bool _swapComplete = false;
  String? _error;

  Future<void> _startSwap() async {
    setState(() {
      _isSwapping = true;
      _error = null;
      _step.startTime = DateTime.now();
      _step.endTime = null;
    });

    try {
      await _bitwindow.bitwindowd.updateNetwork(_networkToString(widget.toNetwork));
      if (mounted) {
        setState(() {
          _step.endTime = DateTime.now();
          _swapComplete = true;
        });
      }
    } catch (e) {
      _log.e('NetworkSwapPage: swap failed: $e');
      if (mounted) {
        setState(() {
          _step.endTime = DateTime.now();
          _error = e.toString();
        });
      }
    }
  }

  void _handleBack() {
    Navigator.of(context).pop(_isSwapping);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final fromName = widget.fromNetwork.toDisplayName();
    final toName = widget.toNetwork.toDisplayName();

    return PopScope(
      canPop: !_isSwapping || _swapComplete || _error != null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && (_swapComplete || _error != null)) {
          Navigator.of(context).pop(_swapComplete);
        }
      },
      child: Scaffold(
        backgroundColor: theme.colors.background,
        appBar: AppBar(
          backgroundColor: theme.colors.background,
          foregroundColor: theme.colors.text,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _isSwapping && !_swapComplete && _error == null ? null : _handleBack,
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: SizedBox(
                    width: 800,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          SailRow(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: SailStyleValues.padding12,
                            children: [
                              if (_swapComplete)
                                Icon(
                                  Icons.check_circle,
                                  color: theme.colors.success,
                                  size: 32,
                                )
                              else if (_error != null)
                                Icon(
                                  Icons.error,
                                  color: theme.colors.error,
                                  size: 32,
                                )
                              else
                                SailSVG.fromAsset(
                                  SailSVGAsset.iconRestart,
                                  color: theme.colors.primary,
                                  width: 32,
                                  height: 32,
                                ),
                              SailText.primary24(
                                _swapComplete
                                    ? 'Network Switch Complete'
                                    : _error != null
                                    ? 'Network Switch Failed'
                                    : 'Switch Bitcoin Network',
                                bold: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SailText.secondary13(
                            _swapComplete
                                ? 'Switched from $fromName to $toName.'
                                : _error != null
                                ? _error!
                                : _isSwapping
                                ? 'Switching from $fromName to $toName...'
                                : 'BitWindow will swap bitcoind to $toName and reload its data — the app stays open. Switching from $fromName to $toName.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          if (_isSwapping || _swapComplete || _error != null)
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: theme.colors.backgroundSecondary,
                                borderRadius: SailStyleValues.borderRadiusSmall,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(SailStyleValues.padding12),
                                child: ProgressStepTile(
                                  name: _step.name,
                                  isCompleted: _step.isCompleted,
                                  duration: _step.duration,
                                  isActive: _isSwapping && !_step.isCompleted,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              BottomActionBar(
                children: [
                  if (!_isSwapping) ...[
                    SailButton(
                      label: 'Cancel',
                      onPressed: () async => Navigator.of(context).pop(false),
                    ),
                    const SizedBox(width: SailStyleValues.padding12),
                    SailButton(
                      label: 'Switch to $toName',
                      variant: ButtonVariant.primary,
                      onPressed: () async => await _startSwap(),
                    ),
                  ] else if (_swapComplete)
                    SailButton(
                      label: 'Continue',
                      variant: ButtonVariant.primary,
                      onPressed: () async => _handleBack(),
                    )
                  else if (_error != null)
                    SailButton(
                      label: 'Close',
                      variant: ButtonVariant.secondary,
                      onPressed: () async => _handleBack(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwapStep {
  final String name;
  DateTime? startTime;
  DateTime? endTime;

  _SwapStep(this.name);

  bool get isCompleted => endTime != null;
  Duration? get duration => (startTime != null && endTime != null) ? endTime!.difference(startTime!) : null;
}

String _networkToString(BitcoinNetwork network) {
  switch (network) {
    case BitcoinNetwork.BITCOIN_NETWORK_MAINNET:
      return 'mainnet';
    case BitcoinNetwork.BITCOIN_NETWORK_FORKNET:
      return 'forknet';
    case BitcoinNetwork.BITCOIN_NETWORK_TESTNET:
      return 'testnet';
    case BitcoinNetwork.BITCOIN_NETWORK_SIGNET:
      return 'signet';
    case BitcoinNetwork.BITCOIN_NETWORK_REGTEST:
      return 'regtest';
    default:
      return 'signet';
  }
}
