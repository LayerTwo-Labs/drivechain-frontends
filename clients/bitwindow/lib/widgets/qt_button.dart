import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class QtButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsets padding;
  final bool large;
  final bool important;
  final bool disabled;
  final bool loading;

  const QtButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: SailStyleValues.padding15,
      vertical: 0,
    ),
    this.large = false,
    this.important = false,
    this.disabled = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: SailScaleButton(
        color: context.sailTheme.colors.backgroundSecondary,
        disabled: disabled,
        loading: loading,
        onPressed: onPressed,
        child: Padding(
          padding: padding,
          child: Center(child: child),
        ),
      ),
    );
  }
}
