import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class ResetButton extends StatelessWidget {
  const ResetButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Tooltip(
      message: 'Reset / Troubleshoot',
      child: InkWell(
        onTap: () => _navigateToResetSettings(context),
        borderRadius: SailStyleValues.borderRadiusSmall,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: SailRow(
            spacing: SailStyleValues.padding04,
            children: [
              SailSVG.fromAsset(
                SailSVGAsset.iconRestart,
                color: theme.colors.textSecondary,
                width: 12,
                height: 12,
              ),
              SailText.secondary12('Reset'),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToResetSettings(BuildContext context) {
    final confProvider = GetIt.I.get<BitcoinConfProvider>();
    final settingsTabIndex = confProvider.networkSupportsSidechains ? 6 : 5;

    // Set section first - will be pending if page not mounted yet
    SettingsPage.setSection(4);

    // Navigate to Settings tab
    final tabsRouter = AutoTabsRouter.of(context);
    tabsRouter.setActiveIndex(settingsTabIndex);
  }
}
