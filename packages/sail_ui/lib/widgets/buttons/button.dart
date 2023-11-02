import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sail_ui/widgets/loading_indicator.dart';

enum ButtonSize { small, regular, large }

class SailButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool disabled;
  final bool loading;
  final ButtonSize size;
  final Widget child;

  const SailButton._({
    required this.onPressed,
    required this.disabled,
    required this.loading,
    required this.size,
    required this.child,
  });

  static Widget primary({
    required String label,
    required VoidCallback onPressed,
    required ButtonSize size,
    bool loading = false,
    bool disabled = false,
  }) {
    return SailButton._(
      onPressed: onPressed,
      disabled: disabled,
      loading: loading,
      size: size,
      child: size == ButtonSize.small || size == ButtonSize.regular
          ? SailText.mediumPrimary12(label)
          : SailText.primary14(label),
    );
  }

  static Widget icon({
    required String label,
    required Widget icon,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.regular,
    bool loading = false,
    bool disabled = false,
  }) {
    return SailButton._(
      onPressed: onPressed,
      disabled: disabled,
      loading: loading,
      size: size,
      child: SailRow(
        spacing: SailStyleValues.padding8,
        children: [
          icon,
          size == ButtonSize.small || size == ButtonSize.regular
              ? SailText.mediumPrimary12(label)
              : SailText.primary14(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;

    switch (size) {
      case ButtonSize.small:
        return SailRawButton(
          disabled: disabled,
          disabledColor: colors.disabledPrimaryButton,
          backgroundColor: colors.orange,
          onPressed: onPressed,
          loading: loading,
          padding: const EdgeInsets.symmetric(
            vertical: SailStyleValues.padding5,
            horizontal: SailStyleValues.padding10,
          ),
          child: child,
        );

      case ButtonSize.regular:
        return SailRawButton(
          disabled: disabled,
          disabledColor: colors.disabledPrimaryButton,
          backgroundColor: colors.orange,
          onPressed: onPressed,
          loading: loading,
          padding: const EdgeInsets.symmetric(
            vertical: SailStyleValues.padding8,
            horizontal: SailStyleValues.padding15,
          ),
          child: child,
        );

      case ButtonSize.large:
        return SailRawButton(
          disabled: disabled,
          disabledColor: colors.disabledPrimaryButton,
          backgroundColor: colors.orange,
          onPressed: onPressed,
          loading: loading,
          padding: const EdgeInsets.symmetric(
            vertical: SailStyleValues.padding15,
            horizontal: SailStyleValues.padding15,
          ),
          child: child,
        );
    }
  }
}

class SailTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const SailTextButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return InkWell(
      borderRadius: SailStyleValues.borderRadiusButton,
      onTap: onPressed,
      highlightColor: Colors.transparent,
      focusColor: theme.colors.backgroundActionModal.withOpacity(0.1),
      hoverColor: theme.colors.backgroundActionModal.withOpacity(0.1),
      splashColor: Colors.transparent,
      child: SailText.mediumSecondary12(label),
    );
  }
}

class SailRawButton extends StatefulWidget {
  final bool disabled;
  final bool loading;
  final Color disabledColor;
  final Color backgroundColor;
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsets? padding;

  const SailRawButton({
    Key? key,
    required this.disabled,
    required this.loading,
    required this.disabledColor,
    required this.backgroundColor,
    required this.onPressed,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  State<SailRawButton> createState() => _SailRawButtonState();
}

class _SailRawButtonState extends State<SailRawButton> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final disabled = widget.disabled || widget.onPressed == null;

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: SailScaleButton(
        onPressed: widget.onPressed,
        disabled: disabled,
        child: MaterialButton(
          color: widget.backgroundColor,
          disabledColor: widget.backgroundColor,
          enableFeedback: !widget.disabled,
          textColor: theme.colors.text,
          splashColor: Colors.transparent,
          hoverColor: widget.backgroundColor.withOpacity(0.9),
          padding: widget.padding,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: SailStyleValues.borderRadiusButton,
          ),
          onPressed: widget.disabled ? null : widget.onPressed,
          child: Stack(
            children: [
              Opacity(opacity: widget.loading ? 0 : 1, child: widget.child),
              if (widget.loading) LoadingIndicator.insideButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class SailScaleButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool disabled;
  final bool loading;
  final Color? color;

  const SailScaleButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.disabled = false,
    this.loading = false,
    this.color,
  }) : super(key: key);

  @override
  State<SailScaleButton> createState() => _SailScaleButtonState();
}

class _SailScaleButtonState extends State<SailScaleButton> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController = AnimationController(
    vsync: this,
    lowerBound: 0.98,
    upperBound: 1.0,
    value: 1,
    duration: const Duration(milliseconds: 20),
  );

  bool _readyForFling = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> reset() async {
    _readyForFling = false;
  }

  Future<void> fling() async {
    if (!mounted || widget.disabled) return;
    await _scaleController.fling();
  }

  void shrink() {
    if (widget.disabled) {
      return;
    }
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: widget.onPressed == null
          ? null
          : (_) async {
              await reset();
              shrink();

              await Future.delayed(const Duration(milliseconds: 100));
              _readyForFling = true;
            },
      onPointerUp: widget.onPressed == null
          ? null
          : (_) async {
              if (!_readyForFling) {
                await Future.delayed(const Duration(milliseconds: 40));
              }

              await fling();
            },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onPressed == null
            ? null
            : () async {
                shrink();
                await HapticFeedback.lightImpact();
                await fling();
                if (widget.disabled) {
                  return;
                }
                if (widget.onPressed != null) {
                  widget.onPressed!();
                }
              },
        child: InkWell(
          borderRadius: widget.onPressed == null ? null : SailStyleValues.borderRadiusButton,
          onTap: widget.onPressed == null
              ? null
              : () {
                  if (widget.disabled) {
                    return;
                  }
                  widget.onPressed!();
                },
          child: AnimatedBuilder(
            animation: _scaleController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleController.value,
                child: widget.loading ? LoadingIndicator.insideButton() : widget.child,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }
}
