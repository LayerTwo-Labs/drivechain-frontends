import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class SailStep {
  final String title;
  final String? subtitle;
  final Widget content;

  const SailStep({required this.title, this.subtitle, required this.content});
}

/// Vertical wizard: completed steps show a check, the active step expands
/// its content with [controls] underneath.
class SailStepper extends StatelessWidget {
  final List<SailStep> steps;
  final int currentStep;
  final Widget? controls;

  const SailStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.controls,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _StepHeader(
            index: i,
            title: steps[i].title,
            subtitle: steps[i].subtitle,
            isActive: i == currentStep,
            isCompleted: i < currentStep,
          ),
          if (i == currentStep)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  steps[i].content,
                  if (controls != null) controls!,
                ],
              ),
            ),
          if (i < steps.length - 1)
            Padding(
              padding: const EdgeInsets.only(left: 11),
              child: Container(
                width: 2,
                height: 12,
                color: theme.colors.divider,
              ),
            ),
        ],
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  final int index;
  final String title;
  final String? subtitle;
  final bool isActive;
  final bool isCompleted;

  const _StepHeader({
    required this.index,
    required this.title,
    this.subtitle,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final circleColor = isCompleted
        ? theme.colors.success
        : isActive
        ? theme.colors.primary
        : theme.colors.backgroundSecondary;

    return SailRow(
      spacing: SailStyleValues.padding12,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          child: Center(
            child: isCompleted
                ? SailSVG.fromAsset(SailSVGAsset.check, width: 12, color: theme.colors.background)
                : SailText.primary12(
                    '${index + 1}',
                    bold: true,
                    color: isActive ? theme.colors.primaryButtonText : theme.colors.textSecondary,
                  ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary13(title, bold: isActive),
              if (subtitle != null) SailText.secondary12(subtitle!),
            ],
          ),
        ),
      ],
    );
  }
}
