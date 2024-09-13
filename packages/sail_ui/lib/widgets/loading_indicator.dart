import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class LoadingIndicator extends StatelessWidget {
  final double strokeWidth;
  final Color? color;

  const LoadingIndicator({super.key, this.strokeWidth = 2, this.color});

  static Widget overlay() {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);

        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            fit: StackFit.loose,
            children: [
              Center(
                child: LoadingIndicator(color: theme.colors.text),
              ),
              const AbsorbPointer(),
            ],
          ),
        );
      },
    );
  }

  static Widget insideButton() {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return SizedBox(
          width: SailStyleValues.padding15,
          height: SailStyleValues.padding15,
          child: Stack(
            children: [
              Center(
                child: LoadingIndicator(color: theme.colors.background),
              ),
              const AbsorbPointer(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SailCircularProgressIndicator(
      strokeWidth: strokeWidth,
      color: color ?? SailTheme.of(context).colors.text,
    );
  }
}

class SailCircularProgressIndicator extends StatelessWidget {
  final double strokeWidth;
  final Color color;

  const SailCircularProgressIndicator({
    super.key,
    required this.color,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: color,
      strokeWidth: strokeWidth,
    );
  }
}
