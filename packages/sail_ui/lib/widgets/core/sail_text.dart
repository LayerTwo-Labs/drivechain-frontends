import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';

class _Text extends StatelessWidget {
  final String label;
  final TextStyle style;
  final bool softwrap;
  final TextAlign? textAlign;

  const _Text({required this.label, required this.style, this.softwrap = true, this.textAlign});

  @override
  Widget build(BuildContext context) {
    double systemTextScaleFactor = MediaQuery.of(context).textScaleFactor;
    // cap max text size at a sensible value. Sorry very blind people
    double cappedTextScaleFactor = math.min(systemTextScaleFactor, 2);

    return Text(
      label,
      style: style,
      textScaleFactor: cappedTextScaleFactor,
      softWrap: softwrap,
      textAlign: textAlign,
    );
  }
}

class SailText {
  final String value;

  const SailText(
    this.value,
  );

  static Widget mediumText35(
    String label,
  ) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.medium35.copyWith(color: theme.colors.text),
        );
      },
    );
  }

  static Widget mediumText30(
    String label,
  ) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.medium30.copyWith(color: theme.colors.text),
        );
      },
    );
  }

  static Widget mediumColor35(
    String label,
    Color color,
  ) {
    return Builder(
      builder: (context) {
        return _Text(
          label: label,
          style: SailStyleValues.medium35.copyWith(color: color),
        );
      },
    );
  }

  static Widget mediumText25(
    String label,
  ) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.medium25.copyWith(color: theme.colors.text),
        );
      },
    );
  }

  static Widget mediumColor25(
    String label,
    Color color,
  ) {
    return Builder(
      builder: (context) {
        return _Text(
          label: label,
          style: SailStyleValues.medium25.copyWith(color: color),
        );
      },
    );
  }

  static Widget mediumText20(
    String label, {
    bool softwrap = true,
    TextAlign? textAlign,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.medium20.copyWith(color: theme.colors.text),
          softwrap: softwrap,
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget mediumColor20(
    String label,
    Color color,
  ) {
    return Builder(
      builder: (context) {
        return _Text(
          label: label,
          style: SailStyleValues.medium20.copyWith(color: color),
        );
      },
    );
  }

  static Widget mediumDarkGrey20(
    String label,
  ) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.medium20.copyWith(color: theme.colors.textSecondary),
        );
      },
    );
  }

  static Widget mediumColor16(
    String label,
    Color color,
  ) {
    return Builder(
      builder: (context) {
        return _Text(
          label: label,
          style: SailStyleValues.medium16.copyWith(color: color),
        );
      },
    );
  }

  static Widget mediumDarkGrey16(
    String label,
  ) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.medium16.copyWith(color: theme.colors.textSecondary),
        );
      },
    );
  }

  static Widget mediumText16(
    String label,
  ) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.medium16.copyWith(color: theme.colors.text),
        );
      },
    );
  }

  static Widget mediumText14(
    String label,
  ) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.medium14.copyWith(color: theme.colors.text),
        );
      },
    );
  }

  static Widget mediumColor14(
    String label,
    Color color,
  ) {
    return Builder(
      builder: (context) {
        return _Text(
          label: label,
          style: SailStyleValues.medium14.copyWith(color: color),
        );
      },
    );
  }

  static Widget regularText16(
    String label, {
    TextDecoration? decoration,
    bool softwrap = true,
    TextAlign? textAlign,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.regular16.copyWith(color: theme.colors.text, decoration: decoration),
          softwrap: softwrap,
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget regularDarkGrey16(
    String label,
  ) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.regular16.copyWith(color: theme.colors.textSecondary),
        );
      },
    );
  }

  static Widget regularColor16(
    String label,
    Color color, {
    TextAlign? textAlign,
  }) {
    return Builder(
      builder: (context) {
        return _Text(
          label: label,
          style: SailStyleValues.regular16.copyWith(color: color),
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget mediumPrimary16(
    String label,
  ) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.medium16.copyWith(color: theme.colors.background),
        );
      },
    );
  }

  static Widget regularText14(
    String label, {
    bool softwrap = true,
    TextAlign? textAlign,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.regular14.copyWith(color: theme.colors.text),
          softwrap: softwrap,
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget mediumOrange14(
    String label,
  ) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.medium14.copyWith(color: theme.colors.orange),
        );
      },
    );
  }

  static Widget lightDarkGrey14(
    String label,
  ) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.light14.copyWith(color: theme.colors.textSecondary),
        );
      },
    );
  }

  static Widget lightColor14(
    String label,
    Color color,
  ) {
    return Builder(
      builder: (context) {
        return _Text(
          label: label,
          style: SailStyleValues.light14.copyWith(color: color),
        );
      },
    );
  }

  static Widget regularDarkGrey14(
    String label,
  ) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.regular14.copyWith(color: theme.colors.textSecondary),
        );
      },
    );
  }

  static Widget regularText12(
    String label, {
    TextAlign? textAlign,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.regular12.copyWith(color: theme.colors.text),
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget regularColor12(
    String label,
    Color color, {
    bool softwrap = true,
  }) {
    return Builder(
      builder: (context) {
        return _Text(
          label: label,
          style: SailStyleValues.regular12.copyWith(color: color),
          softwrap: softwrap,
        );
      },
    );
  }

  static Widget lightDarkGrey12(
    String label,
  ) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.light12.copyWith(color: theme.colors.textSecondary),
          softwrap: true,
        );
      },
    );
  }

  static Widget mediumTertiary12(
    String label,
  ) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.medium12.copyWith(color: theme.colors.textTertiary),
        );
      },
    );
  }

  static Widget mediumColor12(
    String label,
    Color color,
  ) {
    return Builder(
      builder: (context) {
        return _Text(
          label: label,
          style: SailStyleValues.medium12.copyWith(color: color),
        );
      },
    );
  }

  static Widget mediumColor10(
    String label,
    Color color,
  ) {
    return Builder(
      builder: (context) {
        return _Text(
          label: label,
          style: SailStyleValues.medium10.copyWith(color: color),
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
