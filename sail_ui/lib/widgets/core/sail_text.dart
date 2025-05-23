import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class _Text extends StatelessWidget {
  final String label;
  final TextStyle style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const _Text({
    required this.label,
    required this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    var scaler = MediaQuery.of(context).textScaler;
    // cap max text size at a sensible value. Sorry very blind people
    scaler = scaler.clamp(maxScaleFactor: 2);

    return Text(
      label,
      style: style,
      textScaler: scaler,
      softWrap: true,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class SailText {
  final String value;

  const SailText(
    this.value,
  );

  static Widget primary24(
    String label, {
    TextAlign? textAlign,
    bool bold = false,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.twentyFour.copyWith(
            color: color ?? theme.colors.text,
            fontWeight: bold ? SailStyleValues.boldWeight : null,
          ),
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget primary22(
    String label, {
    TextAlign? textAlign,
    bool bold = false,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.twentyTwo.copyWith(
            color: color ?? theme.colors.text,
            fontWeight: bold ? SailStyleValues.boldWeight : null,
          ),
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget primary20(
    String label, {
    TextAlign? textAlign,
    bool bold = false,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.twenty.copyWith(
            color: color ?? theme.colors.text,
            fontWeight: bold ? SailStyleValues.boldWeight : null,
          ),
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget primary15(
    String label, {
    TextAlign? textAlign,
    bool bold = false,
    Color? color,
    bool underline = false,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.fifteen.copyWith(
            color: color ?? theme.colors.text,
            fontWeight: bold ? SailStyleValues.boldWeight : null,
            decoration: underline ? TextDecoration.underline : TextDecoration.none,
            decorationColor: underline ? (color ?? theme.colors.text) : null,
          ),
          maxLines: maxLines,
          overflow: overflow,
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget primary13(
    String label, {
    TextAlign? textAlign,
    bool bold = false,
    Color? color,
    bool underline = false,
    bool monospace = false,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.thirteen.copyWith(
            color: color ?? theme.colors.text,
            fontWeight: bold ? SailStyleValues.boldWeight : null,
            decoration: underline ? TextDecoration.underline : TextDecoration.none,
            decorationColor: underline ? (color ?? theme.colors.text) : null,
            fontFamily: monospace ? 'SourceCodePro' : 'Inter',
            overflow: overflow,
          ),
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget secondary13(
    String label, {
    TextAlign? textAlign,
    bool bold = false,
    Color? color,
    bool monospace = false,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.thirteen.copyWith(
            color: color ?? theme.colors.textSecondary,
            fontWeight: bold ? SailStyleValues.boldWeight : null,
            fontFamily: monospace ? 'SourceCodePro' : 'Inter',
          ),
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget secondary15(
    String label, {
    TextAlign? textAlign,
    bool bold = false,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.fifteen.copyWith(
            color: color ?? theme.colors.textSecondary,
            fontWeight: bold ? SailStyleValues.boldWeight : null,
          ),
        );
      },
    );
  }

  static Widget primary12(
    String label, {
    TextAlign? textAlign,
    bool bold = false,
    bool italic = false,
    Color? color,
    bool monospace = false,
    TextOverflow overflow = TextOverflow.ellipsis,
    TextDecoration? decoration,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);

        return _Text(
          label: label,
          style: SailStyleValues.twelve.copyWith(
            color: color ?? theme.colors.text,
            fontWeight: bold ? SailStyleValues.boldWeight : null,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            fontFamily: monospace ? 'SourceCodePro' : 'Inter',
            overflow: overflow,
            decoration: decoration,
          ),
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget secondary12(
    String label, {
    TextAlign? textAlign,
    bool bold = false,
    bool italic = false,
    Color? color,
    bool monospace = false,
    TextOverflow? overflow,
    int? maxLines,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.twelve.copyWith(
            color: color ?? theme.colors.textSecondary,
            fontWeight: bold ? SailStyleValues.boldWeight : null,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            fontFamily: monospace ? 'SourceCodePro' : 'Inter',
            overflow: overflow,
          ),
          maxLines: maxLines,
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget background12(
    String label, {
    TextAlign? textAlign,
    bool bold = false,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.twelve.copyWith(
            color: color ?? theme.colors.background,
            fontWeight: bold ? SailStyleValues.boldWeight : null,
          ),
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget background13(
    String label, {
    TextAlign? textAlign,
    bool bold = false,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.thirteen.copyWith(
            color: color ?? theme.colors.background,
            fontWeight: bold ? SailStyleValues.boldWeight : null,
          ),
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget primary10(
    String label, {
    TextAlign? textAlign,
    bool bold = false,
    bool italic = false,
    bool underline = false,
    Color? color,
    bool monospace = false,
    TextDecoration? decoration,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.ten.copyWith(
            color: color ?? theme.colors.text,
            fontWeight: bold ? SailStyleValues.boldWeight : null,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            decoration: decoration ?? (underline ? TextDecoration.underline : TextDecoration.none),
            fontFamily: monospace ? 'SourceCodePro' : 'Inter',
          ),
          textAlign: textAlign,
        );
      },
    );
  }
}

class Shadow {
  static List<BoxShadow> regular(
    BuildContext context,
  ) {
    final theme = SailTheme.of(context);
    return [
      BoxShadow(
        color: theme.colors.shadow,
        blurRadius: 6,
        spreadRadius: 3,
      ),
    ];
  }
}
