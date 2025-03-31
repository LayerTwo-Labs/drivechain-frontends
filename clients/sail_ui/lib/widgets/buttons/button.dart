import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';

enum ButtonVariant {
  primary,
  secondary,
  destructive,
  outline,
  ghost,
  link,
  icon,
}

class SailButton extends StatefulWidget {
  final String? label;
  final Future<void> Function()? onPressed;
  final ButtonVariant variant;
  final bool loading;
  final bool disabled;
  final SailSVGAsset? icon;
  final EdgeInsets? padding;

  const SailButton({
    super.key,
    this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.loading = false,
    this.disabled = false,
    this.icon,
    this.padding,
  })  : assert(
          variant != ButtonVariant.icon || (icon != null && label == null),
          'Icon must be set with no label for icon-variant',
        ),
        assert(
          variant == ButtonVariant.icon || (label != null),
          'Label must be set',
        );

  @override
  State<SailButton> createState() => _SailButtonState();
}

class _SailButtonState extends State<SailButton> {
  bool _internalLoading = false;

  bool get _isLoading => widget.loading || _internalLoading;

  Future<void> _handlePress() async {
    if (widget.onPressed == null || _isLoading) return;

    try {
      setState(() => _internalLoading = true);
      await widget.onPressed!();
      if (mounted) {
        setState(() => _internalLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _internalLoading = false);
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final colors = theme.colors;

    final style = _getVariantStyle(widget.variant, colors);
    final content = _buildButtonContent(style.foregroundColor, widget.variant);

    return _SailScaleButton(
      onPressed: _handlePress,
      disabled: widget.disabled,
      loading: _isLoading,
      variant: widget.variant,
      color: style.backgroundColor,
      borderColor: style.borderColor,
      hoverColor: style.hoverColor,
      child: Padding(
        padding: widget.padding ??
            (widget.variant == ButtonVariant.icon
                ? EdgeInsets.all(12)
                : const EdgeInsets.only(
                    top: 8,
                    bottom: 8,
                    left: 12,
                    right: 12,
                  )),
        child: content,
      ),
    );
  }

  Widget _buildButtonContent(Color foregroundColor, ButtonVariant variant) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_isLoading) ...[
          SizedBox(
            width: 12,
            height: 12,
            child: LoadingIndicator.insideButton(foregroundColor),
          ),
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          SailSVG.fromAsset(
            widget.icon!,
            color: foregroundColor,
            width: 14,
          ),
          if (widget.label != null) const SizedBox(width: 8),
        ],
        if (widget.label != null)
          SailText.primary12(
            _isLoading ? 'Please wait' : widget.label!,
            color: foregroundColor,
            bold: true,
            decoration: variant == ButtonVariant.link ? TextDecoration.underline : null,
          ),
      ],
    );
  }
}

class _ButtonVariantStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final Color? hoverColor;

  const _ButtonVariantStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    this.hoverColor,
  });
}

_ButtonVariantStyle _getVariantStyle(ButtonVariant variant, SailColor colors) {
  switch (variant) {
    case ButtonVariant.primary:
      return _ButtonVariantStyle(
        backgroundColor: colors.primaryButtonBackground,
        foregroundColor: colors.primaryButtonText,
        hoverColor: colors.primaryButtonHover,
      );
    case ButtonVariant.secondary:
      return _ButtonVariantStyle(
        backgroundColor: colors.secondaryButtonBackground,
        foregroundColor: colors.secondaryButtonText,
        hoverColor: colors.secondaryButtonHover,
      );
    case ButtonVariant.destructive:
      return _ButtonVariantStyle(
        backgroundColor: colors.destructiveButtonBackground,
        foregroundColor: colors.destructiveButtonText,
        hoverColor: colors.destructiveButtonHover,
      );
    case ButtonVariant.outline:
      return _ButtonVariantStyle(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.outlineButtonText,
        borderColor: colors.outlineButtonBorder,
        hoverColor: colors.outlineButtonHover,
      );
    case ButtonVariant.ghost:
      return _ButtonVariantStyle(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.ghostButtonText,
        hoverColor: colors.ghostButtonHover,
      );
    case ButtonVariant.link:
      return _ButtonVariantStyle(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.linkButtonText,
        hoverColor: colors.linkButtonText,
      );
    case ButtonVariant.icon:
      return _ButtonVariantStyle(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.ghostButtonText,
        hoverColor: colors.ghostButtonHover,
      );
  }
}

class CopyButton extends StatelessWidget {
  final String text;

  const CopyButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SailButton(
      label: 'Copy',
      variant: ButtonVariant.secondary,
      icon: SailSVGAsset.iconCopy,
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: text)).then((_) {
          if (context.mounted) showSnackBar(context, 'Copied $text');
        }).catchError((error) {
          if (context.mounted) showSnackBar(context, 'Could not copy $text: $error');
        });
      },
    );
  }
}

class _SailScaleButton extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final bool disabled;
  final bool loading;
  final ButtonVariant variant;
  final Color color;
  final Color? borderColor;
  final Color? hoverColor;
  final Widget child;

  const _SailScaleButton({
    required this.onPressed,
    required this.disabled,
    required this.loading,
    required this.variant,
    required this.color,
    required this.child,
    this.hoverColor,
    this.borderColor,
  });

  @override
  State<_SailScaleButton> createState() => __SailScaleButtonState();
}

class __SailScaleButtonState extends State<_SailScaleButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isHovered = false;
  bool _isPressed = false; // Track the pressed state

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.disabled && !widget.loading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.disabled && !widget.loading) {
      setState(() => _isPressed = false);
      // Only reverse if forward animation is complete
      if (!_controller.isAnimating) {
        _controller.reverse();
      } else {
        _controller.addStatusListener(_handleAnimationComplete);
      }
    }
  }

  void _handleTapCancel() {
    if (!widget.disabled && !widget.loading) {
      setState(() => _isPressed = false);
      // Only reverse if forward animation is complete
      if (!_controller.isAnimating) {
        _controller.reverse();
      } else {
        _controller.addStatusListener(_handleAnimationComplete);
      }
    }
  }

  void _handleAnimationComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_isPressed) {
      _controller.reverse();
    }
    _controller.removeStatusListener(_handleAnimationComplete);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the current color based on state
    Color currentColor = widget.color;
    if (_isHovered && widget.hoverColor != null) {
      currentColor = widget.hoverColor!;
    }

    return SelectionContainer.disabled(
      child: MouseRegion(
        cursor: (widget.disabled || widget.loading) ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.onPressed,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  // Bottom shadow layer
                  Container(
                    decoration: BoxDecoration(
                      color: widget.variant != ButtonVariant.link ? currentColor.darken(0.2) : Colors.transparent,
                      borderRadius: widget.variant != ButtonVariant.link ? SailStyleValues.borderRadius : null,
                    ),
                    margin: widget.variant != ButtonVariant.link ? const EdgeInsets.only(top: 3) : EdgeInsets.zero,
                    child: Opacity(
                      opacity: 0,
                      child: widget.child,
                    ),
                  ),
                  // Top button layer
                  Container(
                    transform: Matrix4.translationValues(
                      0,
                      widget.variant != ButtonVariant.link ? _controller.value * 1.5 : 0.0,
                      0,
                    ),
                    decoration: BoxDecoration(
                      color: widget.variant != ButtonVariant.link ? currentColor : Colors.transparent,
                      borderRadius: widget.variant != ButtonVariant.link ? SailStyleValues.borderRadius : null,
                    ),
                    child: widget.child,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

extension ColorExtension on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}
