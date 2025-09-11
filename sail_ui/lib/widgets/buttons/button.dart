import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';
import 'dart:async';

enum ButtonVariant { primary, secondary, destructive, outline, ghost, link, icon }

class SailButton extends StatefulWidget {
  final String? label;
  final Future<void> Function()? onPressed;
  final ButtonVariant variant;
  final bool loading;
  final String? loadingLabel;
  final bool disabled;
  final SailSVGAsset? icon;
  final SailSVGAsset? endIcon;
  final EdgeInsets? padding;
  final double? iconHeight;
  final double? iconWidth;
  final bool small;
  final bool insideTable;
  final Color? textColor;
  final bool skipLoading;

  const SailButton({
    super.key,
    this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.loading = false,
    this.loadingLabel,
    this.disabled = false,
    this.icon,
    this.endIcon,
    this.iconHeight,
    this.iconWidth,
    this.padding,
    this.small = false,
    this.insideTable = false,
    this.textColor,
    this.skipLoading = false,
  }) : assert(
         variant != ButtonVariant.icon || (icon != null && label == null),
         'Icon must be set with no label for icon-variant',
       ),
       assert(
         (variant == ButtonVariant.icon || variant == ButtonVariant.destructive) || (label != null),
         'Label must be set',
       );

  @override
  State<SailButton> createState() => _SailButtonState();
}

class _SailButtonState extends State<SailButton> {
  bool _internalLoading = false;

  bool get _isLoading => (widget.loading || _internalLoading) && !widget.skipLoading;

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

    final style = _getVariantStyle(widget.variant, colors, widget.textColor);
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
        padding:
            widget.padding ??
            (widget.insideTable
                ? EdgeInsets.only(top: 4, bottom: 4, left: 6, right: 6)
                : (widget.variant == ButtonVariant.icon
                      ? widget.small
                            ? EdgeInsets.all(8)
                            : EdgeInsets.all(12)
                      : const EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 12))),
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
          SizedBox(width: 12, height: 12, child: LoadingIndicator.insideButton(foregroundColor)),
          const SizedBox(width: 8),
        ] else if (widget.icon != null || widget.endIcon != null) ...[
          if (widget.icon != null)
            SailSVG.fromAsset(
              widget.icon!,
              color: foregroundColor,
              height: widget.iconHeight,
              width: (widget.iconWidth ?? widget.iconHeight) == null ? 14 : widget.iconWidth,
            ),
          if (widget.icon != null && widget.label != null) const SizedBox(width: 8),
          if (widget.endIcon != null)
            SailSVG.fromAsset(
              widget.endIcon!,
              color: foregroundColor,
              height: widget.iconHeight,
              width: (widget.iconWidth ?? widget.iconHeight) == null ? 14 : widget.iconWidth,
            ),
          if (widget.endIcon != null && widget.label != null) const SizedBox(width: 8),
        ],
        if (widget.label != null)
          widget.small || widget.insideTable
              ? SailText.primary10(
                  _isLoading ? widget.loadingLabel ?? 'Please wait' : widget.label!,
                  color: foregroundColor,
                  bold: true,
                  decoration: variant == ButtonVariant.link ? TextDecoration.underline : null,
                )
              : SailText.primary12(
                  _isLoading ? widget.loadingLabel ?? 'Please wait' : widget.label!,
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

_ButtonVariantStyle _getVariantStyle(ButtonVariant variant, SailColor colors, Color? textColor) {
  switch (variant) {
    case ButtonVariant.primary:
      return _ButtonVariantStyle(
        backgroundColor: colors.primaryButtonBackground,
        foregroundColor: textColor ?? colors.primaryButtonText,
        hoverColor: colors.primaryButtonHover,
      );
    case ButtonVariant.secondary:
      return _ButtonVariantStyle(
        backgroundColor: colors.secondaryButtonBackground,
        foregroundColor: textColor ?? colors.secondaryButtonText,
        hoverColor: colors.secondaryButtonHover,
      );
    case ButtonVariant.destructive:
      return _ButtonVariantStyle(
        backgroundColor: colors.destructiveButtonBackground,
        foregroundColor: textColor ?? colors.destructiveButtonText,
        hoverColor: colors.destructiveButtonHover,
      );
    case ButtonVariant.outline:
      return _ButtonVariantStyle(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor ?? colors.outlineButtonText,
        borderColor: colors.outlineButtonBorder,
        hoverColor: colors.outlineButtonHover,
      );
    case ButtonVariant.ghost:
      return _ButtonVariantStyle(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor ?? colors.textSecondary,
        hoverColor: colors.ghostButtonHover,
      );
    case ButtonVariant.link:
      return _ButtonVariantStyle(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor ?? colors.linkButtonText,
        hoverColor: colors.linkButtonText,
      );
    case ButtonVariant.icon:
      return _ButtonVariantStyle(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor ?? colors.ghostButtonText,
        hoverColor: colors.ghostButtonHover,
      );
  }
}

class CopyButton extends StatefulWidget {
  final String text;

  const CopyButton({super.key, required this.text});

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _resetCopiedState() {
    setState(() {
      _copied = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailButton(
      variant: ButtonVariant.icon,
      icon: _copied ? SailSVGAsset.iconCheck : SailSVGAsset.iconCopy,
      textColor: _copied ? SailColorScheme.green : null,
      padding: EdgeInsets.all(9.5),
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: widget.text))
            .then((_) {
              if (mounted) {
                setState(() {
                  _copied = true;
                });
                // Reset after 2 seconds
                _resetTimer?.cancel();
                _resetTimer = Timer(const Duration(seconds: 2), _resetCopiedState);
              }
            })
            .catchError((error) {
              if (context.mounted) {
                showSnackBar(context, 'Could not copy ${widget.text}: $error');
              }
            });
      },
    );
  }
}

class PasteButton extends StatelessWidget {
  final void Function(String text) onPaste;

  const PasteButton({super.key, required this.onPaste});

  @override
  Widget build(BuildContext context) {
    return SailButton(
      variant: ButtonVariant.icon,
      icon: SailSVGAsset.clipboardPaste,
      padding: EdgeInsets.all(10.5),
      onPressed: () async {
        try {
          final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
          if (clipboardData?.text != null) {
            onPaste(clipboardData!.text!);
          }
        } catch (e) {
          if (!context.mounted) return;
          showSnackBar(context, 'Error accessing clipboard');
        }
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
    _controller = AnimationController(duration: const Duration(milliseconds: 50), vsync: this);
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

    return Opacity(
      opacity: widget.disabled ? 0.5 : 1.0,
      child: SelectionContainer.disabled(
        child: MouseRegion(
          cursor: (widget.disabled || widget.loading) ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.disabled ? null : widget.onPressed,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return MouseRegion(
                  onEnter: (_) => setState(() => widget.disabled ? _isHovered = _isHovered : _isHovered = true),
                  onExit: (_) => setState(() => widget.disabled ? _isHovered = _isHovered : _isHovered = false),
                  child: Stack(
                    children: [
                      // Bottom shadow layer
                      Container(
                        decoration: BoxDecoration(
                          color: widget.variant != ButtonVariant.link ? currentColor.darken(0.2) : Colors.transparent,
                          borderRadius: widget.variant != ButtonVariant.link ? SailStyleValues.borderRadius : null,
                        ),
                        margin: widget.variant != ButtonVariant.link ? const EdgeInsets.only(top: 3) : EdgeInsets.zero,
                        child: Opacity(opacity: 0, child: widget.child),
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
                  ),
                );
              },
            ),
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
