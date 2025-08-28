import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class ShuttingDownPage extends StatefulWidget {
  final List<Binary> binaries;
  final VoidCallback onComplete;

  const ShuttingDownPage({super.key, required this.binaries, required this.onComplete});

  @override
  State<ShuttingDownPage> createState() => _ShuttingDownPageState();
}

class _ShuttingDownPageState extends State<ShuttingDownPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  String _currentMessage = '';

  @override
  void initState() {
    super.initState();

    final totalSteps = widget.binaries.length + 1;
    final duration = Duration(seconds: totalSteps);

    _controller = AnimationController(duration: duration, vsync: this);

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.addListener(_updateMessage);

    if (widget.binaries.isEmpty) {
      setState(() {
        _currentMessage = 'Until we meet again';
      });
    }

    // Start the animation for normal case
    _controller.forward().then((_) {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  void _updateMessage() {
    final totalSteps = widget.binaries.length + 1;
    final step = (_controller.value * totalSteps).floor();
    setState(() {
      if (step < widget.binaries.length) {
        _currentMessage = 'Shutting down ${widget.binaries[step].name}...';
      } else {
        _currentMessage = 'Until we meet again';
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return QtPage(
      child: Stack(
        children: [
          // Centered logo
          Center(child: SailSVG.fromAsset(SailSVGAsset.layerTwoLabsLogo, height: 71)),

          // Progress and text overlay
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: SailColumn(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SailText.primary10(_currentMessage, color: theme.colors.inactiveNavText),
                  SizedBox(
                    width: 200,
                    child: ProgressBar(
                      current: _progressAnimation.value,
                      goal: 1,
                      hideProgressInside: true,
                      small: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
