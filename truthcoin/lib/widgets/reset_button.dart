import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:truthcoin/pages/tabs/home_page.dart';
import 'package:truthcoin/pages/tabs/settings_page.dart';

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
    // Set section first - will be pending if page not mounted yet
    SettingsTabPage.setSection(1);

    // Navigate to Settings tab
    final tabsRouter = AutoTabsRouter.of(context);
    tabsRouter.setActiveIndex(Tabs.SettingsHome.index);
  }
}
