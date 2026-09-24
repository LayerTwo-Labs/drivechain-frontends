import 'dart:async';

import 'package:bitwindow/providers/backend_swap_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Why BitWindow holds the user on a restart.
const String backendSwapReason =
    'BitWindow found a backend from the last run. It replaces that one, so you get the code of this version.';

/// What the detail reads when the swap ends while the user looks at it.
const String backendSwapDone = 'The new backend runs.';

/// What the bottom bar reads beside the step.
const String backendSwapOpenSteps = 'Click for the steps';

/// What the splash screen reads when no swap runs.
const String splashStartLabel = 'Starting BitWindow...';

Future<void> openBackendSwap(BuildContext context) => widgetDialog(
  context: context,
  title: 'Backend restart',
  maxWidth: 520,
  child: const BackendSwapSteps(),
);

/// The bottom bar of a route that carries no [BottomNav]. A running swap reads
/// over the error banner, because a planned stop is not a fault.
class BackendSwapBar extends StatelessWidget {
  const BackendSwapBar({super.key, required this.child, this.swap});

  final Widget child;
  final BackendSwapProvider? swap;

  @override
  Widget build(BuildContext context) {
    final provider = swap ?? GetIt.I.get<BackendSwapProvider>();
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        if (!provider.swapping) {
          return child;
        }
        final colors = SailTheme.of(context).colors;
        return Material(
          color: colors.backgroundSecondary,
          child: InkWell(
            onTap: () => unawaited(openBackendSwap(context)),
            child: SizedBox(
              height: 36,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: colors.border)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 1.6, color: colors.primary),
                      ),
                      const SizedBox(width: SailStyleValues.padding08),
                      Expanded(child: SailText.primary12(provider.navLabel)),
                      SailText.secondary12(backendSwapOpenSteps),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The steps of the running swap, with the seconds on the current one.
class BackendSwapSteps extends StatelessWidget {
  const BackendSwapSteps({super.key, this.swap});

  final BackendSwapProvider? swap;

  @override
  Widget build(BuildContext context) {
    final provider = swap ?? GetIt.I.get<BackendSwapProvider>();
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) => SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SailText.secondary12(backendSwapReason, overflow: TextOverflow.visible),
          if (provider.steps.isEmpty)
            SailText.primary13(backendSwapDone, overflow: TextOverflow.visible)
          else
            for (final step in provider.steps)
              _StepRow(
                step: step,
                active: step == provider.step,
                failed: step == provider.failedStep,
                seconds: provider.seconds,
              ),
          if (provider.error != null)
            SailText.primary13(
              'The swap stopped: ${provider.error}',
              color: SailTheme.of(context).colors.error,
              overflow: TextOverflow.visible,
            ),
        ],
      ),
    );
  }
}

/// The splash screen line. It names the step while a swap runs.
class BackendSwapSplash extends StatelessWidget {
  const BackendSwapSplash({super.key, this.swap});

  final BackendSwapProvider? swap;

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    final provider = swap ?? GetIt.I.get<BackendSwapProvider>();
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        final step = provider.step;
        return SailColumn(
          spacing: SailStyleValues.padding04,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SailText.primary10(
              step == null ? splashStartLabel : provider.navLabel,
              color: colors.inactiveNavText,
            ),
            if (step != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: SailText.primary10(
                  step.detail,
                  color: colors.inactiveNavText,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.active, required this.failed, required this.seconds});

  final BackendSwapStep step;
  final bool active;
  final bool failed;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SizedBox(
            width: 16,
            height: 16,
            child: active
                ? CircularProgressIndicator(strokeWidth: 1.6, color: colors.primary)
                : failed
                ? SailSVG.fromAsset(SailSVGAsset.circleX, color: colors.error)
                : SailSVG.fromAsset(SailSVGAsset.circleCheck, color: colors.success),
          ),
        ),
        const SizedBox(width: SailStyleValues.padding08),
        Expanded(
          child: SailColumn(
            spacing: SailStyleValues.padding04,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary13(active ? '${step.label} (${seconds}s)' : step.label, overflow: TextOverflow.visible),
              SailText.secondary12(step.detail, overflow: TextOverflow.visible),
            ],
          ),
        ),
      ],
    );
  }
}
