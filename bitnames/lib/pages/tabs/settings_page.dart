import 'package:auto_route/auto_route.dart';
import 'package:bitnames/pages/settings/settings_general.dart';
import 'package:bitnames/pages/settings/settings_info.dart';
import 'package:bitnames/pages/settings/settings_reset.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class SettingsTabPage extends StatefulWidget {
  const SettingsTabPage({super.key});

  static SettingsTabPageState? _currentState;
  static int? _pendingSection;

  static void setSection(int index) {
    if (_currentState != null) {
      _currentState!.setSelectedIndex(index);
    } else {
      _pendingSection = index;
    }
  }

  @override
  State<SettingsTabPage> createState() => SettingsTabPageState();
}

class SettingsTabPageState extends State<SettingsTabPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    SettingsTabPage._currentState = this;
    // Use pending section if set, otherwise default to 0
    if (SettingsTabPage._pendingSection != null) {
      _selectedIndex = SettingsTabPage._pendingSection!.clamp(0, 2);
      SettingsTabPage._pendingSection = null;
    } else {
      _selectedIndex = 0;
    }
  }

  @override
  void dispose() {
    if (SettingsTabPage._currentState == this) {
      SettingsTabPage._currentState = null;
    }
    super.dispose();
  }

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

    return Container(
      color: theme.colors.background,
      padding: const EdgeInsets.all(SailStyleValues.padding12),
      child: SelectionArea(
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
                    child: [
                      const SettingsGeneral(),
                      const SettingsReset(),
                      const SettingsInfo(),
                    ][_selectedIndex],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
