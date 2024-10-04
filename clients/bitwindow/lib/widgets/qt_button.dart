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
      horizontal: SailStyleValues.padding30,
      vertical: SailStyleValues.padding10,
    ),
    this.large = false,
    this.important = false,
    this.disabled = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: large ? 32 : 24,
      child: SailRawButton(
        backgroundColor: context.sailTheme.colors.backgroundSecondary,
        disabled: disabled,
        loading: loading,
        onPressed: onPressed,
        padding: padding,
        child: child,
      ),
    );
  }
}
