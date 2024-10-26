import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';

enum ButtonSize { small, regular }

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
            vertical: SailStyleValues.padding04 / divideFactor,
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

    return SailScaleButton(
      onPressed: onPressed,
      child: InkWell(
        borderRadius: SailStyleValues.borderRadiusButton,
        onTap: onPressed,
        highlightColor: Colors.transparent,
        focusColor: theme.colors.backgroundActionModal.withOpacity(0.1),
        hoverColor: theme.colors.backgroundActionModal.withOpacity(0.1),
        splashColor: Colors.transparent,
        child: SailText.secondary12(label, bold: true),
      ),
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
    final backgroundColor = widget.backgroundColor ?? theme.colors.background;

    // TODO: Actually use this
    Color textColor;
    if (!disabled && widget.onPressed != null) {
      textColor = SailTheme.of(context).colors.textTertiary;
    } else {
      textColor = SailTheme.of(context).colors.text;
    }

    return MaterialButton(
      mouseCursor: disabled ? SystemMouseCursors.forbidden : WidgetStateMouseCursor.clickable,
      visualDensity: theme.dense ? VisualDensity.compact : null,
      onPressed: disabled ? null : widget.onPressed,
      disabledColor: backgroundColor,
      color: backgroundColor,
      enableFeedback: !widget.disabled,
      textColor: textColor,
      splashColor: theme.colors.primary,
      hoverColor: HSLColor.fromColor(backgroundColor)
          .withLightness((HSLColor.fromColor(backgroundColor).lightness - 0.1).clamp(0.0, 1.0))
          .toColor(),
      padding: widget.padding,
      elevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      minWidth: theme.dense ? 24 : 32,
      shape: RoundedRectangleBorder(
        borderRadius: SailStyleValues.borderRadiusButton,
        side: BorderSide(
          color: context.sailTheme.colors.formFieldBorder,
          width: 0.5,
        ),
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

enum SailButtonStyle { primary, secondary }

class SailScaleButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool pressed;
  final Widget child;
  final SailButtonStyle style;

  final bool disabled;
  final bool loading;
  final Color? color;
  final Color? borderColor;

  const SailScaleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style = SailButtonStyle.primary,
    this.pressed = false,
    this.disabled = false,
    this.loading = false,
    this.borderColor,
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
    duration: const Duration(milliseconds: 100),
  );

  bool _readyForFling = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _updatePressedState();
  }

  @override
  void didUpdateWidget(SailScaleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pressed != widget.pressed) {
      _updatePressedState();
    }
  }

  void _updatePressedState() {
    setState(() {
      _isPressed = widget.pressed;
    });
  }

  Future<void> reset() async {
    _readyForFling = false;
  }

  Future<void> fling() async {
    if (!mounted || widget.disabled) return;
    await _scaleController.fling();
  }

  bool get disabled => widget.disabled || widget.loading;

  void shrink() {
    if (widget.disabled) {
      return;
    }
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final backgroundColor =
        widget.style == SailButtonStyle.secondary ? theme.colors.backgroundSecondary : theme.colors.text;

    Widget buttonContent = Listener(
      onPointerDown: (_) async {
        if (disabled) {
          return;
        }

        setState(() {
          if (widget.pressed) {
            _isPressed = false;
          } else {
            _isPressed = true;
          }
        });
        await reset();
        shrink();
        await Future.delayed(const Duration(milliseconds: 100));
        _readyForFling = true;
      },
      onPointerUp: (_) async {
        if (disabled) {
          return;
        }

        setState(() {
          if (widget.pressed) {
            _isPressed = true;
          } else {
            _isPressed = false;
          }
        });
        if (!_readyForFling) {
          await Future.delayed(const Duration(milliseconds: 40));
        }
        await fling();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () async {
          if (disabled) {
            return;
          }

          shrink();
          await HapticFeedback.lightImpact();
          await fling();

          widget.onPressed!();
        },
        child: InkWell(
          mouseCursor: disabled ? SystemMouseCursors.forbidden : WidgetStateMouseCursor.clickable,
          borderRadius: SailStyleValues.borderRadiusButton,
          onTap: () {
            if (disabled) {
              return;
            }

            widget.onPressed!();
          },
          child: AnimatedBuilder(
            animation: _scaleController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleController.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(opacity: widget.loading ? 0.3 : 1, child: widget.child),
                    if (widget.loading) Center(child: LoadingIndicator.insideButton()),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    if (widget.onPressed != null) {
      return Container(
        padding: const EdgeInsets.only(bottom: 3, right: 3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: SailTheme.of(context).colors.textTertiary.withOpacity(0.5),
                offset: const Offset(1.5, 1.5),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            padding: EdgeInsets.only(
              top: _isPressed ? 1.5 : 0,
              left: _isPressed ? 1.5 : 0,
              bottom: _isPressed ? 0 : 1.5,
              right: _isPressed ? 0 : 1.5,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: widget.color ?? backgroundColor,
                border: Border.all(
                  color: widget.borderColor ?? Colors.transparent,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: buttonContent,
              ),
            ),
          ),
        ),
      );
    }

    return buttonContent;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }
}

class RightSideShadowPainter extends CustomPainter {
  final Color shadowColor;
  final double shadowWidth;

  RightSideShadowPainter({required this.shadowColor, required this.shadowWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.transparent, shadowColor],
        stops: [0.7, 1.0],
      ).createShader(Rect.fromLTRB(size.width - shadowWidth, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTRB(size.width - shadowWidth, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
