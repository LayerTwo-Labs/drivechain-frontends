import 'package:auto_route/auto_route.dart';
import 'package:bbc/gen/version.dart';
import 'package:flutter/widgets.dart';
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
  static const _sectionCount = 3;

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    SettingsTabPage._currentState = this;
    final pending = SettingsTabPage._pendingSection;
    SettingsTabPage._pendingSection = null;
    _selectedIndex = (pending ?? 0).clamp(0, _sectionCount - 1);
  }

  @override
  void dispose() {
    if (SettingsTabPage._currentState == this) {
      SettingsTabPage._currentState = null;
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
      subtitle: 'Manage your Bbc settings',
      selectedIndex: _selectedIndex,
      onSectionSelected: setSelectedIndex,
      sections: [
        SailSettingsSection(label: 'Appearance', builder: (_) => const SettingsAppearance()),
        SailSettingsSection(
          label: 'Reset',
          builder: (_) => SettingsReset(binary: Bbc(), appName: 'Big Block Covenant'),
        ),
        SailSettingsSection(
          label: 'About',
          builder: (_) => SettingsInfo(
            appName: 'Big Block Covenant',
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
