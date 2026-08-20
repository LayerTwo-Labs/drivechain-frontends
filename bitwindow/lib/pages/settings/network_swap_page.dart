import 'package:flutter/widgets.dart';
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
  final String dataDir;

  /// Catalog id of the target row. The eCash entries share one [BitcoinNetwork],
  /// so the id decides which fork boots.
  final String networkId;

  const NetworkSwapPage({
    super.key,
    required this.fromNetwork,
    required this.toNetwork,
    this.dataDir = '',
    this.networkId = '',
  });

  @override
  State<NetworkSwapPage> createState() => _NetworkSwapPageState();
}

class _NetworkSwapPageState extends State<NetworkSwapPage> {
  Logger get _log => GetIt.I.get<Logger>();

  final _SwapStep _step = _SwapStep('Switching network');

  /// Names the block the move rewinds to, when it is between two eCash
  /// networks. They share their history below the fork, so a rewind beats a
  /// download of the whole chain. The backend does the rewind inside the swap.
  int? _rewindHeight;

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
      await _readRewindHeight();
      await GetIt.I.get<BitcoinConfProvider>().updateNetwork(
        widget.toNetwork,
        dataDir: widget.dataDir,
        networkId: widget.networkId,
      );
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

  /// Reads the block the backend rewinds to, so the step can name it. The
  /// rewind itself runs inside the network change.
  Future<void> _readRewindHeight() async {
    if (widget.networkId.isEmpty || widget.toNetwork != BitcoinNetwork.BITCOIN_NETWORK_ECASH) {
      return;
    }
    try {
      final plan = await GetIt.I.get<BitcoinConfProvider>().planECashSwitch(widget.networkId);
      if (plan.needsRollback && mounted) {
        setState(() => _rewindHeight = plan.rewindHeight);
      }
    } catch (e) {
      _log.w('NetworkSwapPage: could not plan the eCash switch: $e');
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
      child: SailScaffold(
        backgroundColor: theme.colors.background,
        appBar: SailAppBar.build(
          context,
          leading: SailAppBarBackButton(
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
                                SailSVG.fromAsset(SailSVGAsset.circleCheck, width: 32, color: theme.colors.success)
                              else if (_error != null)
                                SailSVG.fromAsset(SailSVGAsset.circleAlert, width: 32, color: theme.colors.error)
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
                                : 'BitWindow will swap bitcoind to $toName and reload its data — the app stays open.',
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
                                  name: _rewindHeight == null
                                      ? _step.name
                                      : 'Rewinding to block $_rewindHeight, then switching network',
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
