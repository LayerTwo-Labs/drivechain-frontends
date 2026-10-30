import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/sidechain_module.dart';

@RoutePage()
class SidechainSettingsPage extends StatefulWidget {
  const SidechainSettingsPage({super.key});

  static SidechainSettingsPageState? _currentState;
  static int? _pendingSection;

  static void setSection(int index) {
    if (_currentState != null) {
      _currentState!.setSelectedIndex(index);
    } else {
      _pendingSection = index;
    }
  }

  @override
  State<SidechainSettingsPage> createState() => SidechainSettingsPageState();
}

class SidechainSettingsPageState extends State<SidechainSettingsPage> {
  static const _sectionCount = 3;

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    SidechainSettingsPage._currentState = this;
    final pending = SidechainSettingsPage._pendingSection;
    SidechainSettingsPage._pendingSection = null;
    _selectedIndex = (pending ?? 0).clamp(0, _sectionCount - 1);
  }

  @override
  void dispose() {
    if (SidechainSettingsPage._currentState == this) {
      SidechainSettingsPage._currentState = null;
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
    final module = GetIt.I.get<SidechainModule>();
    final version = module.version;

    return SailSettingsScaffold(
      subtitle: 'Manage your ${module.appName} settings',
      selectedIndex: _selectedIndex,
      onSectionSelected: setSelectedIndex,
      sections: [
        SailSettingsSection(label: 'Appearance', builder: (_) => const SettingsAppearance()),
        SailSettingsSection(
          label: 'Reset',
          builder: (_) => SettingsReset(binary: module.chain, appName: module.fullName),
        ),
        SailSettingsSection(
          label: 'About',
          builder: (_) => SettingsInfo(
            appName: module.fullName,
            versionString: version.versionString,
            buildDate: version.buildDate,
            commitFull: version.commitFull,
            applicationName: version.appName,
          ),
        ),
      ],
    );
  }
}
