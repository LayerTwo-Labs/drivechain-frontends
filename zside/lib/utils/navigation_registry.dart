import 'package:zside/pages/tabs/home_page.dart';

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
  'zside_homepage.dart': NavigationTarget(tabIndex: Tabs.ZSideHomepage.index),
  'zside_shield_deshield_page.dart': NavigationTarget(tabIndex: Tabs.ZSideShieldDeshield.index),
  'zside_melt_cast_page.dart': NavigationTarget(tabIndex: Tabs.ZSideMeltCast.index),
  'zside_transfer_page.dart': NavigationTarget(tabIndex: Tabs.ZSideHomepage.index),
  'zside_bill_page.dart': NavigationTarget(tabIndex: Tabs.ZSideHomepage.index),
  'console_page.dart': NavigationTarget(tabIndex: Tabs.Console.index),
};
