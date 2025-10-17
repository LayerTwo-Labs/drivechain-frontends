import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class ShutDownPage extends StatefulWidget {
  final List<Binary> binaries;
  final Stream<ShutdownProgress> shutdownStream;
  final VoidCallback onComplete;

  const ShutDownPage({
    super.key,
    required this.binaries,
    required this.shutdownStream,
    required this.onComplete,
  });

  @override
  State<ShutDownPage> createState() => _ShutDownPageState();
}

class _ShutDownPageState extends State<ShutDownPage> {
  double _progress = 0.0;
  String _currentMessage = '';
  StreamSubscription<ShutdownProgress>? _streamSubscription;
  Timer? _slowShutdownTimer;
  bool _isSlowShutdown = false;

  @override
  void initState() {
    super.initState();

    if (widget.binaries.isEmpty) {
      _currentMessage = 'Until we meet again';
      _progress = 1.0;
      Future.microtask(() => widget.onComplete());
      return;
    }

    _currentMessage = 'Starting shutdown...';

    // Start timer to detect slow shutdown after 3 seconds
    _slowShutdownTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || _progress >= 1.0) return;
      setState(() {
        _isSlowShutdown = true;
      });
    });

    _streamSubscription = widget.shutdownStream.listen(
      (progress) {
        if (!mounted) return;

        setState(() {
          _progress = progress.completedCount / progress.totalCount;
          if (progress.currentBinary != null) {
            if (_isSlowShutdown) {
              _currentMessage = 'Shutting down ${progress.currentBinary} is taking longer than usual. Hang tight...';
            } else {
              _currentMessage = 'Shutting down ${progress.currentBinary}...';
            }
          } else if (progress.completedCount == progress.totalCount) {
            _currentMessage = 'Until we meet again';
            _slowShutdownTimer?.cancel();
          }
        });
      },
      onDone: () {
        if (!mounted) return;
        _slowShutdownTimer?.cancel();
        setState(() {
          _progress = 1.0;
          _currentMessage = 'Until we meet again';
        });
        widget.onComplete();
      },
      onError: (error) {
        if (!mounted) return;
        _slowShutdownTimer?.cancel();
        setState(() {
          _currentMessage = 'Error during shutdown: $error';
        });
      },
    );
  }

  @override
  void dispose() {
    _slowShutdownTimer?.cancel();
    _streamSubscription?.cancel();
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
                      current: _progress,
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
