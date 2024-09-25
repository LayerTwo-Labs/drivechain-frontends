import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class QtButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsets padding;
  final bool large;
  final bool important;
  final bool enabled;
  final bool loading;

  const QtButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: SailStyleValues.padding30,
      vertical: SailStyleValues.padding10,
    ),
    this.large = false,
    this.important = false,
    this.enabled = true,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: large ? 32 : 24,
      child: SailRawButton(
        disabled: !enabled,
        loading: loading,
        onPressed: enabled ? onPressed : null,
        padding: padding,
        child: child,
      ),
    );
  }
}
