import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Restarts the L1 stack (bitcoind + enforcer) so config or datadir changes
/// take effect. Pushed after the user confirms a Bitcoin Core data directory
/// or clicks Apply on the conf editor.
class L1RestartPage extends StatefulWidget {
  final String reason;

  const L1RestartPage({super.key, required this.reason});

  @override
  State<L1RestartPage> createState() => _L1RestartPageState();
}

class _L1RestartPageState extends State<L1RestartPage> {
  Logger get _log => GetIt.I.get<Logger>();
  BinaryProvider get _binaries => GetIt.I.get<BinaryProvider>();

  final _step = _RestartStep('Restarting Bitcoin Core and Enforcer');
  bool _running = false;
  bool _done = false;
  String? _error;

  Future<void> _start() async {
    setState(() {
      _running = true;
      _error = null;
      _step.startTime = DateTime.now();
      _step.endTime = null;
    });

    try {
      // Stop dependent first so it doesn't fight the bitcoind teardown.
      await _binaries.stop(Enforcer());
      await _binaries.stop(BitcoinCore());

      // Brief settle so the OS finishes releasing the bitcoind RPC port
      // before the new process tries to bind.
      await Future.delayed(const Duration(seconds: 1));

      // start(BitcoinCore()) → orchestrator.startWithL1 → fire-and-forget.
      // Returns once boot is dispatched, which is enough to pop the page.
      await _binaries.start(BitcoinCore());

      if (!mounted) return;
      setState(() {
        _step.endTime = DateTime.now();
        _done = true;
      });
    } catch (e) {
      _log.e('L1RestartPage: restart failed: $e');
      if (!mounted) return;
      setState(() {
        _step.endTime = DateTime.now();
        _error = e.toString();
      });
    }
  }

  void _handleBack() {
    Navigator.of(context).pop(_done);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return PopScope(
      canPop: !_running || _done || _error != null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && (_done || _error != null)) {
          Navigator.of(context).pop(_done);
        }
      },
      child: Scaffold(
        backgroundColor: theme.colors.background,
        appBar: AppBar(
          backgroundColor: theme.colors.background,
          foregroundColor: theme.colors.text,
          leading: SailAppBarBackButton(
            onPressed: _running && !_done && _error == null ? null : _handleBack,
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
                              if (_done)
                                Icon(Icons.check_circle, color: theme.colors.success, size: 32)
                              else if (_error != null)
                                Icon(Icons.error, color: theme.colors.error, size: 32)
                              else
                                SailSVG.fromAsset(
                                  SailSVGAsset.iconRestart,
                                  color: theme.colors.primary,
                                  width: 32,
                                  height: 32,
                                ),
                              SailText.primary24(
                                _done
                                    ? 'Restart Complete'
                                    : _error != null
                                    ? 'Restart Failed'
                                    : 'Apply Changes',
                                bold: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SailText.secondary13(
                            _done
                                ? 'Bitcoin Core and Enforcer have been restarted.'
                                : _error != null
                                ? _error!
                                : _running
                                ? 'Stopping Enforcer and Bitcoin Core, then starting them on the new configuration...'
                                : widget.reason,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          if (_running || _done || _error != null)
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
                                  isActive: _running && !_step.isCompleted,
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
                  if (!_running) ...[
                    SailButton(
                      label: 'Cancel',
                      onPressed: () async => Navigator.of(context).pop(false),
                    ),
                    const SizedBox(width: SailStyleValues.padding12),
                    SailButton(
                      label: 'Restart Now',
                      variant: ButtonVariant.primary,
                      onPressed: () async => await _start(),
                    ),
                  ] else if (_done)
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

class _RestartStep {
  final String name;
  DateTime? startTime;
  DateTime? endTime;

  _RestartStep(this.name);

  bool get isCompleted => endTime != null;
  Duration? get duration => (startTime != null && endTime != null) ? endTime!.difference(startTime!) : null;
}
