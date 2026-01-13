import 'package:auto_route/auto_route.dart';
import 'package:bitnames/pages/settings/settings_general.dart';
import 'package:bitnames/pages/settings/settings_info.dart';
import 'package:bitnames/pages/settings/settings_reset.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class SettingsTabPage extends StatefulWidget {
  const SettingsTabPage({super.key});

  static final GlobalKey<SettingsTabPageState> settingsKey = GlobalKey<SettingsTabPageState>();

  static void setSection(int index) {
    settingsKey.currentState?.setSelectedIndex(index);
  }

  @override
  State<SettingsTabPage> createState() => SettingsTabPageState();
}

class SettingsTabPageState extends State<SettingsTabPage> {
  int _selectedIndex = 0;

  void setSelectedIndex(int index) {
    if (index >= 0 && index < 3) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return QtPage(
      key: SettingsTabPage.settingsKey,
      child: SingleChildScrollView(
        child: SailColumn(
          spacing: SailStyleValues.padding10,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SailText.primary24(
              'Settings',
              bold: true,
            ),
            SailText.secondary13('Manage your Bitnames settings.'),
            const SailSpacing(SailStyleValues.padding10),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.colors.divider,
            ),
            const SailSpacing(SailStyleValues.padding10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SideNav(
                  items: const [
                    SideNavItem(label: 'General'),
                    SideNavItem(label: 'Reset'),
                    SideNavItem(label: 'Info'),
                  ],
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
                const SailSpacing(SailStyleValues.padding40),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const SettingsGeneral();
      case 1:
        return const SettingsReset();
      case 2:
        return const SettingsInfo();
      default:
        return const SettingsGeneral();
    }
  }
}
