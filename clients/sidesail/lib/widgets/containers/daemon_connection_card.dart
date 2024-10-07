import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/routing/router.dart';

class DaemonConnectionCard extends StatelessWidget {
  AppRouter get _router => GetIt.I.get<AppRouter>();

  final Chain chain;
  final String? errorMessage;
  final bool initializing;
  final bool connected;
  final VoidCallback restartDaemon;

  final String? infoMessage;

  const DaemonConnectionCard({
    super.key,
    required this.chain,
    required this.initializing,
    required this.connected,
    required this.errorMessage,
    required this.infoMessage,
    required this.restartDaemon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailScaleButton(
      onPressed: () => _router.push(
        LogRoute(
          name: chain.name,
          logPath: chain.type.logDir(),
        ),
      ),
      child: SizedBox(
        width: 250,
        child: SailBorder(
          padding: const EdgeInsets.symmetric(
            horizontal: SailStyleValues.padding12,
            vertical: SailStyleValues.padding08,
          ),
          child: SailColumn(
            spacing: 0,
            children: [
              SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  SailSVG.fromAsset(
                    SailSVGAsset.iconGlobe,
                    color: infoMessage != null
                        ? theme.colors.info
                        : initializing
                            ? theme.colors.orangeLight
                            : connected
                                ? theme.colors.success
                                : theme.colors.error,
                  ),
                  SailText.primary13('${chain.name} daemon'),
                  Expanded(child: Container()),
                  SailScaleButton(
                    onPressed: restartDaemon,
                    child: InitializingDaemonSVG(
                      animate: initializing,
                    ),
                  ),
                ],
              ),
              SailText.primary10('View logs', color: theme.colors.textSecondary),
              const SailSpacing(SailStyleValues.padding12),
              SailText.secondary12(
                infoMessage ??
                    errorMessage ??
                    (initializing
                        ? 'Initializing...'
                        : connected
                            ? 'Connected'
                            : 'Unknown error occured'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
