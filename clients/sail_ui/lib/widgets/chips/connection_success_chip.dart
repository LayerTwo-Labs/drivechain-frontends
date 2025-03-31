import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/sail_ui.dart';

class ConnectionStatusChip extends StatelessWidget {
  final String chain;
  final int blockHeight;
  final Future<void> Function() onPressed;
  final bool initializing;

  final String? infoMessage;

  const ConnectionStatusChip({
    super.key,
    required this.chain,
    required this.blockHeight,
    required this.onPressed,
    required this.initializing,
    required this.infoMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: theme.colors.formFieldBorder, width: 0.5),
          left: BorderSide(color: theme.colors.formFieldBorder, width: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: SailStyleValues.padding04,
            horizontal: SailStyleValues.padding10,
          ),
          child: SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SailSVG.fromAsset(
                SailSVGAsset.iconGlobe,
                color: infoMessage != null
                    ? theme.colors.info
                    : initializing
                        ? theme.colors.orangeLight
                        : theme.colors.success,
              ),
              if (initializing) SailText.primary12('Initializing $chain'),
              if (initializing)
                InitializingDaemonSVG(
                  animate: initializing,
                ),
              if (!initializing)
                SailText.secondary12(infoMessage ?? '$chain | ${formatNumberWithSpace(blockHeight)} blocks'),
            ],
          ),
        ),
      ),
    );
  }
}

String formatNumberWithSpace(int number) {
  final format = NumberFormat('#,##0', 'en_US');
  return format.format(number).replaceAll(',', ' ');
}

class InitializingDaemonSVG extends StatefulWidget {
  final bool animate;

  const InitializingDaemonSVG({
    super.key,
    required this.animate,
  });

  @override
  State<InitializingDaemonSVG> createState() => _InitializingDaemonSVGState();
}

class _InitializingDaemonSVGState extends State<InitializingDaemonSVG> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Control the animation based on the 'animate' property
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(InitializingDaemonSVG oldWidget) {
    super.didUpdateWidget(oldWidget);
    // React to updates in the 'animate' property
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
      child: SailSVG.icon(SailSVGAsset.iconRestart),
    );
  }
}
