import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class ErrorContainer extends StatefulWidget {
  final String error;
  final Function()? onRetry;
  final bool? loading;

  const ErrorContainer({super.key, required this.error, this.onRetry, this.loading});

  @override
  State<ErrorContainer> createState() => _ErrorContainerState();
}

class _ErrorContainerState extends State<ErrorContainer> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // The use of Align is to make sure the container doesn't expand for some weird reason(s)
    return Align(
      heightFactor: 1.0,
      alignment: Alignment.topLeft,
      child: QtContainer(
        child: SailColumn(
          mainAxisSize: MainAxisSize.min,
          spacing: SailStyleValues.padding04,
          children: [
            SailText.primary12(widget.error),
            if (widget.onRetry != null) ...{
              QtButton(
                onPressed: widget.onRetry,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 24.0,
                  ),
                  child: AnimatedBuilder(
                    animation: AnimationController(
                      duration: const Duration(milliseconds: 300),
                      vsync: this,
                    ),
                    builder: (context, child) {
                      return AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        firstChild: const CircularProgressIndicator.adaptive(strokeWidth: 2),
                        secondChild: SailText.primary12('Retry'),
                        crossFadeState: widget.loading == true ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                      );
                    },
                  ),
                ),
              ),
            },
          ],
        ),
      ),
    );
  }
}
