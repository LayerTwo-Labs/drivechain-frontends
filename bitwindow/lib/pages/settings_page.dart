import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/gen/version.dart';
import 'package:bitwindow/pages/settings/settings_advanced.dart';
import 'package:bitwindow/pages/settings/settings_network.dart';
import 'package:bitwindow/pages/settings/settings_reset.dart';
import 'package:bitwindow/pages/settings/settings_wallet.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart' hide SettingsReset;

@RoutePage()
class SettingsPage extends StatefulWidget {
  final int initialSection;

  const SettingsPage({super.key, @PathParam('section') this.initialSection = 0});

  static SettingsPageState? _currentState;
  static int? _pendingSection;

  static void setSection(int index) {
    if (_currentState != null) {
      _currentState!.setSelectedIndex(index);
    } else {
      _pendingSection = index;
    }
  }

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  static const _sectionCount = 6;

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    SettingsPage._currentState = this;
    final pending = SettingsPage._pendingSection;
    SettingsPage._pendingSection = null;
    _selectedIndex = (pending ?? widget.initialSection).clamp(0, _sectionCount - 1);
  }

  @override
  void dispose() {
    if (SettingsPage._currentState == this) {
      SettingsPage._currentState = null;
    }
    super.dispose();
  }

  void setSelectedIndex(int index) {
    if (index >= 0 && index < _sectionCount) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SailSettingsScaffold(
      subtitle: 'Manage your BitWindow settings',
      selectedIndex: _selectedIndex,
      onSectionSelected: setSelectedIndex,
      sections: [
        SailSettingsSection(label: 'Network', builder: (_) => const SettingsNetwork()),
        SailSettingsSection(label: 'Wallet', builder: (_) => const SettingsWallet()),
        SailSettingsSection(label: 'Appearance', builder: (_) => const SettingsAppearance()),
        SailSettingsSection(label: 'Advanced', builder: (_) => const SettingsAdvanced()),
        SailSettingsSection(label: 'Reset', builder: (_) => const SettingsReset()),
        SailSettingsSection(
          label: 'About',
          builder: (_) => SettingsInfo(
            appName: 'BitWindow',
            versionString: AppVersion.versionString,
            buildDate: AppVersion.buildDate,
            commitFull: AppVersion.commitFull,
            applicationName: AppVersion.appName,
          ),
        ),
      ],
    );
  }
}
