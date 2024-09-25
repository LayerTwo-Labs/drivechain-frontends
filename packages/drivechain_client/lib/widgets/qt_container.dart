import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class QtContainer extends StatelessWidget {
  final Widget child;
  final bool tight;

  const QtContainer({
    super.key,
    required this.child,
    this.tight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: tight ? const EdgeInsets.all(0) : const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: context.sailTheme.colors.divider),
      ),
      child: child,
    );
  }
}