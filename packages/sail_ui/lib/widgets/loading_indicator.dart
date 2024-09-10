import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';

class LoadingIndicator extends StatelessWidget {
  final double strokeWidth;

  const LoadingIndicator({super.key, this.strokeWidth = 2});

  static Widget overlay() {
    return Builder(
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: const Stack(
            fit: StackFit.loose,
            children: [
              Center(
                child: LoadingIndicator(),
              ),
              AbsorbPointer(),
            ],
          ),
        );
      },
    );
  }

  static Widget insideButton() {
    return Builder(
      builder: (context) {
        return const SizedBox(
          width: SailStyleValues.padding15,
          height: SailStyleValues.padding15,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: LoadingIndicator(),
              ),
              AbsorbPointer(),
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
    );
  }
}

class SailCircularProgressIndicator extends StatelessWidget {
  final double strokeWidth;

  const SailCircularProgressIndicator({super.key, this.strokeWidth = 2});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: SailTheme.of(context).colors.text,
      strokeWidth: strokeWidth,
    );
  }
}
