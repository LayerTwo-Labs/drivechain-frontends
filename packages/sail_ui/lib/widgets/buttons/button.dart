import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';

enum ButtonSize { small, regular, large }

class SailButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool disabled;
  final bool loading;
  final ButtonSize size;
  final bool isSecondary;
  final Widget child;

  const SailButton._({
    required this.onPressed,
    required this.disabled,
    required this.loading,
    required this.size,
    required this.isSecondary,
    required this.child,
  });

  static Widget primary(
    String label, {
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
      isSecondary: false,
      child: size == ButtonSize.small || size == ButtonSize.regular
          ? SailText.background12(label, bold: true)
          : SailText.background13(label),
    );
  }

  static Widget secondary(
    String label, {
    required VoidCallback onPressed,
    required ButtonSize size,
    bool loading = false,
    bool disabled = false,
  }) {
    return SailButton._(
      onPressed: onPressed,
      disabled: disabled,
      loading: loading,
      isSecondary: true,
      size: size,
      child: size == ButtonSize.small || size == ButtonSize.regular
          ? SailText.primary12(label, bold: true)
          : SailText.primary13(label),
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
      isSecondary: false,
      child: SailRow(
        spacing: SailStyleValues.padding08,
        children: [
          icon,
          size == ButtonSize.small || size == ButtonSize.regular
              ? SailText.primary12(label, bold: true)
              : SailText.primary13(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final colors = theme.colors;
    final backgroundColor = isSecondary ? colors.chip : colors.primary;
    final divideFactor = theme.dense ? 2 : 1;

    switch (size) {
      case ButtonSize.small:
        return SailRawButton(
          disabled: disabled,
          backgroundColor: backgroundColor,
          onPressed: onPressed,
          loading: loading,
          padding: EdgeInsets.symmetric(
            vertical: SailStyleValues.padding05 / divideFactor,
            horizontal: SailStyleValues.padding10 / divideFactor,
          ),
          child: child,
        );

      case ButtonSize.regular:
        return SailRawButton(
          disabled: disabled,
          backgroundColor: backgroundColor,
          onPressed: onPressed,
          loading: loading,
          padding: EdgeInsets.symmetric(
            vertical: SailStyleValues.padding08 / divideFactor,
            horizontal: SailStyleValues.padding20 / divideFactor,
          ),
          child: child,
        );

      case ButtonSize.large:
        return SailRawButton(
          disabled: disabled,
          backgroundColor: backgroundColor,
          onPressed: onPressed,
          loading: loading,
          padding: EdgeInsets.symmetric(
            vertical: SailStyleValues.padding15 / divideFactor,
            horizontal: SailStyleValues.padding15 / divideFactor,
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
      child: SailText.secondary12(label, bold: true),
    );
  }
}

class SailRawButton extends StatefulWidget {
  final bool disabled;
  final bool loading;
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsets? padding;

  const SailRawButton({
    super.key,
    required this.disabled,
    required this.loading,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.padding,
  });

  @override
  State<SailRawButton> createState() => _SailRawButtonState();
}

class _SailRawButtonState extends State<SailRawButton> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final disabled = widget.loading || widget.disabled || widget.onPressed == null;
    final backgroundColor = widget.backgroundColor ?? theme.colors.backgroundSecondary;

    Color textColor;
    if (!disabled && widget.onPressed != null) {
      textColor = SailTheme.of(context).colors.textTertiary;
    } else {
      textColor = SailTheme.of(context).colors.text;
    }

    return MaterialButton(
      visualDensity: theme.dense ? VisualDensity.compact : null,
      onPressed: disabled ? null : widget.onPressed,
      disabledColor: backgroundColor,
      color: backgroundColor,
      enableFeedback: !widget.disabled,
      textColor: textColor,
      splashColor: theme.colors.primary,
      hoverColor: theme.colors.primary,
      padding: widget.padding,
      elevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      minWidth: theme.dense ? 24 : 32,
      shape: RoundedRectangleBorder(
        borderRadius: SailStyleValues.borderRadiusButton,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: widget.loading ? 0 : 1, child: widget.child),
          if (widget.loading) LoadingIndicator.insideButton(),
        ],
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
    super.key,
    required this.onPressed,
    required this.child,
    this.disabled = false,
    this.loading = false,
    this.color,
  });

  @override
  State<SailScaleButton> createState() => _SailScaleButtonState();
}

class _SailScaleButtonState extends State<SailScaleButton> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController = AnimationController(
    vsync: this,
    lowerBound: 0.995,
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
