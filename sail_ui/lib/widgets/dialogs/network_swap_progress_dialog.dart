import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class NetworkSwapStep {
  String name;
  DateTime startTime;
  DateTime? endTime;

  NetworkSwapStep({
    required this.name,
    required this.startTime,
  });

  bool get isCompleted => endTime != null;
  Duration? get duration => endTime?.difference(startTime);
}

class NetworkSwapProgressDialog extends StatefulWidget {
  final BitcoinNetwork fromNetwork;
  final BitcoinNetwork toNetwork;
  final Future<void> Function(void Function(String) updateStatus) swapFunction;

  const NetworkSwapProgressDialog({
    super.key,
    required this.fromNetwork,
    required this.toNetwork,
    required this.swapFunction,
  });

  @override
  State<NetworkSwapProgressDialog> createState() => _NetworkSwapProgressDialogState();
}

class _NetworkSwapProgressDialogState extends State<NetworkSwapProgressDialog> {
  final List<NetworkSwapStep> _steps = [];
  bool get _isCompleted => _steps.isNotEmpty && _steps.every((step) => step.isCompleted);
  String? _error;
  int _currentStepIndex = -1;

  @override
  void initState() {
    super.initState();
    _initializeAllSteps();
    _startSwap();
  }

  void _initializeAllSteps() {
    final stepNames = [
      'Stopping Bitcoin Core',
      'Stopping Enforcer',
      'Stopping BitWindow',
      'Waiting for processes to exit',
      'Starting Core, Enforcer and BitWindow',
      'Network swap complete',
    ];

    setState(() {
      _steps.addAll(
        stepNames.map(
          (name) => NetworkSwapStep(
            name: name,
            startTime: DateTime.now(),
          ),
        ),
      );
    });
  }

  void _startSwap() async {
    try {
      await widget.swapFunction((status) {
        setState(() {
          // Complete current step
          if (_currentStepIndex >= 0 && _currentStepIndex < _steps.length) {
            _steps[_currentStepIndex].endTime = DateTime.now();
          }

          // Move to next step
          _currentStepIndex++;

          if (_currentStepIndex < _steps.length) {
            _steps[_currentStepIndex].startTime = DateTime.now();
          }
        });
      });

      // Complete the FINAL step (the one that's currently active)
      setState(() {
        if (_currentStepIndex >= 0 && _currentStepIndex < _steps.length) {
          _steps[_currentStepIndex].endTime = DateTime.now();
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fromNetworkName = widget.fromNetwork.toDisplayName();
    final toNetworkName = widget.toNetwork.toDisplayName();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 650),
        child: SailCard(
          title: 'Switching Network',
          subtitle: _isCompleted
              ? 'Successfully switched from $fromNetworkName to $toNetworkName!'
              : _error != null
              ? 'Network swap failed: $_error'
              : 'Switching from $fromNetworkName to $toNetworkName...',
          withCloseButton: true,
          child: SingleChildScrollView(
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ..._steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isActive = index == _currentStepIndex && !step.isCompleted;
                  return _StepTile(step: step, isActive: isActive);
                }),
                if (_isCompleted) const SailSpacing(SailStyleValues.padding08),
                if (_isCompleted)
                  SailButton(
                    label: 'Close',
                    variant: ButtonVariant.primary,
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                if (_error != null) const SailSpacing(SailStyleValues.padding08),
                if (_error != null)
                  SailButton(
                    label: 'Close',
                    variant: ButtonVariant.secondary,
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final NetworkSwapStep step;
  final bool isActive;

  const _StepTile({required this.step, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    Widget iconWidget;
    String timeText = '';

    if (step.isCompleted) {
      iconWidget = SailSVG.fromAsset(SailSVGAsset.circleCheck, color: SailColorScheme.green, width: 16, height: 16);
      if (step.duration != null) {
        final duration = step.duration!;
        if (duration.inSeconds > 0) {
          timeText = '${duration.inSeconds}.${(duration.inMilliseconds % 1000).toString().padLeft(3, '0')}s';
        } else {
          timeText = '${duration.inMilliseconds}ms';
        }
      }
    } else if (isActive) {
      iconWidget = SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 1,
          valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primary),
        ),
      );
    } else {
      iconWidget = SailSVG.fromAsset(SailSVGAsset.circle, color: theme.colors.textSecondary, width: 16, height: 16);
    }

    return SailRow(
      spacing: SailStyleValues.padding04,
      children: [
        SizedBox(width: 16, child: iconWidget),
        Expanded(
          child: SailText.primary13(
            step.name,
            color: isActive
                ? theme.colors.primary
                : step.isCompleted
                ? SailColorScheme.green
                : theme.colors.textSecondary,
          ),
        ),
        if (timeText.isNotEmpty)
          SailText.secondary12(
            timeText,
            color: SailColorScheme.green,
          ),
      ],
    );
  }
}
