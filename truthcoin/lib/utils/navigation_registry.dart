import 'package:truthcoin/pages/tabs/home_page.dart';

class NavigationTarget {
  final int tabIndex;
  final int? sectionIndex;

  const NavigationTarget({required this.tabIndex, this.sectionIndex});
}

final Map<String, NavigationTarget> navigationRegistry = {
  // Settings sections
  'settings_general.dart': NavigationTarget(tabIndex: Tabs.SettingsHome.index, sectionIndex: 0),
  'settings_reset.dart': NavigationTarget(tabIndex: Tabs.SettingsHome.index, sectionIndex: 1),
  'settings_info.dart': NavigationTarget(tabIndex: Tabs.SettingsHome.index, sectionIndex: 2),

  // Main pages
  'truthcoin_homepage.dart': NavigationTarget(tabIndex: Tabs.TruthcoinHomepage.index),
  'console_tab.dart': NavigationTarget(tabIndex: Tabs.Console.index),
  'parent_chain_page.dart': NavigationTarget(tabIndex: Tabs.ParentChainPeg.index),
};
