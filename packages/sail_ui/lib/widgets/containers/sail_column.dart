import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/optional_builder.dart';

class SailColumn extends StatelessWidget {
  final List<Widget> children;
  final bool leadingSpacing;
  final bool trailingSpacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool withDivider;
  final double spacing;

  const SailColumn({
    Key? key,
    required this.spacing,
    required this.children,
    this.leadingSpacing = false,
    this.trailingSpacing = false,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.withDivider = false,
  }) : super(key: key);

  bool notLastOrFirst(int i) => i >= 0 && i < (children.length - 1);
  bool isNotOptional(i) => children[i] is! SailOptional;
  bool isOptionalWithValue(i) {
    final child = children[i];
    if (child is SailOptional) {
      return (child).value != null;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i == 0 && leadingSpacing)
            SailSpacing(
              spacing,
            ),
          children[i],
          if (notLastOrFirst(i) && (isNotOptional(i) || isOptionalWithValue(i)))
            SailSpacing(
              spacing,
            ),
          if (notLastOrFirst(i) && withDivider)
            Divider(
              height: 1,
              thickness: 0.5,
              color: theme.colors.divider,
            ),
          // add spacing before and after divider
          if (notLastOrFirst(i) && withDivider)
            SailSpacing(
              spacing,
            ),
          if (i == (children.length - 1) && trailingSpacing)
            SailSpacing(
              spacing,
            ),
        ],
      ],
    );
  }
}

class SailRow extends StatelessWidget {
  final List<Widget> children;
  final bool leadingSpacing;
  final bool trailingSpacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;

  const SailRow({
    Key? key,
    required this.spacing,
    required this.children,
    this.leadingSpacing = false,
    this.trailingSpacing = false,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i == 0 && leadingSpacing) SizedBox(width: spacing),
          children[i],
          if (i >= 0 && i < (children.length - 1)) SizedBox(width: spacing),
          if (i == (children.length - 1) && trailingSpacing) SizedBox(width: spacing),
        ],
      ],
    );
  }
}
