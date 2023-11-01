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

  static Widget mediumPrimary20(
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

  static Widget primary14(
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

  static Widget mediumPrimary14(
    String label, {
    bool softwrap = true,
    TextAlign? textAlign,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.medium14.copyWith(color: theme.colors.text),
          softwrap: softwrap,
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget secondary14(
    String label, {
    bool softwrap = true,
    TextAlign? textAlign,
  }) {
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

  static Widget mediumPrimary12(
    String label, {
    bool softwrap = true,
    TextAlign? textAlign,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.medium12.copyWith(color: theme.colors.text),
          softwrap: softwrap,
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget primary12(
    String label, {
    bool softwrap = true,
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

  static Widget secondary12(
    String label, {
    bool softwrap = true,
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

  static Widget mediumSecondary12(
    String label, {
    bool softwrap = true,
    TextAlign? textAlign,
  }) {
    return Builder(
      builder: (context) {
        final theme = SailTheme.of(context);
        return _Text(
          label: label,
          style: SailStyleValues.medium12.copyWith(color: theme.colors.textSecondary),
          softwrap: softwrap,
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
