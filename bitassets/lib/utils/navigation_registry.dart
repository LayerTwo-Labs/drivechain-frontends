import 'package:bitassets/pages/tabs/home_page.dart';

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
  'bitassets_homepage.dart': NavigationTarget(tabIndex: Tabs.BitAssetsHomepage.index),
  'reserve_register_page.dart': NavigationTarget(tabIndex: Tabs.BitAssets.index),
  'messaging_page.dart': NavigationTarget(tabIndex: Tabs.Messaging.index),
  'dutch_auction_page.dart': NavigationTarget(tabIndex: Tabs.DutchAuction.index),
  'amm_page.dart': NavigationTarget(tabIndex: Tabs.Amm.index),
  'paymail_page.dart': NavigationTarget(tabIndex: Tabs.BitAssets.index),
  'wallet_utxos.dart': NavigationTarget(tabIndex: Tabs.BitAssets.index),
  'console_page.dart': NavigationTarget(tabIndex: Tabs.Console.index),
};
