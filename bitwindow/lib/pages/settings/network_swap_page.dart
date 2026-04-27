import 'package:bitwindow/main.dart' show bootBitwindowBackend;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Confirms a Bitcoin network change, then runs the swap as
/// "shut down → save → boot back up", mirroring the reset flow.
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
  BitcoinConfProvider get _conf => GetIt.I.get<BitcoinConfProvider>();
  BinaryProvider get _binaries => GetIt.I.get<BinaryProvider>();

  final List<_SwapStep> _steps = [
    _SwapStep('Stopping binaries'),
    _SwapStep('Saving network configuration'),
    _SwapStep('Starting binaries'),
  ];

  bool _isSwapping = false;
  bool _swapComplete = false;
  int _currentStepIndex = -1;
  String? _error;

  Future<void> _startSwap() async {
    setState(() {
      _isSwapping = true;
      _error = null;
    });

    try {
      await _runStep(0, () async {
        await _binaries.stop(BitWindow());
        await Future.delayed(const Duration(seconds: 2));
      });
      await _runStep(1, () => _conf.updateNetwork(widget.toNetwork));
      await _runStep(2, () => bootBitwindowBackend(_log));

      if (mounted) {
        setState(() => _swapComplete = true);
      }
    } catch (e) {
      _log.e('NetworkSwapPage: swap failed: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          if (_currentStepIndex >= 0 && _currentStepIndex < _steps.length) {
            _steps[_currentStepIndex].endTime = DateTime.now();
          }
        });
      }
    }
  }

  Future<void> _runStep(int idx, Future<void> Function() action) async {
    if (!mounted) return;
    setState(() {
      _currentStepIndex = idx;
      _steps[idx].startTime = DateTime.now();
    });
    await action();
    if (!mounted) return;
    setState(() {
      _steps[idx].endTime = DateTime.now();
    });
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
                                : 'BitWindow will stop, save the new network, and boot back up. Switching from $fromName to $toName.',
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var i = 0; i < _steps.length; i++)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: ProgressStepTile(
                                          name: _steps[i].name,
                                          isCompleted: _steps[i].isCompleted,
                                          duration: _steps[i].duration,
                                          isActive: i == _currentStepIndex && !_steps[i].isCompleted,
                                        ),
                                      ),
                                  ],
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
