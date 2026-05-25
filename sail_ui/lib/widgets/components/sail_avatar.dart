import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class SailAvatar extends StatelessWidget {
  final ImageProvider? image;
  final String? initials;
  final Widget? fallback;
  final double size;
  final Color? backgroundColor;

  const SailAvatar({
    super.key,
    this.image,
    this.initials,
    this.fallback,
    this.size = 40,
    this.backgroundColor,
  });

  String? _initialsFromName(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final parts = name.trim().split(RegExp(r'\s+'));
    final letters = parts.take(2).map((p) => p.isEmpty ? '' : p[0].toUpperCase()).join();
    return letters.isEmpty ? null : letters;
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final bg = backgroundColor ?? theme.colors.avatarBackground;
    final initialsText = _initialsFromName(initials);

    Widget content;
    if (image != null) {
      content = Image(
        image: image!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => _renderFallback(theme, bg, initialsText),
      );
    } else {
      content = _renderFallback(theme, bg, initialsText);
    }

    return ClipOval(
      child: SizedBox(width: size, height: size, child: content),
    );
  }

  Widget _renderFallback(SailThemeData theme, Color bg, String? initialsText) {
    if (fallback != null) {
      return Container(
        color: bg,
        alignment: Alignment.center,
        child: fallback,
      );
    }
    return Container(
      color: bg,
      alignment: Alignment.center,
      child: initialsText == null
          ? null
          : Text(
              initialsText,
              style: TextStyle(
                color: theme.colors.text,
                fontSize: size * 0.4,
                fontWeight: SailStyleValues.boldWeight,
              ),
            ),
    );
  }
}
