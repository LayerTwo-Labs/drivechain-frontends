import 'package:bitnames/pages/tabs/home_page.dart';

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

  // Main tabs
  'parent_chain_page.dart': NavigationTarget(tabIndex: Tabs.ParentChainPeg.index),
  'bitnames_homepage.dart': NavigationTarget(tabIndex: Tabs.BitnamesHomepage.index),
  'reserve_register_page.dart': NavigationTarget(tabIndex: Tabs.Bitnames.index),
  'messaging_page.dart': NavigationTarget(tabIndex: Tabs.Messaging.index),
  'paymail_page.dart': NavigationTarget(tabIndex: Tabs.Bitnames.index),
  'wallet_utxos.dart': NavigationTarget(tabIndex: Tabs.Bitnames.index),
  'console_page.dart': NavigationTarget(tabIndex: Tabs.Console.index),
};
