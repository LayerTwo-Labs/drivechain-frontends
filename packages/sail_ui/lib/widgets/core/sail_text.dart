import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';

class _Text extends StatelessWidget {
  final String label;
  final TextStyle style;
  final TextAlign? textAlign;

  const _Text({required this.label, required this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    double systemTextScaleFactor = MediaQuery.of(context).textScaleFactor;
    // cap max text size at a sensible value. Sorry very blind people
    double cappedTextScaleFactor = math.min(systemTextScaleFactor, 2);

    return Text(
      label,
      style: style,
      textScaleFactor: cappedTextScaleFactor,
      softWrap: true,
      textAlign: textAlign,
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
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.twentyFour.copyWith(
            color: theme.colors.text,
            fontWeight: bold ? SailStyleValues.mediumWeight : null,
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
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.twentyTwo.copyWith(
            color: theme.colors.text,
            fontWeight: bold ? SailStyleValues.mediumWeight : null,
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
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.twenty.copyWith(
            color: theme.colors.text,
            fontWeight: bold ? SailStyleValues.mediumWeight : null,
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
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.fifteen.copyWith(
            color: theme.colors.text,
            fontWeight: bold ? SailStyleValues.mediumWeight : null,
          ),
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget primary13(
    String label, {
    TextAlign? textAlign,
    bool bold = false,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.thirteen.copyWith(
            color: theme.colors.text,
            fontWeight: bold ? SailStyleValues.mediumWeight : null,
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
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.thirteen.copyWith(
            color: theme.colors.textSecondary,
            fontWeight: bold ? SailStyleValues.mediumWeight : null,
          ),
        );
      },
    );
  }

  static Widget primary12(
    String label, {
    TextAlign? textAlign,
    bool bold = false,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.twelve.copyWith(
            color: theme.colors.text,
            fontWeight: bold ? SailStyleValues.mediumWeight : null,
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
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.twelve.copyWith(
            color: theme.colors.textTertiary,
            fontWeight: bold ? SailStyleValues.mediumWeight : null,
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
