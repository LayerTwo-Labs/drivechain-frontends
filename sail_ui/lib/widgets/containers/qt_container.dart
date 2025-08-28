import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class QtContainer extends StatelessWidget {
  final Widget child;
  final bool tight;
  final Color? color;

  const QtContainer({super.key, required this.child, this.tight = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        border: Border.all(color: context.sailTheme.colors.text.withValues(alpha: 0.21)),
        color: color,
      ),
      child: child,
    );
  }
}
